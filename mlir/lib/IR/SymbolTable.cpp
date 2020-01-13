//===- SymbolTable.cpp - MLIR Symbol Table Class --------------------------===//
//
// Part of the MLIR Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

#include "mlir/IR/SymbolTable.h"
#include "llvm/ADT/SetVector.h"
#include "llvm/ADT/SmallPtrSet.h"
#include "llvm/ADT/SmallString.h"

using namespace mlir;

/// Return true if the given operation is unknown and may potentially define a
/// symbol table.
static bool isPotentiallyUnknownSymbolTable(Operation *op) {
  return !op->getDialect() && op->getNumRegions() == 1;
}

/// Returns the nearest symbol table from a given operation `from`. Returns
/// nullptr if no valid parent symbol table could be found.
static Operation *getNearestSymbolTable(Operation *from) {
  assert(from && "expected valid operation");
  if (isPotentiallyUnknownSymbolTable(from))
    return nullptr;

  while (!from->hasTrait<OpTrait::SymbolTable>()) {
    from = from->getParentOp();

    // Check that this is a valid op and isn't an unknown symbol table.
    if (!from || isPotentiallyUnknownSymbolTable(from))
      return nullptr;
  }
  return from;
}

/// Returns the string name of the given symbol, or None if this is not a
/// symbol.
static Optional<StringRef> getNameIfSymbol(Operation *symbol) {
  auto nameAttr =
      symbol->getAttrOfType<StringAttr>(SymbolTable::getSymbolAttrName());
  return nameAttr ? nameAttr.getValue() : Optional<StringRef>();
}

/// Computes the nested symbol reference attribute for the symbol 'symbolName'
/// that are usable within the symbol table operations from 'symbol' as far up
/// to the given operation 'within', where 'within' is an ancestor of 'symbol'.
/// Returns success if all references up to 'within' could be computed.
static LogicalResult
collectValidReferencesFor(Operation *symbol, StringRef symbolName,
                          Operation *within,
                          SmallVectorImpl<SymbolRefAttr> &results) {
  assert(within->isAncestor(symbol) && "expected 'within' to be an ancestor");
  MLIRContext *ctx = symbol->getContext();

  auto leafRef = FlatSymbolRefAttr::get(symbolName, ctx);
  results.push_back(leafRef);

  // Early exit for when 'within' is the parent of 'symbol'.
  Operation *symbolTableOp = symbol->getParentOp();
  if (within == symbolTableOp)
    return success();

  // Collect references until 'symbolTableOp' reaches 'within'.
  SmallVector<FlatSymbolRefAttr, 1> nestedRefs(1, leafRef);
  do {
    // Each parent of 'symbol' should define a symbol table.
    if (!symbolTableOp->hasTrait<OpTrait::SymbolTable>())
      return failure();
    // Each parent of 'symbol' should also be a symbol.
    Optional<StringRef> symbolTableName = getNameIfSymbol(symbolTableOp);
    if (!symbolTableName)
      return failure();
    results.push_back(SymbolRefAttr::get(*symbolTableName, nestedRefs, ctx));

    symbolTableOp = symbolTableOp->getParentOp();
    if (symbolTableOp == within)
      break;
    nestedRefs.insert(nestedRefs.begin(),
                      FlatSymbolRefAttr::get(*symbolTableName, ctx));
  } while (true);
  return success();
}

//===----------------------------------------------------------------------===//
// SymbolTable
//===----------------------------------------------------------------------===//

/// Build a symbol table with the symbols within the given operation.
SymbolTable::SymbolTable(Operation *symbolTableOp)
    : symbolTableOp(symbolTableOp) {
  assert(symbolTableOp->hasTrait<OpTrait::SymbolTable>() &&
         "expected operation to have SymbolTable trait");
  assert(symbolTableOp->getNumRegions() == 1 &&
         "expected operation to have a single region");
  assert(has_single_element(symbolTableOp->getRegion(0)) &&
         "expected operation to have a single block");

  for (auto &op : symbolTableOp->getRegion(0).front()) {
    Optional<StringRef> name = getNameIfSymbol(&op);
    if (!name)
      continue;

    auto inserted = symbolTable.insert({*name, &op});
    (void)inserted;
    assert(inserted.second &&
           "expected region to contain uniquely named symbol operations");
  }
}

/// Look up a symbol with the specified name, returning null if no such name
/// exists. Names never include the @ on them.
Operation *SymbolTable::lookup(StringRef name) const {
  return symbolTable.lookup(name);
}

