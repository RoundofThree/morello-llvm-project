//===--- ClangdMain.cpp - clangd server loop ------------------------------===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ClangdLSPServer.h"
#include "JSONRPCDispatcher.h"
#include "Path.h"
#include "RIFF.h"
#include "Trace.h"
#include "index/SymbolYAML.h"
#include "clang/Basic/Version.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/FileSystem.h"
#include "llvm/Support/Path.h"
#include "llvm/Support/Program.h"
#include "llvm/Support/Signals.h"
#include "llvm/Support/raw_ostream.h"
#include <cstdlib>
#include <iostream>
#include <memory>
#include <string>
#include <thread>

using namespace clang;
using namespace clang::clangd;

// FIXME: remove this option when Dex is stable enough.
static llvm::cl::opt<bool>
    UseDex("use-dex-index",
           llvm::cl::desc("Use experimental Dex static index."),
           llvm::cl::init(true), llvm::cl::Hidden);

static llvm::cl::opt<Path> CompileCommandsDir(
    "compile-commands-dir",
    llvm::cl::desc("Specify a path to look for compile_commands.json. If path "
                   "is invalid, clangd will look in the current directory and "
                   "parent paths of each source file."));

static llvm::cl::opt<unsigned>
    WorkerThreadsCount("j",
                       llvm::cl::desc("Number of async workers used by clangd"),
                       llvm::cl::init(getDefaultAsyncThreadsCount()));

// FIXME: also support "plain" style where signatures are always omitted.
enum CompletionStyleFlag { Detailed, Bundled };
static llvm::cl::opt<CompletionStyleFlag> CompletionStyle(
    "completion-style",
    llvm::cl::desc("Granularity of code completion suggestions"),
    llvm::cl::values(
        clEnumValN(Detailed, "detailed",
                   "One completion item for each semantically distinct "
                   "completion, with full type information."),
        clEnumValN(Bundled, "bundled",
                   "Similar completion items (e.g. function overloads) are "
                   "combined. Type information shown where possible.")),
    llvm::cl::init(Detailed));

// FIXME: Flags are the wrong mechanism for user preferences.
// We should probably read a dotfile or similar.
static llvm::cl::opt<bool> IncludeIneligibleResults(
    "include-ineligible-results",
    llvm::cl::desc(
        "Include ineligible completion results (e.g. private members)"),
    llvm::cl::init(clangd::CodeCompleteOptions().IncludeIneligibleResults),
    llvm::cl::Hidden);

static llvm::cl::opt<JSONStreamStyle> InputStyle(
    "input-style", llvm::cl::desc("Input JSON stream encoding"),
    llvm::cl::values(
        clEnumValN(JSONStreamStyle::Standard, "standard", "usual LSP protocol"),
        clEnumValN(JSONStreamStyle::Delimited, "delimited",
                   "messages delimited by --- lines, with # comment support")),
    llvm::cl::init(JSONStreamStyle::Standard));

static llvm::cl::opt<bool>
    PrettyPrint("pretty", llvm::cl::desc("Pretty-print JSON output"),
                llvm::cl::init(false));

static llvm::cl::opt<Logger::Level> LogLevel(
    "log", llvm::cl::desc("Verbosity of log messages written to stderr"),
    llvm::cl::values(clEnumValN(Logger::Error, "error", "Error messages only"),
                     clEnumValN(Logger::Info, "info",
                                "High level execution tracing"),
                     clEnumValN(Logger::Debug, "verbose", "Low level details")),
    llvm::cl::init(Logger::Info));

static llvm::cl::opt<bool> Test(
    "lit-test",
    llvm::cl::desc(
        "Abbreviation for -input-style=delimited -pretty -run-synchronously. "
        "Intended to simplify lit tests."),
    llvm::cl::init(false), llvm::cl::Hidden);

enum PCHStorageFlag { Disk, Memory };
static llvm::cl::opt<PCHStorageFlag> PCHStorage(
    "pch-storage",
    llvm::cl::desc("Storing PCHs in memory increases memory usages, but may "
                   "improve performance"),
    llvm::cl::values(
        clEnumValN(PCHStorageFlag::Disk, "disk", "store PCHs on disk"),
        clEnumValN(PCHStorageFlag::Memory, "memory", "store PCHs in memory")),
    llvm::cl::init(PCHStorageFlag::Disk));

static llvm::cl::opt<int> LimitResults(
    "limit-results",
    llvm::cl::desc("Limit the number of results returned by clangd. "
                   "0 means no limit."),
    llvm::cl::init(100));

