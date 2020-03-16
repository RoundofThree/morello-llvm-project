//===- TableGen.cpp - Top-Level TableGen implementation for Clang ---------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file contains the main function for Clang's TableGen.
//
//===----------------------------------------------------------------------===//

#include "TableGenBackends.h" // Declares all backends.
#include "ASTTableGen.h"
#include "llvm/Support/CommandLine.h"
#include "llvm/Support/PrettyStackTrace.h"
#include "llvm/Support/Signals.h"
#include "llvm/TableGen/Error.h"
#include "llvm/TableGen/Main.h"
#include "llvm/TableGen/Record.h"

using namespace llvm;
using namespace clang;

enum ActionType {
  PrintRecords,
  DumpJSON,
  GenClangAttrClasses,
  GenClangAttrParserStringSwitches,
  GenClangAttrSubjectMatchRulesParserStringSwitches,
  GenClangAttrImpl,
  GenClangAttrList,
  GenClangAttrSubjectMatchRuleList,
  GenClangAttrPCHRead,
  GenClangAttrPCHWrite,
  GenClangAttrHasAttributeImpl,
  GenClangAttrSpellingListIndex,
  GenClangAttrASTVisitor,
  GenClangAttrTemplateInstantiate,
  GenClangAttrParsedAttrList,
  GenClangAttrParsedAttrImpl,
  GenClangAttrParsedAttrKinds,
  GenClangAttrTextNodeDump,
  GenClangAttrNodeTraverse,
  GenClangBasicReader,
  GenClangBasicWriter,
  GenClangDiagsDefs,
  GenClangDiagGroups,
  GenClangDiagsIndexName,
  GenClangCommentNodes,
  GenClangDeclNodes,
  GenClangStmtNodes,
  GenClangTypeNodes,
  GenClangTypeReader,
  GenClangTypeWriter,
  GenClangOpcodes,
  GenClangSACheckers,
  GenClangCommentHTMLTags,
  GenClangCommentHTMLTagsProperties,
  GenClangCommentHTMLNamedCharacterReferences,
  GenClangCommentCommandInfo,
  GenClangCommentCommandList,
  GenClangOpenCLBuiltins,
  GenArmNeon,
  GenArmFP16,
  GenArmNeonSema,
  GenArmNeonTest,
  GenArmMveHeader,
  GenArmMveBuiltinDef,
  GenArmMveBuiltinSema,
  GenArmMveBuiltinCG,
  GenArmMveBuiltinAliases,
  GenArmSveHeader,
  GenArmSveBuiltins,
  GenArmSveCodeGenMap,
  GenArmCdeHeader,
  GenArmCdeBuiltinDef,
  GenArmCdeBuiltinSema,
  GenArmCdeBuiltinCG,
  GenArmCdeBuiltinAliases,
  GenAttrDocs,
  GenDiagDocs,
  GenOptDocs,
  GenDataCollectors,
  GenTestPragmaAttributeSupportedAttributes
};