/// Erase the given symbol from the table.
void SymbolTable::erase(Operation *symbol) {
  Optional<StringRef> name = getNameIfSymbol(symbol);
  assert(name && "expected valid 'name' attribute");
  assert(symbol->getParentOp() == symbolTableOp &&
         "expected this operation to be inside of the operation with this "
         "SymbolTable");

  auto it = symbolTable.find(*name);
  if (it != symbolTable.end() && it->second == symbol) {
    symbolTable.erase(it);
    symbol->erase();
  }
}

/// Insert a new symbol into the table and associated operation, and rename it
/// as necessary to avoid collisions.
void SymbolTable::insert(Operation *symbol, Block::iterator insertPt) {
  auto &body = symbolTableOp->getRegion(0).front();
  if (insertPt == Block::iterator() || insertPt == body.end())
    insertPt = Block::iterator(body.getTerminator());

  assert(insertPt->getParentOp() == symbolTableOp &&
         "expected insertPt to be in the associated module operation");

  body.getOperations().insert(insertPt, symbol);

  // Add this symbol to the symbol table, uniquing the name if a conflict is
  // detected.
  StringRef name = getSymbolName(symbol);
  if (symbolTable.insert({name, symbol}).second)
    return;
  // If a conflict was detected, then the symbol will not have been added to
  // the symbol table. Try suffixes until we get to a unique name that works.
  SmallString<128> nameBuffer(name);
  unsigned originalLength = nameBuffer.size();

  // Iteratively try suffixes until we find one that isn't used.
  do {
    nameBuffer.resize(originalLength);
    nameBuffer += '_';
    nameBuffer += std::to_string(uniquingCounter++);
  } while (!symbolTable.insert({nameBuffer, symbol}).second);
  setSymbolName(symbol, nameBuffer);
}

/// Returns true if the given operation defines a symbol.
bool SymbolTable::isSymbol(Operation *op) {
  return op->hasTrait<OpTrait::Symbol>() || getNameIfSymbol(op).hasValue();
}

/// Returns the name of the given symbol operation.
StringRef SymbolTable::getSymbolName(Operation *symbol) {
  Optional<StringRef> name = getNameIfSymbol(symbol);
  assert(name && "expected valid symbol name");
  return *name;
}
/// Sets the name of the given symbol operation.
void SymbolTable::setSymbolName(Operation *symbol, StringRef name) {
  symbol->setAttr(getSymbolAttrName(),
                  StringAttr::get(name, symbol->getContext()));
}

/// Returns the operation registered with the given symbol name with the
/// regions of 'symbolTableOp'. 'symbolTableOp' is required to be an operation
/// with the 'OpTrait::SymbolTable' trait. Returns nullptr if no valid symbol
/// was found.
Operation *SymbolTable::lookupSymbolIn(Operation *symbolTableOp,
                                       StringRef symbol) {
  assert(symbolTableOp->hasTrait<OpTrait::SymbolTable>());

  // Look for a symbol with the given name.
  for (auto &block : symbolTableOp->getRegion(0)) {
    for (auto &op : block)
      if (getNameIfSymbol(&op) == symbol)
        return &op;
  }
  return nullptr;
}
Operation *SymbolTable::lookupSymbolIn(Operation *symbolTableOp,
                                       SymbolRefAttr symbol) {
  assert(symbolTableOp->hasTrait<OpTrait::SymbolTable>());

  // Lookup the root reference for this symbol.
  symbolTableOp = lookupSymbolIn(symbolTableOp, symbol.getRootReference());
  if (!symbolTableOp)
    return nullptr;

  // If there are no nested references, just return the root symbol directly.
  ArrayRef<FlatSymbolRefAttr> nestedRefs = symbol.getNestedReferences();
  if (nestedRefs.empty())
    return symbolTableOp;

  // Verify that the root is also a symbol table.
  if (!symbolTableOp->hasTrait<OpTrait::SymbolTable>())
    return nullptr;

  // Otherwise, lookup each of the nested non-leaf references and ensure that
  // each corresponds to a valid symbol table.
  for (FlatSymbolRefAttr ref : nestedRefs.drop_back()) {
    symbolTableOp = lookupSymbolIn(symbolTableOp, ref.getValue());
    if (!symbolTableOp || !symbolTableOp->hasTrait<OpTrait::SymbolTable>())
      return nullptr;
  }
  return lookupSymbolIn(symbolTableOp, symbol.getLeafReference());
}

