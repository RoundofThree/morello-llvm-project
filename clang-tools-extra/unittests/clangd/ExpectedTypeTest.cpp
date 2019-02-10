//===-- ExpectedTypeTest.cpp  -----------------------------------*- C++ -*-===//
//
//                     The LLVM Compiler Infrastructure
//
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ClangdUnit.h"
#include "ExpectedTypes.h"
#include "TestTU.h"
#include "clang/AST/ASTContext.h"
#include "clang/AST/Decl.h"
#include "llvm/ADT/StringRef.h"
#include "gmock/gmock-matchers.h"
#include "gmock/gmock.h"
#include "gtest/gtest.h"

using namespace llvm;

namespace clang {
namespace clangd {
namespace {

using ::testing::Field;
using ::testing::Matcher;
using ::testing::SizeIs;
using ::testing::UnorderedElementsAreArray;

class ExpectedTypeConversionTest : public ::testing::Test {
protected:
  void build(StringRef Code) {
    assert(!AST && "AST built twice");
    AST = TestTU::withCode(Code).build();
  }

  const ValueDecl *decl(StringRef Name) {
    return &cast<ValueDecl>(findDecl(*AST, Name));
  }

  QualType typeOf(StringRef Name) {
    return decl(Name)->getType().getCanonicalType();
  }

  /// An overload for convenience.
  Optional<OpaqueType> fromCompletionResult(const ValueDecl *D) {
    return OpaqueType::fromCompletionResult(
        ASTCtx(), CodeCompletionResult(D, CCP_Declaration));
  }

  /// A set of DeclNames whose type match each other computed by
  /// OpaqueType::fromCompletionResult.
  using EquivClass = std::set<std::string>;

  Matcher<std::map<std::string, EquivClass>>
  ClassesAre(ArrayRef<EquivClass> Classes) {
    using MapEntry = std::map<std::string, EquivClass>::value_type;

    std::vector<Matcher<MapEntry>> Elements;
    Elements.reserve(Classes.size());
    for (auto &Cls : Classes)
      Elements.push_back(Field(&MapEntry::second, Cls));
    return UnorderedElementsAreArray(Elements);
  }

  // Groups \p Decls into equivalence classes based on the result of
  // 'OpaqueType::fromCompletionResult'.
  std::map<std::string, EquivClass>
  buildEquivClasses(ArrayRef<StringRef> DeclNames) {
    std::map<std::string, EquivClass> Classes;
    for (StringRef Name : DeclNames) {
      auto Type = OpaqueType::fromType(ASTCtx(), typeOf(Name));
      Classes[Type->raw()].insert(Name);
    }
    return Classes;
  }

  ASTContext &ASTCtx() { return AST->getASTContext(); }

private:
  // Set after calling build().
  Optional<ParsedAST> AST;
};

TEST_F(ExpectedTypeConversionTest, BasicTypes) {
  build(R"cpp(
    // ints.
    bool b;
    int i;
    unsigned int ui;
    long long ll;

    // floats.
    float f;
    double d;

    // pointers
    int* iptr;
    bool* bptr;

    // user-defined types.
    struct X {};
    X user_type;
  )cpp");

  EXPECT_THAT(buildEquivClasses({"b", "i", "ui", "ll", "f", "d", "iptr", "bptr",
                                 "user_type"}),
              ClassesAre({{"b"},
                          {"i", "ui", "ll"},
                          {"f", "d"},
                          {"iptr"},
                          {"bptr"},
                          {"user_type"}}));
}

TEST_F(ExpectedTypeConversionTest, ReferencesDontMatter) {
  build(R"cpp(
    int noref;
    int & ref = noref;
    const int & const_ref = noref;
    int && rv_ref = 10;
  )cpp");

  EXPECT_THAT(buildEquivClasses({"noref", "ref", "const_ref", "rv_ref"}),
              SizeIs(1));
}

TEST_F(ExpectedTypeConversionTest, ArraysDecay) {
  build(R"cpp(
     int arr[2];
     int (&arr_ref)[2] = arr;
     int *ptr;
  )cpp");

  EXPECT_THAT(buildEquivClasses({"arr", "arr_ref", "ptr"}), SizeIs(1));
}

TEST_F(ExpectedTypeConversionTest, FunctionReturns) {
  build(R"cpp(
     int returns_int();
     int* returns_ptr();

     int int_;
     int* int_ptr;
  )cpp");

  OpaqueType IntTy = *OpaqueType::fromType(ASTCtx(), typeOf("int_"));
  EXPECT_EQ(fromCompletionResult(decl("returns_int")), IntTy);

  OpaqueType IntPtrTy = *OpaqueType::fromType(ASTCtx(), typeOf("int_ptr"));
  EXPECT_EQ(fromCompletionResult(decl("returns_ptr")), IntPtrTy);
}

} // namespace
} // namespace clangd
} // namespace clang