static llvm::cl::opt<bool> RunSynchronously(
    "run-synchronously",
    llvm::cl::desc("Parse on main thread. If set, -j is ignored"),
    llvm::cl::init(false), llvm::cl::Hidden);

static llvm::cl::opt<Path>
    ResourceDir("resource-dir",
                llvm::cl::desc("Directory for system clang headers"),
                llvm::cl::init(""), llvm::cl::Hidden);

static llvm::cl::opt<Path> InputMirrorFile(
    "input-mirror-file",
    llvm::cl::desc(
        "Mirror all LSP input to the specified file. Useful for debugging."),
    llvm::cl::init(""), llvm::cl::Hidden);

static llvm::cl::opt<bool> EnableIndex(
    "index",
    llvm::cl::desc(
        "Enable index-based features. By default, clangd maintains an index "
        "built from symbols in opened files. Global index support needs to "
        "enabled separatedly."),
    llvm::cl::init(true), llvm::cl::Hidden);

static llvm::cl::opt<bool>
    ShowOrigins("debug-origin",
                llvm::cl::desc("Show origins of completion items"),
                llvm::cl::init(clangd::CodeCompleteOptions().ShowOrigins),
                llvm::cl::Hidden);

static llvm::cl::opt<bool> HeaderInsertionDecorators(
    "header-insertion-decorators",
    llvm::cl::desc("Prepend a circular dot or space before the completion "
                   "label, depending on whether "
                   "an include line will be inserted or not."),
    llvm::cl::init(true));

static llvm::cl::opt<Path> YamlSymbolFile(
    "yaml-symbol-file",
    llvm::cl::desc(
        "YAML-format global symbol file to build the static index. Clangd will "
        "use the static index for global code completion.\n"
        "WARNING: This option is experimental only, and will be removed "
        "eventually. Don't rely on it."),
    llvm::cl::init(""), llvm::cl::Hidden);

enum CompileArgsFrom { LSPCompileArgs, FilesystemCompileArgs };
static llvm::cl::opt<CompileArgsFrom> CompileArgsFrom(
    "compile_args_from", llvm::cl::desc("The source of compile commands"),
    llvm::cl::values(clEnumValN(LSPCompileArgs, "lsp",
                                "All compile commands come from LSP and "
                                "'compile_commands.json' files are ignored"),
                     clEnumValN(FilesystemCompileArgs, "filesystem",
                                "All compile commands come from the "
                                "'compile_commands.json' files")),
    llvm::cl::init(FilesystemCompileArgs), llvm::cl::Hidden);

static llvm::cl::opt<bool> EnableFunctionArgSnippets(
    "function-arg-placeholders",
    llvm::cl::desc("When disabled, completions contain only parentheses for "
                   "function calls. When enabled, completions also contain "
                   "placeholders for method parameters."),
    llvm::cl::init(clangd::CodeCompleteOptions().EnableFunctionArgSnippets));