/// Returns the operation registered with the given symbol name within the
/// closes parent operation with the 'OpTrait::SymbolTable' trait. Returns
/// nullptr if no valid symbol was found.
Operation *SymbolTable::lookupNearestSymbolFrom(Operation *from,
                                                StringRef symbol) {
  Operation *symbolTableOp = getNearestSymbolTable(from);
  return symbolTableOp ? lookupSymbolIn(symbolTableOp, symbol) : nullptr;
}
Operation *SymbolTable::lookupNearestSymbolFrom(Operation *from,
                                                SymbolRefAttr symbol) {
  Operation *symbolTableOp = getNearestSymbolTable(from);
  return symbolTableOp ? lookupSymbolIn(symbolTableOp, symbol) : nullptr;
}

//===----------------------------------------------------------------------===//
// SymbolTable Trait Types
//===----------------------------------------------------------------------===//

LogicalResult OpTrait::impl::verifySymbolTable(Operation *op) {
  if (op->getNumRegions() != 1)
    return op->emitOpError()
           << "Operations with a 'SymbolTable' must have exactly one region";
  if (!has_single_element(op->getRegion(0)))
    return op->emitOpError()
           << "Operations with a 'SymbolTable' must have exactly one block";

  // Check that all symbols are uniquely named within child regions.
  DenseMap<Attribute, Location> nameToOrigLoc;
  for (auto &block : op->getRegion(0)) {
    for (auto &op : block) {
      // Check for a symbol name attribute.
      auto nameAttr =
          op.getAttrOfType<StringAttr>(mlir::SymbolTable::getSymbolAttrName());
      if (!nameAttr)
        continue;

      // Try to insert this symbol into the table.
      auto it = nameToOrigLoc.try_emplace(nameAttr, op.getLoc());
      if (!it.second)
        return op.emitError()
            .append("redefinition of symbol named '", nameAttr.getValue(), "'")
            .attachNote(it.first->second)
            .append("see existing symbol definition here");
    }
  }
  return success();
}

LogicalResult OpTrait::impl::verifySymbol(Operation *op) {
  if (!op->getAttrOfType<StringAttr>(mlir::SymbolTable::getSymbolAttrName()))
    return op->emitOpError() << "requires string attribute '"
                             << mlir::SymbolTable::getSymbolAttrName() << "'";
  return success();
}

//===----------------------------------------------------------------------===//
// Symbol Use Lists
//===----------------------------------------------------------------------===//

/// Walk all of the symbol references within the given operation, invoking the
/// provided callback for each found use. The callbacks takes as arguments: the
/// use of the symbol, and the nested access chain to the attribute within the
/// operation dictionary. An access chain is a set of indices into nested
/// container attributes. For example, a symbol use in an attribute dictionary
/// that looks like the following:
///
///    {use = [{other_attr, @symbol}]}
///
/// May have the following access chain:
///
///     [0, 0, 1]
///
static WalkResult walkSymbolRefs(
    Operation *op,
    function_ref<WalkResult(SymbolTable::SymbolUse, ArrayRef<int>)> callback) {
  // Check to see if the operation has any attributes.
  DictionaryAttr attrDict = op->getAttrList().getDictionary();
  if (!attrDict)
    return WalkResult::advance();

  // A worklist of a container attribute and the current index into the held
  // attribute list.
  SmallVector<Attribute, 1> attrWorklist(1, attrDict);
  SmallVector<int, 1> curAccessChain(1, /*Value=*/-1);

  // Process the symbol references within the given nested attribute range.
  auto processAttrs = [&](int &index, auto attrRange) -> WalkResult {
    for (Attribute attr : llvm::drop_begin(attrRange, index)) {
      /// Check for a nested container attribute, these will also need to be
      /// walked.
      if (attr.isa<ArrayAttr>() || attr.isa<DictionaryAttr>()) {
        attrWorklist.push_back(attr);
        curAccessChain.push_back(-1);
        return WalkResult::advance();
      }

      // Invoke the provided callback if we find a symbol use and check for a
      // requested interrupt.
      if (auto symbolRef = attr.dyn_cast<SymbolRefAttr>())
        if (callback({op, symbolRef}, curAccessChain).wasInterrupted())
          return WalkResult::interrupt();

      // Make sure to keep the index counter in sync.
      ++index;
    }

    // Pop this container attribute from the worklist.
    attrWorklist.pop_back();
    curAccessChain.pop_back();
    return WalkResult::advance();
  };

  WalkResult result = WalkResult::advance();
  do {
    Attribute attr = attrWorklist.back();
    int &index = curAccessChain.back();
    ++index;

    // Process the given attribute, which is guaranteed to be a container.
    if (auto dict = attr.dyn_cast<DictionaryAttr>())
      result = processAttrs(index, make_second_range(dict.getValue()));
    else
      result = processAttrs(index, attr.cast<ArrayAttr>().getValue());
  } while (!attrWorklist.empty() && !result.wasInterrupted());
  return result;
}

