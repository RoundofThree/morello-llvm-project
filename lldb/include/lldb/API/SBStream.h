//===-- SBStream.h ----------------------------------------------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#ifndef LLDB_API_SBSTREAM_H
#define LLDB_API_SBSTREAM_H

#include <stdio.h>

#include "lldb/API/SBDefines.h"

namespace lldb {

class LLDB_API SBStream {
public:
  SBStream();

  SBStream(SBStream &&rhs);

  ~SBStream();

  explicit operator bool() const;

  bool IsValid() const;

  // If this stream is not redirected to a file, it will maintain a local cache
  // for the stream data which can be accessed using this accessor.
  const char *GetData();

  // If this stream is not redirected to a file, it will maintain a local cache
  // for the stream output whose length can be accessed using this accessor.
  size_t GetSize();

  void Printf(const char *format, ...) __attribute__((format(printf, 2, 3)));

  void RedirectToFile(const char *path, bool append);

  void RedirectToFile(lldb::SBFile file);

  void RedirectToFile(lldb::FileSP file);

  void RedirectToFileHandle(FILE *fh, bool transfer_fh_ownership);

  void RedirectToFileDescriptor(int fd, bool transfer_fh_ownership);

  // If the stream is redirected to a file, forget about the file and if
  // ownership of the file was transferred to this object, close the file. If
  // the stream is backed by a local cache, clear this cache.
  void Clear();

protected:
  friend class SBAddress;
  friend class SBBlock;
  friend class SBBreakpoint;
  friend class SBBreakpointLocation;
  friend class SBBreakpointName;
  friend class SBCommandReturnObject;
  friend class SBCompileUnit;
  friend class SBData;
  friend class SBDebugger;
  friend class SBDeclaration;
  friend class SBEvent;
  friend class SBFileSpec;
  friend class SBFileSpecList;
  friend class SBFrame;
  friend class SBFunction;
  friend class SBInstruction;
  friend class SBInstructionList;
  friend class SBLineEntry;
  friend class SBMemoryRegionInfo;
  friend class SBModule;
  friend class SBModuleSpec;
  friend class SBModuleSpecList;
  friend class SBProcess;
  friend class SBSection;
  friend class SBSourceManager;
  friend class SBStructuredData;
  friend class SBSymbol;
  friend class SBSymbolContext;
  friend class SBSymbolContextList;
  friend class SBTarget;
  friend class SBThread;
  friend class SBThreadPlan;
  friend class SBType;
  friend class SBTypeEnumMember;
  friend class SBTypeMemberFunction;
  friend class SBTypeMember;
  friend class SBValue;
  friend class SBWatchpoint;

  lldb_private::Stream *operator->();

  lldb_private::Stream *get();

  lldb_private::Stream &ref();

private:
  DISALLOW_COPY_AND_ASSIGN(SBStream);
  std::unique_ptr<lldb_private::Stream> m_opaque_up;
  bool m_is_file;
};

} // namespace lldb

#endif // LLDB_API_SBSTREAM_H