namespace {
cl::opt<ActionType> Action(
    cl::desc("Action to perform:"),
    cl::values(
        clEnumValN(PrintRecords, "print-records",
                   "Print all records to stdout (default)"),
        clEnumValN(DumpJSON, "dump-json",
                   "Dump all records as machine-readable JSON"),
        clEnumValN(GenClangAttrClasses, "gen-clang-attr-classes",
                   "Generate clang attribute clases"),
        clEnumValN(GenClangAttrParserStringSwitches,
                   "gen-clang-attr-parser-string-switches",
                   "Generate all parser-related attribute string switches"),
        clEnumValN(GenClangAttrSubjectMatchRulesParserStringSwitches,
                   "gen-clang-attr-subject-match-rules-parser-string-switches",
                   "Generate all parser-related attribute subject match rule"
                   "string switches"),
        clEnumValN(GenClangAttrImpl, "gen-clang-attr-impl",
                   "Generate clang attribute implementations"),
        clEnumValN(GenClangAttrList, "gen-clang-attr-list",
                   "Generate a clang attribute list"),
        clEnumValN(GenClangAttrSubjectMatchRuleList,
                   "gen-clang-attr-subject-match-rule-list",
                   "Generate a clang attribute subject match rule list"),
        clEnumValN(GenClangAttrPCHRead, "gen-clang-attr-pch-read",
                   "Generate clang PCH attribute reader"),
        clEnumValN(GenClangAttrPCHWrite, "gen-clang-attr-pch-write",
                   "Generate clang PCH attribute writer"),
        clEnumValN(GenClangAttrHasAttributeImpl,
                   "gen-clang-attr-has-attribute-impl",
                   "Generate a clang attribute spelling list"),
        clEnumValN(GenClangAttrSpellingListIndex,
                   "gen-clang-attr-spelling-index",
                   "Generate a clang attribute spelling index"),
        clEnumValN(GenClangAttrASTVisitor, "gen-clang-attr-ast-visitor",
                   "Generate a recursive AST visitor for clang attributes"),
        clEnumValN(GenClangAttrTemplateInstantiate,
                   "gen-clang-attr-template-instantiate",
                   "Generate a clang template instantiate code"),
        clEnumValN(GenClangAttrParsedAttrList,
                   "gen-clang-attr-parsed-attr-list",
                   "Generate a clang parsed attribute list"),
        clEnumValN(GenClangAttrParsedAttrImpl,
                   "gen-clang-attr-parsed-attr-impl",
                   "Generate the clang parsed attribute helpers"),
        clEnumValN(GenClangAttrParsedAttrKinds,
                   "gen-clang-attr-parsed-attr-kinds",
                   "Generate a clang parsed attribute kinds"),
        clEnumValN(GenClangAttrTextNodeDump, "gen-clang-attr-text-node-dump",
                   "Generate clang attribute text node dumper"),
        clEnumValN(GenClangAttrNodeTraverse, "gen-clang-attr-node-traverse",
                   "Generate clang attribute traverser"),
        clEnumValN(GenClangDiagsDefs, "gen-clang-diags-defs",
                   "Generate Clang diagnostics definitions"),
        clEnumValN(GenClangDiagGroups, "gen-clang-diag-groups",
                   "Generate Clang diagnostic groups"),
        clEnumValN(GenClangDiagsIndexName, "gen-clang-diags-index-name",
                   "Generate Clang diagnostic name index"),
        clEnumValN(GenClangBasicReader, "gen-clang-basic-reader",
                   "Generate Clang BasicReader classes"),
        clEnumValN(GenClangBasicWriter, "gen-clang-basic-writer",
                   "Generate Clang BasicWriter classes"),
        clEnumValN(GenClangCommentNodes, "gen-clang-comment-nodes",
                   "Generate Clang AST comment nodes"),
        clEnumValN(GenClangDeclNodes, "gen-clang-decl-nodes",
                   "Generate Clang AST declaration nodes"),
        clEnumValN(GenClangStmtNodes, "gen-clang-stmt-nodes",
                   "Generate Clang AST statement nodes"),
        clEnumValN(GenClangTypeNodes, "gen-clang-type-nodes",
                   "Generate Clang AST type nodes"),
        clEnumValN(GenClangTypeReader, "gen-clang-type-reader",
                   "Generate Clang AbstractTypeReader class"),
        clEnumValN(GenClangTypeWriter, "gen-clang-type-writer",
                   "Generate Clang AbstractTypeWriter class"),
        clEnumValN(GenClangOpcodes, "gen-clang-opcodes",
                   "Generate Clang constexpr interpreter opcodes"),
        clEnumValN(GenClangSACheckers, "gen-clang-sa-checkers",
                   "Generate Clang Static Analyzer checkers"),
        clEnumValN(GenClangCommentHTMLTags, "gen-clang-comment-html-tags",
                   "Generate efficient matchers for HTML tag "
                   "names that are used in documentation comments"),
        clEnumValN(GenClangCommentHTMLTagsProperties,
                   "gen-clang-comment-html-tags-properties",
                   "Generate efficient matchers for HTML tag "
                   "properties"),
        clEnumValN(GenClangCommentHTMLNamedCharacterReferences,
                   "gen-clang-comment-html-named-character-references",
                   "Generate function to translate named character "
                   "references to UTF-8 sequences"),
        clEnumValN(GenClangCommentCommandInfo, "gen-clang-comment-command-info",
                   "Generate command properties for commands that "
                   "are used in documentation comments"),
        clEnumValN(GenClangCommentCommandList, "gen-clang-comment-command-list",
                   "Generate list of commands that are used in "
                   "documentation comments"),
        clEnumValN(GenClangOpenCLBuiltins, "gen-clang-opencl-builtins",
                   "Generate OpenCL builtin declaration handlers"),
        clEnumValN(GenArmNeon, "gen-arm-neon", "Generate arm_neon.h for clang"),
        clEnumValN(GenArmFP16, "gen-arm-fp16", "Generate arm_fp16.h for clang"),
        clEnumValN(GenArmNeonSema, "gen-arm-neon-sema",
                   "Generate ARM NEON sema support for clang"),
        clEnumValN(GenArmNeonTest, "gen-arm-neon-test",
                   "Generate ARM NEON tests for clang"),
        clEnumValN(GenArmSveHeader, "gen-arm-sve-header",
                   "Generate arm_sve.h for clang"),
        clEnumValN(GenArmSveBuiltins, "gen-arm-sve-builtins",
                   "Generate arm_sve_builtins.inc for clang"),
        clEnumValN(GenArmSveCodeGenMap, "gen-arm-sve-codegenmap",
                   "Generate arm_sve_codegenmap.inc for clang"),
        clEnumValN(GenArmMveHeader, "gen-arm-mve-header",
                   "Generate arm_mve.h for clang"),
        clEnumValN(GenArmMveBuiltinDef, "gen-arm-mve-builtin-def",
                   "Generate ARM MVE builtin definitions for clang"),
        clEnumValN(GenArmMveBuiltinSema, "gen-arm-mve-builtin-sema",
                   "Generate ARM MVE builtin sema checks for clang"),
        clEnumValN(GenArmMveBuiltinCG, "gen-arm-mve-builtin-codegen",
                   "Generate ARM MVE builtin code-generator for clang"),
        clEnumValN(GenArmMveBuiltinAliases, "gen-arm-mve-builtin-aliases",
                   "Generate list of valid ARM MVE builtin aliases for clang"),
        clEnumValN(GenArmCdeHeader, "gen-arm-cde-header",
                   "Generate arm_cde.h for clang"),
        clEnumValN(GenArmCdeBuiltinDef, "gen-arm-cde-builtin-def",
                   "Generate ARM CDE builtin definitions for clang"),
        clEnumValN(GenArmCdeBuiltinSema, "gen-arm-cde-builtin-sema",
                   "Generate ARM CDE builtin sema checks for clang"),
        clEnumValN(GenArmCdeBuiltinCG, "gen-arm-cde-builtin-codegen",
                   "Generate ARM CDE builtin code-generator for clang"),
        clEnumValN(GenArmCdeBuiltinAliases, "gen-arm-cde-builtin-aliases",
                   "Generate list of valid ARM CDE builtin aliases for clang"),
        clEnumValN(GenAttrDocs, "gen-attr-docs",
                   "Generate attribute documentation"),
        clEnumValN(GenDiagDocs, "gen-diag-docs",
                   "Generate diagnostic documentation"),
        clEnumValN(GenOptDocs, "gen-opt-docs", "Generate option documentation"),
        clEnumValN(GenDataCollectors, "gen-clang-data-collectors",
                   "Generate data collectors for AST nodes"),
        clEnumValN(GenTestPragmaAttributeSupportedAttributes,
                   "gen-clang-test-pragma-attribute-supported-attributes",
                   "Generate a list of attributes supported by #pragma clang "
                   "attribute for testing purposes")));

cl::opt<std::string>
ClangComponent("clang-component",
               cl::desc("Only use warnings from specified component"),
               cl::value_desc("component"), cl::Hidden);

bool ClangTableGenMain(raw_ostream &OS, RecordKeeper &Records) {
  switch (Action) {
  case PrintRecords:
    OS << Records;           // No argument, dump all contents
    break;
  case DumpJSON:
    EmitJSON(Records, OS);
    break;
  case GenClangAttrClasses:
    EmitClangAttrClass(Records, OS);
    break;
  case GenClangAttrParserStringSwitches:
    EmitClangAttrParserStringSwitches(Records, OS);
    break;
  case GenClangAttrSubjectMatchRulesParserStringSwitches:
    EmitClangAttrSubjectMatchRulesParserStringSwitches(Records, OS);
    break;
  case GenClangAttrImpl:
    EmitClangAttrImpl(Records, OS);
    break;
  case GenClangAttrList:
    EmitClangAttrList(Records, OS);
    break;
  case GenClangAttrSubjectMatchRuleList:
    EmitClangAttrSubjectMatchRuleList(Records, OS);
    break;
  case GenClangAttrPCHRead:
    EmitClangAttrPCHRead(Records, OS);
    break;
  case GenClangAttrPCHWrite:
    EmitClangAttrPCHWrite(Records, OS);
    break;
  case GenClangAttrHasAttributeImpl:
    EmitClangAttrHasAttrImpl(Records, OS);
    break;
  case GenClangAttrSpellingListIndex:
    EmitClangAttrSpellingListIndex(Records, OS);
    break;
  case GenClangAttrASTVisitor:
    EmitClangAttrASTVisitor(Records, OS);
    break;
  case GenClangAttrTemplateInstantiate:
    EmitClangAttrTemplateInstantiate(Records, OS);
    break;
  case GenClangAttrParsedAttrList:
    EmitClangAttrParsedAttrList(Records, OS);
    break;
  case GenClangAttrParsedAttrImpl:
    EmitClangAttrParsedAttrImpl(Records, OS);
    break;
  case GenClangAttrParsedAttrKinds:
    EmitClangAttrParsedAttrKinds(Records, OS);
    break;
  case GenClangAttrTextNodeDump:
    EmitClangAttrTextNodeDump(Records, OS);
    break;
  case GenClangAttrNodeTraverse:
    EmitClangAttrNodeTraverse(Records, OS);
    break;
  case GenClangDiagsDefs:
    EmitClangDiagsDefs(Records, OS, ClangComponent);
    break;
  case GenClangDiagGroups:
    EmitClangDiagGroups(Records, OS);
    break;
  case GenClangDiagsIndexName:
    EmitClangDiagsIndexName(Records, OS);
    break;
  case GenClangCommentNodes:
    EmitClangASTNodes(Records, OS, CommentNodeClassName, "");
    break;
  case GenClangDeclNodes:
    EmitClangASTNodes(Records, OS, DeclNodeClassName, "Decl");
    EmitClangDeclContext(Records, OS);
    break;
  case GenClangStmtNodes:
    EmitClangASTNodes(Records, OS, StmtNodeClassName, "");
    break;
  case GenClangTypeNodes:
    EmitClangTypeNodes(Records, OS);
    break;
  case GenClangTypeReader:
    EmitClangTypeReader(Records, OS);
    break;
  case GenClangTypeWriter:
    EmitClangTypeWriter(Records, OS);
    break;
  case GenClangBasicReader:
    EmitClangBasicReader(Records, OS);
    break;
  case GenClangBasicWriter:
    EmitClangBasicWriter(Records, OS);
    break;
  case GenClangOpcodes:
    EmitClangOpcodes(Records, OS);
    break;
  case GenClangSACheckers:
    EmitClangSACheckers(Records, OS);
    break;
  case GenClangCommentHTMLTags:
    EmitClangCommentHTMLTags(Records, OS);
    break;
  case GenClangCommentHTMLTagsProperties:
    EmitClangCommentHTMLTagsProperties(Records, OS);
    break;
  case GenClangCommentHTMLNamedCharacterReferences:
    EmitClangCommentHTMLNamedCharacterReferences(Records, OS);
    break;
  case GenClangCommentCommandInfo:
    EmitClangCommentCommandInfo(Records, OS);
    break;
  case GenClangCommentCommandList:
    EmitClangCommentCommandList(Records, OS);
    break;
  case GenClangOpenCLBuiltins:
    EmitClangOpenCLBuiltins(Records, OS);
    break;
  case GenArmNeon:
    EmitNeon(Records, OS);
    break;
  case GenArmFP16:
    EmitFP16(Records, OS);
    break;
  case GenArmNeonSema:
    EmitNeonSema(Records, OS);
    break;
  case GenArmNeonTest:
    EmitNeonTest(Records, OS);
    break;
  case GenArmMveHeader:
    EmitMveHeader(Records, OS);
    break;
  case GenArmMveBuiltinDef:
    EmitMveBuiltinDef(Records, OS);
    break;
  case GenArmMveBuiltinSema:
    EmitMveBuiltinSema(Records, OS);
    break;
  case GenArmMveBuiltinCG:
    EmitMveBuiltinCG(Records, OS);
    break;
  case GenArmMveBuiltinAliases:
    EmitMveBuiltinAliases(Records, OS);
    break;
  case GenArmSveHeader:
    EmitSveHeader(Records, OS);
    break;
  case GenArmSveBuiltins:
    EmitSveBuiltins(Records, OS);
    break;
  case GenArmSveCodeGenMap:
    EmitSveCodeGenMap(Records, OS);
    break;
  case GenArmCdeHeader:
    EmitCdeHeader(Records, OS);
    break;
  case GenArmCdeBuiltinDef:
    EmitCdeBuiltinDef(Records, OS);
    break;
  case GenArmCdeBuiltinSema:
    EmitCdeBuiltinSema(Records, OS);
    break;
  case GenArmCdeBuiltinCG:
    EmitCdeBuiltinCG(Records, OS);
    break;
  case GenArmCdeBuiltinAliases:
    EmitCdeBuiltinAliases(Records, OS);
    break;
  case GenAttrDocs:
    EmitClangAttrDocs(Records, OS);
    break;
  case GenDiagDocs:
    EmitClangDiagDocs(Records, OS);
    break;
  case GenOptDocs:
    EmitClangOptDocs(Records, OS);
    break;
  case GenDataCollectors:
    EmitClangDataCollectors(Records, OS);
    break;
  case GenTestPragmaAttributeSupportedAttributes:
    EmitTestPragmaAttributeSupportedAttributes(Records, OS);
    break;
  }

  return false;
}
}

int main(int argc, char **argv) {
  sys::PrintStackTraceOnErrorSignal(argv[0]);
  PrettyStackTraceProgram X(argc, argv);
  cl::ParseCommandLineOptions(argc, argv);

  llvm_shutdown_obj Y;

  return TableGenMain(argv[0], &ClangTableGenMain);
}

#ifdef __has_feature
#if __has_feature(address_sanitizer)
#include <sanitizer/lsan_interface.h>
// Disable LeakSanitizer for this binary as it has too many leaks that are not
// very interesting to fix. See compiler-rt/include/sanitizer/lsan_interface.h .
int __lsan_is_turned_off() { return 1; }
#endif  // __has_feature(address_sanitizer)
#endif  // defined(__has_feature)