/// Walk all of the uses, for any symbol, that are nested within the given
/// operation 'from', invoking the provided callback for each. This does not
/// traverse into any nested symbol tables, and will also only return uses on
/// 'from' if it does not also define a symbol table.
static Optional<WalkResult> walkSymbolUses(
    Operation *from,
    function_ref<WalkResult(SymbolTable::SymbolUse, ArrayRef<int>)> callback) {
  // If from is not a symbol table, check for uses. A symbol table defines a new
  // scope, so we can't walk the attributes from the symbol table op.
  if (!from->hasTrait<OpTrait::SymbolTable>()) {
    if (walkSymbolRefs(from, callback).wasInterrupted())
      return WalkResult::interrupt();
  }

  SmallVector<Region *, 1> worklist;
  worklist.reserve(from->getNumRegions());
  for (Region &region : from->getRegions())
    worklist.push_back(&region);

  while (!worklist.empty()) {
    Region *region = worklist.pop_back_val();
    for (Block &block : *region) {
      for (Operation &op : block) {
        if (walkSymbolRefs(&op, callback).wasInterrupted())
          return WalkResult::interrupt();

        // If this operation has regions, and it as well as its dialect aren't
        // registered then conservatively fail. The operation may define a
        // symbol table, so we can't opaquely know if we should traverse to find
        // nested uses.
        if (isPotentiallyUnknownSymbolTable(&op))
          return llvm::None;

        // If this op defines a new symbol table scope, we can't traverse. Any
        // symbol references nested within 'op' are different semantically.
        if (!op.hasTrait<OpTrait::SymbolTable>()) {
          for (Region &region : op.getRegions())
            worklist.push_back(&region);
        }
      }
    }
  }
  return WalkResult::advance();
}

/// Walks all of the symbol scopes from 'symbol' to (inclusive) 'limit' invoking
/// the provided callback at each one with a properly scoped reference to
/// 'symbol'. The callback takes as parameters the symbol reference at the
/// current scope as well as the top-level operation representing the top of
/// that scope.
static Optional<WalkResult> walkSymbolScopes(
    Operation *symbol, Operation *limit,
    function_ref<Optional<WalkResult>(SymbolRefAttr, Operation *)> callback) {
  StringRef symbolName = SymbolTable::getSymbolName(symbol);
  assert(!symbol->hasTrait<OpTrait::SymbolTable>() || symbol != limit);

  // Compute the ancestors of 'limit'.
  llvm::SetVector<Operation *, SmallVector<Operation *, 4>,
                  SmallPtrSet<Operation *, 4>>
      limitAncestors;
  Operation *limitAncestor = limit;
  do {
    // Check to see if 'symbol' is an ancestor of 'limit'.
    if (limitAncestor == symbol) {
      // Check that the nearest symbol table is 'symbol's parent. SymbolRefAttr
      // doesn't support parent references.
      if (getNearestSymbolTable(limit) != symbol->getParentOp())
        return WalkResult::advance();
      return callback(SymbolRefAttr::get(symbolName, symbol->getContext()),
                      limit);
    }

    limitAncestors.insert(limitAncestor);
  } while ((limitAncestor = limitAncestor->getParentOp()));

  // Try to find the first ancestor of 'symbol' that is an ancestor of 'limit'.
  Operation *commonAncestor = symbol->getParentOp();
  do {
    if (limitAncestors.count(commonAncestor))
      break;
  } while ((commonAncestor = commonAncestor->getParentOp()));
  assert(commonAncestor && "'limit' and 'symbol' have no common ancestor");

  // Compute the set of valid nested references for 'symbol' as far up to the
  // common ancestor as possible.
  SmallVector<SymbolRefAttr, 2> references;
  bool collectedAllReferences = succeeded(collectValidReferencesFor(
      symbol, symbolName, commonAncestor, references));

  // Handle the case where the common ancestor is 'limit'.
  if (commonAncestor == limit) {
    // Walk each of the ancestors of 'symbol', calling the compute function for
    // each one.
    Operation *limitIt = symbol->getParentOp();
    for (size_t i = 0, e = references.size(); i != e;
         ++i, limitIt = limitIt->getParentOp()) {
      Optional<WalkResult> callbackResult = callback(references[i], limitIt);
      if (callbackResult != WalkResult::advance())
        return callbackResult;
    }
    return WalkResult::advance();
  }

  // Otherwise, we just need the symbol reference for 'symbol' that will be
  // used within 'limit'. This is the last reference in the list we computed
  // above if we were able to collect all references.
  if (!collectedAllReferences)
    return WalkResult::advance();
  return callback(references.back(), limit);
}

