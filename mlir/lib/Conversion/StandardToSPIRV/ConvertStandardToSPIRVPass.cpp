//===- ConvertStandardToSPIRVPass.cpp - Convert Std Ops to SPIR-V Ops -----===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//
//
// This file implements a pass to convert MLIR standard ops into the SPIR-V
// ops.
//
//===----------------------------------------------------------------------===//

#include "mlir/Conversion/StandardToSPIRV/ConvertStandardToSPIRVPass.h"
#include "mlir/Conversion/StandardToSPIRV/ConvertStandardToSPIRV.h"
#include "mlir/Dialect/SPIRV/SPIRVDialect.h"
#include "mlir/Dialect/SPIRV/SPIRVLowering.h"
#include "mlir/Pass/Pass.h"

using namespace mlir;

namespace {
/// A pass converting MLIR Standard operations into the SPIR-V dialect.
class ConvertStandardToSPIRVPass
    : public PassWrapper<ConvertStandardToSPIRVPass, OperationPass<ModuleOp>> {
/// Include the generated pass utilities.
#define GEN_PASS_ConvertStandardToSPIRV
#include "mlir/Conversion/Passes.h.inc"

  void runOnOperation() override;
};
} // namespace

void ConvertStandardToSPIRVPass::runOnOperation() {
  MLIRContext *context = &getContext();
  ModuleOp module = getOperation();

  auto targetAttr = spirv::lookupTargetEnvOrDefault(module);
  std::unique_ptr<ConversionTarget> target =
      spirv::SPIRVConversionTarget::get(targetAttr);

  SPIRVTypeConverter typeConverter(targetAttr);
  OwningRewritePatternList patterns;
  populateStandardToSPIRVPatterns(context, typeConverter, patterns);
  populateBuiltinFuncToSPIRVPatterns(context, typeConverter, patterns);

  if (failed(applyPartialConversion(module, *target, patterns))) {
    return signalPassFailure();
  }
}

std::unique_ptr<OperationPass<ModuleOp>>
mlir::createConvertStandardToSPIRVPass() {
  return std::make_unique<ConvertStandardToSPIRVPass>();
}
