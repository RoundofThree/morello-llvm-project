//===-- NativeProcessELF.cpp ----------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "NativeProcessELF.h"

#include "lldb/Utility/DataExtractor.h"

namespace lldb_private {

llvm::Optional<uint64_t>
NativeProcessELF::GetAuxValue(enum AuxVector::EntryType type) {
  if (m_aux_vector == nullptr) {
    auto buffer_or_error = GetAuxvData();
    if (!buffer_or_error)
      return llvm::None;
    DataExtractor auxv_data(buffer_or_error.get()->getBufferStart(),
                            buffer_or_error.get()->getBufferSize(),
                            GetByteOrder(), GetAddressByteSize());
    m_aux_vector = std::make_unique<AuxVector>(auxv_data);
  }

  return m_aux_vector->GetAuxValue(type);
}

lldb::addr_t NativeProcessELF::GetSharedLibraryInfoAddress() {
  if (!m_shared_library_info_addr.hasValue()) {
    if (GetAddressByteSize() == 8)
      m_shared_library_info_addr =
          GetELFImageInfoAddress<llvm::ELF::Elf64_Ehdr, llvm::ELF::Elf64_Phdr,
                                 llvm::ELF::Elf64_Dyn>();
    else
      m_shared_library_info_addr =
          GetELFImageInfoAddress<llvm::ELF::Elf32_Ehdr, llvm::ELF::Elf32_Phdr,
                                 llvm::ELF::Elf32_Dyn>();
  }

  return m_shared_library_info_addr.getValue();
}

template <typename ELF_EHDR, typename ELF_PHDR, typename ELF_DYN>
lldb::addr_t NativeProcessELF::GetELFImageInfoAddress() {
  llvm::Optional<uint64_t> maybe_phdr_addr =
      GetAuxValue(AuxVector::AUXV_AT_PHDR);
  llvm::Optional<uint64_t> maybe_phdr_entry_size =
      GetAuxValue(AuxVector::AUXV_AT_PHENT);
  llvm::Optional<uint64_t> maybe_phdr_num_entries =
      GetAuxValue(AuxVector::AUXV_AT_PHNUM);
  if (!maybe_phdr_addr || !maybe_phdr_entry_size || !maybe_phdr_num_entries)
    return LLDB_INVALID_ADDRESS;
  lldb::addr_t phdr_addr = *maybe_phdr_addr;
  size_t phdr_entry_size = *maybe_phdr_entry_size;
  size_t phdr_num_entries = *maybe_phdr_num_entries;

  // Find the PT_DYNAMIC segment (.dynamic section) in the program header and
  // what the load bias by calculating the difference of the program header
  // load address and its virtual address.
  lldb::offset_t load_bias;
  bool found_load_bias = false;
  lldb::addr_t dynamic_section_addr = 0;
  uint64_t dynamic_section_size = 0;
  bool found_dynamic_section = false;
  ELF_PHDR phdr_entry;
  for (size_t i = 0; i < phdr_num_entries; i++) {
    size_t bytes_read;
    auto error = ReadMemory(phdr_addr + i * phdr_entry_size, &phdr_entry,
                            sizeof(phdr_entry), bytes_read);
    if (!error.Success())
      return LLDB_INVALID_ADDRESS;
    if (phdr_entry.p_type == llvm::ELF::PT_PHDR) {
      load_bias = phdr_addr - phdr_entry.p_vaddr;
      found_load_bias = true;
    }

    if (phdr_entry.p_type == llvm::ELF::PT_DYNAMIC) {
      dynamic_section_addr = phdr_entry.p_vaddr;
      dynamic_section_size = phdr_entry.p_memsz;
      found_dynamic_section = true;
    }
  }

  if (!found_load_bias || !found_dynamic_section)
    return LLDB_INVALID_ADDRESS;

  // Find the DT_DEBUG entry in the .dynamic section
  dynamic_section_addr += load_bias;
  ELF_DYN dynamic_entry;
  size_t dynamic_num_entries = dynamic_section_size / sizeof(dynamic_entry);
  for (size_t i = 0; i < dynamic_num_entries; i++) {
    size_t bytes_read;
    auto error = ReadMemory(dynamic_section_addr + i * sizeof(dynamic_entry),
                            &dynamic_entry, sizeof(dynamic_entry), bytes_read);
    if (!error.Success())
      return LLDB_INVALID_ADDRESS;
    // Return the &DT_DEBUG->d_ptr which points to r_debug which contains the
    // link_map.
    if (dynamic_entry.d_tag == llvm::ELF::DT_DEBUG) {
      return dynamic_section_addr + i * sizeof(dynamic_entry) +
             sizeof(dynamic_entry.d_tag);
    }
  }

  return LLDB_INVALID_ADDRESS;
}

template lldb::addr_t NativeProcessELF::GetELFImageInfoAddress<
    llvm::ELF::Elf32_Ehdr, llvm::ELF::Elf32_Phdr, llvm::ELF::Elf32_Dyn>();
template lldb::addr_t NativeProcessELF::GetELFImageInfoAddress<
    llvm::ELF::Elf64_Ehdr, llvm::ELF::Elf64_Phdr, llvm::ELF::Elf64_Dyn>();

template <typename T>
llvm::Expected<SVR4LibraryInfo>
NativeProcessELF::ReadSVR4LibraryInfo(lldb::addr_t link_map_addr) {
  ELFLinkMap<T> link_map;
  size_t bytes_read;
  auto error =
      ReadMemory(link_map_addr, &link_map, sizeof(link_map), bytes_read);
  if (!error.Success())
    return error.ToError();

  char name_buffer[PATH_MAX];
  llvm::Expected<llvm::StringRef> string_or_error = ReadCStringFromMemory(
      link_map.l_name, &name_buffer[0], sizeof(name_buffer), bytes_read);
  if (!string_or_error)
    return string_or_error.takeError();

  SVR4LibraryInfo info;
  info.name = string_or_error->str();
  info.link_map = link_map_addr;
  info.base_addr = link_map.l_addr;
  info.ld_addr = link_map.l_ld;
  info.next = link_map.l_next;

  return info;
}

template <>
llvm::Expected<SVR4LibraryInfo>
NativeProcessELF::ReadSVR4LibraryInfo<uint64_t[2]>(lldb::addr_t link_map_addr) {
  Log *log(lldb_private::GetLogIfAnyCategoriesSet(LIBLLDB_LOG_TARGET | LIBLLDB_LOG_PROCESS | LIBLLDB_LOG_PLATFORM));
  LLDB_LOGF(log, "Trying to read from link map at %" PRIx64, link_map_addr);

  ELFLinkMap<uint64_t[2]> link_map;
  size_t bytes_read;
  auto error =
      ReadMemory(link_map_addr, &link_map, sizeof(link_map), bytes_read);
  if (!error.Success())
    return error.ToError();

  LLDB_LOGF(log, "Reading name from %" PRIx64, GetAddressFromCapability(link_map.l_name));
  char name_buffer[PATH_MAX];
  llvm::Expected<llvm::StringRef> string_or_error = ReadCStringFromMemory(
      GetAddressFromCapability(link_map.l_name), &name_buffer[0], sizeof(name_buffer), bytes_read);
  if (!string_or_error)
    return string_or_error.takeError();

  SVR4LibraryInfo info;
  info.name = string_or_error->str();
  info.link_map = link_map_addr;
  info.base_addr = GetAddressFromCapability(link_map.l_addr);
  info.ld_addr = GetAddressFromCapability(link_map.l_ld);
  info.next = GetAddressFromCapability(link_map.l_next);

  return info;
}

lldb::addr_t NativeProcessELF::GetAddressFromCapability(uint64_t capability[2]) {
  bool is_big_endian = GetArchitecture().GetCapabilityByteOrder() == lldb::eByteOrderBig;
  return is_big_endian ? capability[1] : capability[0];
}

llvm::Expected<std::vector<SVR4LibraryInfo>>
NativeProcessELF::GetLoadedSVR4Libraries() {
  // Address of DT_DEBUG.d_ptr which points to r_debug
  lldb::addr_t info_address = GetSharedLibraryInfoAddress();
  if (info_address == LLDB_INVALID_ADDRESS)
    return llvm::createStringError(llvm::inconvertibleErrorCode(),
                                   "Invalid shared library info address");
  // Address of r_debug
  lldb::addr_t address = 0;
  size_t bytes_read;
  auto status =
      ReadMemory(info_address, &address, GetAddressByteSize(), bytes_read);
  if (!status.Success())
    return status.ToError();
  if (address == 0)
    return llvm::createStringError(llvm::inconvertibleErrorCode(),
                                   "Invalid r_debug address");
  // Read r_debug.r_map
  lldb::addr_t link_map = 0;
  uint64_t link_map_pointer[2];
  size_t pointer_size = GetPointerByteSize();
  status = ReadMemory(address + pointer_size, &link_map_pointer,
                      pointer_size, bytes_read);
  if (!status.Success())
    return status.ToError();
  link_map = GetAddressFromCapability(link_map_pointer);
  if (address == 0)
    return llvm::createStringError(llvm::inconvertibleErrorCode(),
                                   "Invalid link_map address");

  std::vector<SVR4LibraryInfo> library_list;
  size_t address_size = GetAddressByteSize();
  while (link_map) {
    llvm::Expected<SVR4LibraryInfo> info =
      pointer_size != address_size ? ReadSVR4LibraryInfo<uint64_t[2]>(link_map) :
        GetAddressByteSize() == 8 ? ReadSVR4LibraryInfo<uint64_t>(link_map)
                                  : ReadSVR4LibraryInfo<uint32_t>(link_map);
    if (!info)
      return info.takeError();
    if (!info->name.empty() && info->base_addr != 0)
      library_list.push_back(*info);
    link_map = info->next;
  }

  return library_list;
}

} // namespace lldb_private