/// Walk the symbol scopes defined by 'limit' invoking the provided callback.
static Optional<WalkResult> walkSymbolScopes(
    StringRef symbol, Operation *limit,
    function_ref<Optional<WalkResult>(SymbolRefAttr, Operation *)> callback) {
  return callback(SymbolRefAttr::get(symbol, limit->getContext()), limit);
}

/// Returns true if the given reference 'SubRef' is a sub reference of the
/// reference 'ref', i.e. 'ref' is a further qualified reference.
static bool isReferencePrefixOf(SymbolRefAttr subRef, SymbolRefAttr ref) {
  if (ref == subRef)
    return true;

  // If the references are not pointer equal, check to see if `subRef` is a
  // prefix of `ref`.
  if (ref.isa<FlatSymbolRefAttr>() ||
      ref.getRootReference() != subRef.getRootReference())
    return false;

  auto refLeafs = ref.getNestedReferences();
  auto subRefLeafs = subRef.getNestedReferences();
  return subRefLeafs.size() < refLeafs.size() &&
         subRefLeafs == refLeafs.take_front(subRefLeafs.size());
}

//===----------------------------------------------------------------------===//
// SymbolTable::getSymbolUses

/// Get an iterator range for all of the uses, for any symbol, that are nested
/// within the given operation 'from'. This does not traverse into any nested
/// symbol tables, and will also only return uses on 'from' if it does not
/// also define a symbol table. This is because we treat the region as the
/// boundary of the symbol table, and not the op itself. This function returns
/// None if there are any unknown operations that may potentially be symbol
/// tables.
auto SymbolTable::getSymbolUses(Operation *from) -> Optional<UseRange> {
  std::vector<SymbolUse> uses;
  auto walkFn = [&](SymbolUse symbolUse, ArrayRef<int>) {
    uses.push_back(symbolUse);
    return WalkResult::advance();
  };
  auto result = walkSymbolUses(from, walkFn);
  return result ? Optional<UseRange>(std::move(uses)) : Optional<UseRange>();
}

//===----------------------------------------------------------------------===//
// SymbolTable::getSymbolUses

/// The implementation of SymbolTable::getSymbolUses below.
template <typename SymbolT>
static Optional<SymbolTable::UseRange> getSymbolUsesImpl(SymbolT symbol,
                                                         Operation *limit) {
  std::vector<SymbolTable::SymbolUse> uses;
  auto walkFn = [&](SymbolRefAttr symbolRefAttr, Operation *from) {
    return walkSymbolUses(
        from, [&](SymbolTable::SymbolUse symbolUse, ArrayRef<int>) {
          if (isReferencePrefixOf(symbolRefAttr, symbolUse.getSymbolRef()))
            uses.push_back(symbolUse);
          return WalkResult::advance();
        });
  };
  if (walkSymbolScopes(symbol, limit, walkFn))
    return SymbolTable::UseRange(std::move(uses));
  return llvm::None;
}

/// Get all of the uses of the given symbol that are nested within the given
/// operation 'from', invoking the provided callback for each. This does not
/// traverse into any nested symbol tables, and will also only return uses on
/// 'from' if it does not also define a symbol table. This is because we treat
/// the region as the boundary of the symbol table, and not the op itself. This
/// function returns None if there are any unknown operations that may
/// potentially be symbol tables.
auto SymbolTable::getSymbolUses(StringRef symbol, Operation *from)
    -> Optional<UseRange> {
  return getSymbolUsesImpl(symbol, from);
}
auto SymbolTable::getSymbolUses(Operation *symbol, Operation *from)
    -> Optional<UseRange> {
  return getSymbolUsesImpl(symbol, from);
}