int main(int argc, char *argv[]) {
  llvm::sys::PrintStackTraceOnErrorSignal(argv[0]);
  llvm::cl::SetVersionPrinter([](llvm::raw_ostream &OS) {
    OS << clang::getClangToolFullVersion("clangd") << "\n";
  });
  llvm::cl::ParseCommandLineOptions(
      argc, argv,
      "clangd is a language server that provides IDE-like features to editors. "
      "\n\nIt should be used via an editor plugin rather than invoked directly."
      "For more information, see:"
      "\n\thttps://clang.llvm.org/extra/clangd.html"
      "\n\thttps://microsoft.github.io/language-server-protocol/");
  if (Test) {
    RunSynchronously = true;
    InputStyle = JSONStreamStyle::Delimited;
    PrettyPrint = true;
  }

  if (!RunSynchronously && WorkerThreadsCount == 0) {
    llvm::errs() << "A number of worker threads cannot be 0. Did you mean to "
                    "specify -run-synchronously?";
    return 1;
  }

  if (RunSynchronously) {
    if (WorkerThreadsCount.getNumOccurrences())
      llvm::errs() << "Ignoring -j because -run-synchronously is set.\n";
    WorkerThreadsCount = 0;
  }

  // Validate command line arguments.
  llvm::Optional<llvm::raw_fd_ostream> InputMirrorStream;
  if (!InputMirrorFile.empty()) {
    std::error_code EC;
    InputMirrorStream.emplace(InputMirrorFile, /*ref*/ EC,
                              llvm::sys::fs::FA_Read | llvm::sys::fs::FA_Write);
    if (EC) {
      InputMirrorStream.reset();
      llvm::errs() << "Error while opening an input mirror file: "
                   << EC.message();
    }
  }

  // Setup tracing facilities if CLANGD_TRACE is set. In practice enabling a
  // trace flag in your editor's config is annoying, launching with
  // `CLANGD_TRACE=trace.json vim` is easier.
  llvm::Optional<llvm::raw_fd_ostream> TraceStream;
  std::unique_ptr<trace::EventTracer> Tracer;
  if (auto *TraceFile = getenv("CLANGD_TRACE")) {
    std::error_code EC;
    TraceStream.emplace(TraceFile, /*ref*/ EC,
                        llvm::sys::fs::FA_Read | llvm::sys::fs::FA_Write);
    if (EC) {
      TraceStream.reset();
      llvm::errs() << "Error while opening trace file " << TraceFile << ": "
                   << EC.message();
    } else {
      Tracer = trace::createJSONTracer(*TraceStream, PrettyPrint);
    }
  }

  llvm::Optional<trace::Session> TracingSession;
  if (Tracer)
    TracingSession.emplace(*Tracer);

  // Use buffered stream to stderr (we still flush each log message). Unbuffered
  // stream can cause significant (non-deterministic) latency for the logger.
  llvm::errs().SetBuffered();
  JSONOutput Out(llvm::outs(), llvm::errs(), LogLevel,
                 InputMirrorStream ? InputMirrorStream.getPointer() : nullptr,
                 PrettyPrint);

  clangd::LoggingSession LoggingSession(Out);

  // If --compile-commands-dir arg was invoked, check value and override default
  // path.
  llvm::Optional<Path> CompileCommandsDirPath;
  if (CompileCommandsDir.empty()) {
    CompileCommandsDirPath = llvm::None;
  } else if (!llvm::sys::path::is_absolute(CompileCommandsDir) ||
             !llvm::sys::fs::exists(CompileCommandsDir)) {
    llvm::errs() << "Path specified by --compile-commands-dir either does not "
                    "exist or is not an absolute "
                    "path. The argument will be ignored.\n";
    CompileCommandsDirPath = llvm::None;
  } else {
    CompileCommandsDirPath = CompileCommandsDir;
  }

  ClangdServer::Options Opts;
  switch (PCHStorage) {
  case PCHStorageFlag::Memory:
    Opts.StorePreamblesInMemory = true;
    break;
  case PCHStorageFlag::Disk:
    Opts.StorePreamblesInMemory = false;
    break;
  }
  if (!ResourceDir.empty())
    Opts.ResourceDir = ResourceDir;
  Opts.BuildDynamicSymbolIndex = EnableIndex;
  std::unique_ptr<SymbolIndex> StaticIdx;
  std::future<void> AsyncIndexLoad; // Block exit while loading the index.
  if (EnableIndex && !YamlSymbolFile.empty()) {
    // Load the index asynchronously. Meanwhile SwapIndex returns no results.
    SwapIndex *Placeholder;
    StaticIdx.reset(Placeholder = new SwapIndex(llvm::make_unique<MemIndex>()));
    AsyncIndexLoad = runAsync<void>([Placeholder, &Opts] {
      if (auto Idx = loadIndex(YamlSymbolFile, Opts.URISchemes, UseDex))
        Placeholder->reset(std::move(Idx));
    });
    if (RunSynchronously)
      AsyncIndexLoad.wait();
  }
  Opts.StaticIndex = StaticIdx.get();
  Opts.AsyncThreadsCount = WorkerThreadsCount;

  clangd::CodeCompleteOptions CCOpts;
  CCOpts.IncludeIneligibleResults = IncludeIneligibleResults;
  CCOpts.Limit = LimitResults;
  CCOpts.BundleOverloads = CompletionStyle != Detailed;
  CCOpts.ShowOrigins = ShowOrigins;
  if (!HeaderInsertionDecorators) {
    CCOpts.IncludeIndicator.Insert.clear();
    CCOpts.IncludeIndicator.NoInsert.clear();
  }
  CCOpts.SpeculativeIndexRequest = Opts.StaticIndex;
  CCOpts.EnableFunctionArgSnippets = EnableFunctionArgSnippets;

  // Initialize and run ClangdLSPServer.
  ClangdLSPServer LSPServer(
      Out, CCOpts, CompileCommandsDirPath,
      /*ShouldUseInMemoryCDB=*/CompileArgsFrom == LSPCompileArgs, Opts);
  constexpr int NoShutdownRequestErrorCode = 1;
  llvm::set_thread_name("clangd.main");
  // Change stdin to binary to not lose \r\n on windows.
  llvm::sys::ChangeStdinToBinary();
  return LSPServer.run(stdin, InputStyle) ? 0 : NoShutdownRequestErrorCode;
}
