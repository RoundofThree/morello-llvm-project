//===- TargetAndABI.h - SPIR-V target and ABI utilities  --------*- C++ -*-===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file declares utilities for SPIR-V target and shader interface ABI.
//
//===----------------------------------------------------------------------===//

#ifndef MLIR_DIALECT_SPIRV_TARGETANDABI_H
#define MLIR_DIALECT_SPIRV_TARGETANDABI_H

#include "mlir/Dialect/SPIRV/SPIRVAttributes.h"
#include "mlir/Support/LLVM.h"
#include "llvm/ADT/SmallSet.h"

namespace mlir {
class Operation;

namespace spirv {
enum class StorageClass : uint32_t;

/// A wrapper class around a spirv::TargetEnvAttr to provide query methods for
/// allowed version/capabilities/extensions.
class TargetEnv {
public:
  explicit TargetEnv(TargetEnvAttr targetAttr);

  Version getVersion();

  /// Returns true if the given capability is allowed.
  bool allows(Capability) const;
  /// Returns the first allowed one if any of the given capabilities is allowed.
  /// Returns llvm::None otherwise.
  Optional<Capability> allows(ArrayRef<Capability>) const;

  /// Returns true if the given extension is allowed.
  bool allows(Extension) const;
  /// Returns the first allowed one if any of the given extensions is allowed.
  /// Returns llvm::None otherwise.
  Optional<Extension> allows(ArrayRef<Extension>) const;

  /// Returns the MLIRContext.
  MLIRContext *getContext();

  /// Allows implicity converting to the underlying spirv::TargetEnvAttr.
  operator TargetEnvAttr() const { return targetAttr; }

private:
  TargetEnvAttr targetAttr;
  llvm::SmallSet<Extension, 4> givenExtensions;    /// Allowed extensions
  llvm::SmallSet<Capability, 8> givenCapabilities; /// Allowed capabilities
};

/// Returns the attribute name for specifying argument ABI information.
StringRef getInterfaceVarABIAttrName();

/// Gets the InterfaceVarABIAttr given its fields.
InterfaceVarABIAttr getInterfaceVarABIAttr(unsigned descriptorSet,
                                           unsigned binding,
                                           Optional<StorageClass> storageClass,
                                           MLIRContext *context);

/// Returns the attribute name for specifying entry point information.
StringRef getEntryPointABIAttrName();

/// Gets the EntryPointABIAttr given its fields.
EntryPointABIAttr getEntryPointABIAttr(ArrayRef<int32_t> localSize,
                                       MLIRContext *context);

/// Queries the entry point ABI on the nearest function-like op containing the
/// given `op`. Returns null attribute if not found.
EntryPointABIAttr lookupEntryPointABI(Operation *op);

/// Queries the local workgroup size from entry point ABI on the nearest
/// function-like op containing the given `op`. Returns null attribute if not
/// found.
DenseIntElementsAttr lookupLocalWorkGroupSize(Operation *op);

/// Returns a default resource limits attribute that uses numbers from
/// "Table 46. Required Limits" of the Vulkan spec.
ResourceLimitsAttr getDefaultResourceLimits(MLIRContext *context);

/// Returns the attribute name for specifying SPIR-V target environment.
StringRef getTargetEnvAttrName();

/// Returns the default target environment: SPIR-V 1.0 with Shader capability
/// and no extra extensions.
TargetEnvAttr getDefaultTargetEnv(MLIRContext *context);

/// Queries the target environment recursively from enclosing symbol table ops
/// containing the given `op`.
TargetEnvAttr lookupTargetEnv(Operation *op);

/// Queries the target environment recursively from enclosing symbol table ops
/// containing the given `op` or returns the default target environment as
/// returned by getDefaultTargetEnv() if not provided.
TargetEnvAttr lookupTargetEnvOrDefault(Operation *op);

} // namespace spirv
} // namespace mlir

#endif // MLIR_DIALECT_SPIRV_TARGETANDABI_H