//===----------------------------------------------------------------------===//
// SymbolTable::symbolKnownUseEmpty

/// The implementation of SymbolTable::symbolKnownUseEmpty below.
template <typename SymbolT>
static bool symbolKnownUseEmptyImpl(SymbolT symbol, Operation *limit) {
  // Walk all of the symbol uses looking for a reference to 'symbol'.
  auto walkFn = [&](SymbolRefAttr symbolRefAttr, Operation *from) {
    return walkSymbolUses(
        from, [&](SymbolTable::SymbolUse symbolUse, ArrayRef<int>) {
          return isReferencePrefixOf(symbolRefAttr, symbolUse.getSymbolRef())
                     ? WalkResult::interrupt()
                     : WalkResult::advance();
        });
  };
  return walkSymbolScopes(symbol, limit, walkFn) == WalkResult::advance();
}

/// Return if the given symbol is known to have no uses that are nested within
/// the given operation 'from'. This does not traverse into any nested symbol
/// tables, and will also only count uses on 'from' if it does not also define
/// a symbol table. This is because we treat the region as the boundary of the
/// symbol table, and not the op itself. This function will also return false if
/// there are any unknown operations that may potentially be symbol tables.
bool SymbolTable::symbolKnownUseEmpty(StringRef symbol, Operation *from) {
  return symbolKnownUseEmptyImpl(symbol, from);
}
bool SymbolTable::symbolKnownUseEmpty(Operation *symbol, Operation *from) {
  return symbolKnownUseEmptyImpl(symbol, from);
}

//===----------------------------------------------------------------------===//
// SymbolTable::replaceAllSymbolUses

/// Rebuild the given attribute container after replacing all references to a
/// symbol with the updated attribute in 'accesses'.
static Attribute rebuildAttrAfterRAUW(
    Attribute container,
    ArrayRef<std::pair<SmallVector<int, 1>, SymbolRefAttr>> accesses,
    unsigned depth) {
  // Given a range of Attributes, update the ones referred to by the given
  // access chains to point to the new symbol attribute.
  auto updateAttrs = [&](auto &&attrRange) {
    auto attrBegin = std::begin(attrRange);
    for (unsigned i = 0, e = accesses.size(); i != e;) {
      ArrayRef<int> access = accesses[i].first;
      Attribute &attr = *std::next(attrBegin, access[depth]);

      // Check to see if this is a leaf access, i.e. a SymbolRef.
      if (access.size() == depth + 1) {
        attr = accesses[i].second;
        ++i;
        continue;
      }

      // Otherwise, this is a container. Collect all of the accesses for this
      // index and recurse. The recursion here is bounded by the size of the
      // largest access array.
      auto nestedAccesses = accesses.drop_front(i).take_while([&](auto &it) {
        ArrayRef<int> nextAccess = it.first;
        return nextAccess.size() > depth + 1 &&
               nextAccess[depth] == access[depth];
      });
      attr = rebuildAttrAfterRAUW(attr, nestedAccesses, depth + 1);

      // Skip over all of the accesses that refer to the nested container.
      i += nestedAccesses.size();
    }
  };

  if (auto dictAttr = container.dyn_cast<DictionaryAttr>()) {
    auto newAttrs = llvm::to_vector<4>(dictAttr.getValue());
    updateAttrs(make_second_range(newAttrs));
    return DictionaryAttr::get(newAttrs, dictAttr.getContext());
  }
  auto newAttrs = llvm::to_vector<4>(container.cast<ArrayAttr>().getValue());
  updateAttrs(newAttrs);
  return ArrayAttr::get(newAttrs, container.getContext());
}

/// Generates a new symbol reference attribute with a new leaf reference.
SymbolRefAttr generateNewRefAttr(SymbolRefAttr oldAttr,
                                 FlatSymbolRefAttr newLeafAttr) {
  if (oldAttr.isa<FlatSymbolRefAttr>())
    return newLeafAttr;
  auto nestedRefs = llvm::to_vector<2>(oldAttr.getNestedReferences());
  nestedRefs.back() = newLeafAttr;
  return SymbolRefAttr::get(oldAttr.getRootReference(), nestedRefs,
                            oldAttr.getContext());
}

/// The implementation of SymbolTable::replaceAllSymbolUses below.
template <typename SymbolT>
static LogicalResult replaceAllSymbolUsesImpl(SymbolT symbol,
                                              StringRef newSymbol,
                                              Operation *limit) {
  // A collection of operations along with their new attribute dictionary.
  std::vector<std::pair<Operation *, DictionaryAttr>> updatedAttrDicts;

  // The current operation being processed.
  Operation *curOp = nullptr;

  // The set of access chains into the attribute dictionary of the current
  // operation, as well as the replacement attribute to use.
  SmallVector<std::pair<SmallVector<int, 1>, SymbolRefAttr>, 1> accessChains;

  // Generate a new attribute dictionary for the current operation by replacing
  // references to the old symbol.
  auto generateNewAttrDict = [&] {
    auto oldDict = curOp->getAttrList().getDictionary();
    auto newDict = rebuildAttrAfterRAUW(oldDict, accessChains, /*depth=*/0);
    return newDict.cast<DictionaryAttr>();
  };

  // Generate a new attribute to replace the given attribute.
  MLIRContext *ctx = limit->getContext();
  FlatSymbolRefAttr newLeafAttr = FlatSymbolRefAttr::get(newSymbol, ctx);
  auto scopeWalkFn = [&](SymbolRefAttr oldAttr,
                         Operation *from) -> Optional<WalkResult> {
    SymbolRefAttr newAttr = generateNewRefAttr(oldAttr, newLeafAttr);
    auto walkFn = [&](SymbolTable::SymbolUse symbolUse,
                      ArrayRef<int> accessChain) {
      SymbolRefAttr useRef = symbolUse.getSymbolRef();
      if (!isReferencePrefixOf(oldAttr, useRef))
        return WalkResult::advance();

      // If we have a valid match, check to see if this is a proper
      // subreference. If it is, then we will need to generate a different new
      // attribute specifically for this use.
      SymbolRefAttr replacementRef = newAttr;
      if (useRef != oldAttr) {
        if (oldAttr.isa<FlatSymbolRefAttr>()) {
          replacementRef =
              SymbolRefAttr::get(newSymbol, useRef.getNestedReferences(), ctx);
        } else {
          auto nestedRefs = llvm::to_vector<4>(useRef.getNestedReferences());
          nestedRefs[oldAttr.getNestedReferences().size() - 1] = newLeafAttr;
          replacementRef =
              SymbolRefAttr::get(useRef.getRootReference(), nestedRefs, ctx);
        }
      }

      // If there was a previous operation, generate a new attribute dict
      // for it. This means that we've finished processing the current
      // operation, so generate a new dictionary for it.
      if (curOp && symbolUse.getUser() != curOp) {
        updatedAttrDicts.push_back({curOp, generateNewAttrDict()});
        accessChains.clear();
      }

      // Record this access.
      curOp = symbolUse.getUser();
      accessChains.push_back({llvm::to_vector<1>(accessChain), replacementRef});
      return WalkResult::advance();
    };
    if (!walkSymbolUses(from, walkFn))
      return llvm::None;

    // Check to see if we have a dangling op that needs to be processed.
    if (curOp) {
      updatedAttrDicts.push_back({curOp, generateNewAttrDict()});
      curOp = nullptr;
    }
    return WalkResult::advance();
  };
  if (!walkSymbolScopes(symbol, limit, scopeWalkFn))
    return failure();

  // Update the attribute dictionaries as necessary.
  for (auto &it : updatedAttrDicts)
    it.first->setAttrs(it.second);
  return success();
}

/// Attempt to replace all uses of the given symbol 'oldSymbol' with the
/// provided symbol 'newSymbol' that are nested within the given operation
/// 'from'. This does not traverse into any nested symbol tables, and will
/// also only replace uses on 'from' if it does not also define a symbol
/// table. This is because we treat the region as the boundary of the symbol
/// table, and not the op itself. If there are any unknown operations that may
/// potentially be symbol tables, no uses are replaced and failure is returned.
LogicalResult SymbolTable::replaceAllSymbolUses(StringRef oldSymbol,
                                                StringRef newSymbol,
                                                Operation *from) {
  return replaceAllSymbolUsesImpl(oldSymbol, newSymbol, from);
}
LogicalResult SymbolTable::replaceAllSymbolUses(Operation *oldSymbol,
                                                StringRef newSymbol,
                                                Operation *from) {
  return replaceAllSymbolUsesImpl(oldSymbol, newSymbol, from);
}
