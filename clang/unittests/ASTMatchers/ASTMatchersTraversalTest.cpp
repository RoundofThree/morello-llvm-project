//= unittests/ASTMatchers/ASTMatchersTraversalTest.cpp - matchers unit tests =//
//
//                     The LLVM Compiler Infrastructure
//`
// This file is distributed under the University of Illinois Open Source
// License. See LICENSE.TXT for details.
//
//===----------------------------------------------------------------------===//

#include "ASTMatchersTest.h"
#include "clang/AST/PrettyPrinter.h"
#include "clang/ASTMatchers/ASTMatchFinder.h"
#include "clang/ASTMatchers/ASTMatchers.h"
#include "clang/Tooling/Tooling.h"
#include "llvm/ADT/Triple.h"
#include "llvm/Support/Host.h"
#include "gtest/gtest.h"

namespace clang {
namespace ast_matchers {

TEST(DeclarationMatcher, hasMethod) {
  EXPECT_TRUE(matches("class A { void func(); };",
                      cxxRecordDecl(hasMethod(hasName("func")))));
  EXPECT_TRUE(notMatches("class A { void func(); };",
                         cxxRecordDecl(hasMethod(isPublic()))));
}

TEST(DeclarationMatcher, ClassDerivedFromDependentTemplateSpecialization) {
  EXPECT_TRUE(matches(
    "template <typename T> struct A {"
      "  template <typename T2> struct F {};"
      "};"
      "template <typename T> struct B : A<T>::template F<T> {};"
      "B<int> b;",
    cxxRecordDecl(hasName("B"), isDerivedFrom(recordDecl()))));
}

TEST(DeclarationMatcher, hasDeclContext) {
  EXPECT_TRUE(matches(
    "namespace N {"
      "  namespace M {"
      "    class D {};"
      "  }"
      "}",
    recordDecl(hasDeclContext(namespaceDecl(hasName("M"))))));
  EXPECT_TRUE(notMatches(
    "namespace N {"
      "  namespace M {"
      "    class D {};"
      "  }"
      "}",
    recordDecl(hasDeclContext(namespaceDecl(hasName("N"))))));

  EXPECT_TRUE(matches("namespace {"
                        "  namespace M {"
                        "    class D {};"
                        "  }"
                        "}",
                      recordDecl(hasDeclContext(namespaceDecl(
                        hasName("M"), hasDeclContext(namespaceDecl()))))));

  EXPECT_TRUE(matches("class D{};", decl(hasDeclContext(decl()))));
}

TEST(HasDescendant, MatchesDescendantTypes) {
  EXPECT_TRUE(matches("void f() { int i = 3; }",
                      decl(hasDescendant(loc(builtinType())))));
  EXPECT_TRUE(matches("void f() { int i = 3; }",
                      stmt(hasDescendant(builtinType()))));

  EXPECT_TRUE(matches("void f() { int i = 3; }",
                      stmt(hasDescendant(loc(builtinType())))));
  EXPECT_TRUE(matches("void f() { int i = 3; }",
                      stmt(hasDescendant(qualType(builtinType())))));

  EXPECT_TRUE(notMatches("void f() { float f = 2.0f; }",
                         stmt(hasDescendant(isInteger()))));

  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void f() { int a; float c; int d; int e; }",
    functionDecl(forEachDescendant(
      varDecl(hasDescendant(isInteger())).bind("x"))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 3)));
}

TEST(HasDescendant, MatchesDescendantsOfTypes) {
  EXPECT_TRUE(matches("void f() { int*** i; }",
                      qualType(hasDescendant(builtinType()))));
  EXPECT_TRUE(matches("void f() { int*** i; }",
                      qualType(hasDescendant(
                        pointerType(pointee(builtinType()))))));
  EXPECT_TRUE(matches("void f() { int*** i; }",
                      typeLoc(hasDescendant(loc(builtinType())))));

  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void f() { int*** i; }",
    qualType(asString("int ***"), forEachDescendant(pointerType().bind("x"))),
    llvm::make_unique<VerifyIdIsBoundTo<Type>>("x", 2)));
}


TEST(Has, MatchesChildrenOfTypes) {
  EXPECT_TRUE(matches("int i;",
                      varDecl(hasName("i"), has(isInteger()))));
  EXPECT_TRUE(notMatches("int** i;",
                         varDecl(hasName("i"), has(isInteger()))));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "int (*f)(float, int);",
    qualType(functionType(), forEach(qualType(isInteger()).bind("x"))),
    llvm::make_unique<VerifyIdIsBoundTo<QualType>>("x", 2)));
}

TEST(Has, MatchesChildTypes) {
  EXPECT_TRUE(matches(
    "int* i;",
    varDecl(hasName("i"), hasType(qualType(has(builtinType()))))));
  EXPECT_TRUE(notMatches(
    "int* i;",
    varDecl(hasName("i"), hasType(qualType(has(pointerType()))))));
}

TEST(StatementMatcher, Has) {
  StatementMatcher HasVariableI =
      expr(hasType(pointsTo(recordDecl(hasName("X")))),
           has(ignoringParenImpCasts(declRefExpr(to(varDecl(hasName("i")))))));

  EXPECT_TRUE(matches(
    "class X; X *x(int); void c() { int i; x(i); }", HasVariableI));
  EXPECT_TRUE(notMatches(
    "class X; X *x(int); void c() { int i; x(42); }", HasVariableI));
}

TEST(StatementMatcher, HasDescendant) {
  StatementMatcher HasDescendantVariableI =
    expr(hasType(pointsTo(recordDecl(hasName("X")))),
         hasDescendant(declRefExpr(to(varDecl(hasName("i"))))));

  EXPECT_TRUE(matches(
    "class X; X *x(bool); bool b(int); void c() { int i; x(b(i)); }",
    HasDescendantVariableI));
  EXPECT_TRUE(notMatches(
    "class X; X *x(bool); bool b(int); void c() { int i; x(b(42)); }",
    HasDescendantVariableI));
}

TEST(TypeMatcher, MatchesClassType) {
  TypeMatcher TypeA = hasDeclaration(recordDecl(hasName("A")));

  EXPECT_TRUE(matches("class A { public: A *a; };", TypeA));
  EXPECT_TRUE(notMatches("class A {};", TypeA));

  TypeMatcher TypeDerivedFromA =
    hasDeclaration(cxxRecordDecl(isDerivedFrom("A")));

  EXPECT_TRUE(matches("class A {}; class B : public A { public: B *b; };",
                      TypeDerivedFromA));
  EXPECT_TRUE(notMatches("class A {};", TypeA));

  TypeMatcher TypeAHasClassB = hasDeclaration(
    recordDecl(hasName("A"), has(recordDecl(hasName("B")))));

  EXPECT_TRUE(
    matches("class A { public: A *a; class B {}; };", TypeAHasClassB));

  EXPECT_TRUE(matchesC("struct S {}; void f(void) { struct S s; }",
                       varDecl(hasType(namedDecl(hasName("S"))))));
}

TEST(TypeMatcher, MatchesDeclTypes) {
  // TypedefType -> TypedefNameDecl
  EXPECT_TRUE(matches("typedef int I; void f(I i);",
                      parmVarDecl(hasType(namedDecl(hasName("I"))))));
  // ObjCObjectPointerType
  EXPECT_TRUE(matchesObjC("@interface Foo @end void f(Foo *f);",
                          parmVarDecl(hasType(objcObjectPointerType()))));
  // ObjCObjectPointerType -> ObjCInterfaceType -> ObjCInterfaceDecl
  EXPECT_TRUE(matchesObjC(
    "@interface Foo @end void f(Foo *f);",
    parmVarDecl(hasType(pointsTo(objcInterfaceDecl(hasName("Foo")))))));
  // TemplateTypeParmType
  EXPECT_TRUE(matches("template <typename T> void f(T t);",
                      parmVarDecl(hasType(templateTypeParmType()))));
  // TemplateTypeParmType -> TemplateTypeParmDecl
  EXPECT_TRUE(matches("template <typename T> void f(T t);",
                      parmVarDecl(hasType(namedDecl(hasName("T"))))));
  // InjectedClassNameType
  EXPECT_TRUE(matches("template <typename T> struct S {"
                        "  void f(S s);"
                        "};",
                      parmVarDecl(hasType(injectedClassNameType()))));
  EXPECT_TRUE(notMatches("template <typename T> struct S {"
                           "  void g(S<T> s);"
                           "};",
                         parmVarDecl(hasType(injectedClassNameType()))));
  // InjectedClassNameType -> CXXRecordDecl
  EXPECT_TRUE(matches("template <typename T> struct S {"
                        "  void f(S s);"
                        "};",
                      parmVarDecl(hasType(namedDecl(hasName("S"))))));

  static const char Using[] = "template <typename T>"
    "struct Base {"
    "  typedef T Foo;"
    "};"
    ""
    "template <typename T>"
    "struct S : private Base<T> {"
    "  using typename Base<T>::Foo;"
    "  void f(Foo);"
    "};";
  // UnresolvedUsingTypenameDecl
  EXPECT_TRUE(matches(Using, unresolvedUsingTypenameDecl(hasName("Foo"))));
  // UnresolvedUsingTypenameType -> UnresolvedUsingTypenameDecl
  EXPECT_TRUE(matches(Using, parmVarDecl(hasType(namedDecl(hasName("Foo"))))));
}

TEST(HasDeclaration, HasDeclarationOfEnumType) {
  EXPECT_TRUE(matches("enum X {}; void y(X *x) { x; }",
                      expr(hasType(pointsTo(
                        qualType(hasDeclaration(enumDecl(hasName("X")))))))));
}

TEST(HasDeclaration, HasGetDeclTraitTest) {
  static_assert(internal::has_getDecl<TypedefType>::value,
                "Expected TypedefType to have a getDecl.");
  static_assert(internal::has_getDecl<RecordType>::value,
                "Expected RecordType to have a getDecl.");
  static_assert(!internal::has_getDecl<TemplateSpecializationType>::value,
                "Expected TemplateSpecializationType to *not* have a getDecl.");
}

TEST(HasDeclaration, ElaboratedType) {
  EXPECT_TRUE(matches(
      "namespace n { template <typename T> struct X {}; }"
      "void f(n::X<int>);",
      parmVarDecl(hasType(qualType(hasDeclaration(cxxRecordDecl()))))));
  EXPECT_TRUE(matches(
      "namespace n { template <typename T> struct X {}; }"
      "void f(n::X<int>);",
      parmVarDecl(hasType(elaboratedType(hasDeclaration(cxxRecordDecl()))))));
}

TEST(HasDeclaration, HasDeclarationOfTypeWithDecl) {
  EXPECT_TRUE(matches("typedef int X; X a;",
                      varDecl(hasName("a"),
                              hasType(typedefType(hasDeclaration(decl()))))));

  // FIXME: Add tests for other types with getDecl() (e.g. RecordType)
}

TEST(HasDeclaration, HasDeclarationOfTemplateSpecializationType) {
  EXPECT_TRUE(matches("template <typename T> class A {}; A<int> a;",
                      varDecl(hasType(templateSpecializationType(
                        hasDeclaration(namedDecl(hasName("A"))))))));
  EXPECT_TRUE(matches("template <typename T> class A {};"
                      "template <typename T> class B { A<T> a; };",
                      fieldDecl(hasType(templateSpecializationType(
                        hasDeclaration(namedDecl(hasName("A"))))))));
  EXPECT_TRUE(matches("template <typename T> class A {}; A<int> a;",
                      varDecl(hasType(templateSpecializationType(
                          hasDeclaration(cxxRecordDecl()))))));
}

TEST(HasDeclaration, HasDeclarationOfCXXNewExpr) {
  EXPECT_TRUE(
      matches("int *A = new int();",
              cxxNewExpr(hasDeclaration(functionDecl(parameterCountIs(1))))));
}

TEST(HasDeclaration, HasDeclarationOfTypeAlias) {
  EXPECT_TRUE(matches("template <typename T> using C = T; C<int> c;",
                      varDecl(hasType(templateSpecializationType(
                          hasDeclaration(typeAliasTemplateDecl()))))));
}

TEST(HasUnqualifiedDesugaredType, DesugarsUsing) {
  EXPECT_TRUE(
      matches("struct A {}; using B = A; B b;",
              varDecl(hasType(hasUnqualifiedDesugaredType(recordType())))));
  EXPECT_TRUE(
      matches("struct A {}; using B = A; using C = B; C b;",
              varDecl(hasType(hasUnqualifiedDesugaredType(recordType())))));
}

TEST(HasUnderlyingDecl, Matches) {
  EXPECT_TRUE(matches("namespace N { template <class T> void f(T t); }"
                      "template <class T> void g() { using N::f; f(T()); }",
                      unresolvedLookupExpr(hasAnyDeclaration(
                          namedDecl(hasUnderlyingDecl(hasName("::N::f")))))));
  EXPECT_TRUE(matches(
      "namespace N { template <class T> void f(T t); }"
      "template <class T> void g() { N::f(T()); }",
      unresolvedLookupExpr(hasAnyDeclaration(namedDecl(hasName("::N::f"))))));
  EXPECT_TRUE(notMatches(
      "namespace N { template <class T> void f(T t); }"
      "template <class T> void g() { using N::f; f(T()); }",
      unresolvedLookupExpr(hasAnyDeclaration(namedDecl(hasName("::N::f"))))));
}

TEST(HasType, TakesQualTypeMatcherAndMatchesExpr) {
  TypeMatcher ClassX = hasDeclaration(recordDecl(hasName("X")));
  EXPECT_TRUE(
    matches("class X {}; void y(X &x) { x; }", expr(hasType(ClassX))));
  EXPECT_TRUE(
    notMatches("class X {}; void y(X *x) { x; }",
               expr(hasType(ClassX))));
  EXPECT_TRUE(
    matches("class X {}; void y(X *x) { x; }",
            expr(hasType(pointsTo(ClassX)))));
}

TEST(HasType, TakesQualTypeMatcherAndMatchesValueDecl) {
  TypeMatcher ClassX = hasDeclaration(recordDecl(hasName("X")));
  EXPECT_TRUE(
    matches("class X {}; void y() { X x; }", varDecl(hasType(ClassX))));
  EXPECT_TRUE(
    notMatches("class X {}; void y() { X *x; }", varDecl(hasType(ClassX))));
  EXPECT_TRUE(
    matches("class X {}; void y() { X *x; }",
            varDecl(hasType(pointsTo(ClassX)))));
}

TEST(HasType, TakesDeclMatcherAndMatchesExpr) {
  DeclarationMatcher ClassX = recordDecl(hasName("X"));
  EXPECT_TRUE(
    matches("class X {}; void y(X &x) { x; }", expr(hasType(ClassX))));
  EXPECT_TRUE(
    notMatches("class X {}; void y(X *x) { x; }",
               expr(hasType(ClassX))));
}

TEST(HasType, TakesDeclMatcherAndMatchesValueDecl) {
  DeclarationMatcher ClassX = recordDecl(hasName("X"));
  EXPECT_TRUE(
    matches("class X {}; void y() { X x; }", varDecl(hasType(ClassX))));
  EXPECT_TRUE(
    notMatches("class X {}; void y() { X *x; }", varDecl(hasType(ClassX))));
}

TEST(HasType, MatchesTypedefDecl) {
  EXPECT_TRUE(matches("typedef int X;", typedefDecl(hasType(asString("int")))));
  EXPECT_TRUE(matches("typedef const int T;",
                      typedefDecl(hasType(asString("const int")))));
  EXPECT_TRUE(notMatches("typedef const int T;",
                         typedefDecl(hasType(asString("int")))));
  EXPECT_TRUE(matches("typedef int foo; typedef foo bar;",
                      typedefDecl(hasType(asString("foo")), hasName("bar"))));
}

TEST(HasType, MatchesTypedefNameDecl) {
  EXPECT_TRUE(matches("using X = int;", typedefNameDecl(hasType(asString("int")))));
  EXPECT_TRUE(matches("using T = const int;",
                      typedefNameDecl(hasType(asString("const int")))));
  EXPECT_TRUE(notMatches("using T = const int;",
                         typedefNameDecl(hasType(asString("int")))));
  EXPECT_TRUE(matches("using foo = int; using bar = foo;",
                      typedefNameDecl(hasType(asString("foo")), hasName("bar"))));
}

TEST(HasTypeLoc, MatchesDeclaratorDecls) {
  EXPECT_TRUE(matches("int x;",
                      varDecl(hasName("x"), hasTypeLoc(loc(asString("int"))))));

  // Make sure we don't crash on implicit constructors.
  EXPECT_TRUE(notMatches("class X {}; X x;",
                         declaratorDecl(hasTypeLoc(loc(asString("int"))))));
}


TEST(Callee, MatchesDeclarations) {
  StatementMatcher CallMethodX = callExpr(callee(cxxMethodDecl(hasName("x"))));

  EXPECT_TRUE(matches("class Y { void x() { x(); } };", CallMethodX));
  EXPECT_TRUE(notMatches("class Y { void x() {} };", CallMethodX));

  CallMethodX = callExpr(callee(cxxConversionDecl()));
  EXPECT_TRUE(
    matches("struct Y { operator int() const; }; int i = Y();", CallMethodX));
  EXPECT_TRUE(notMatches("struct Y { operator int() const; }; Y y = Y();",
                         CallMethodX));
}

TEST(Callee, MatchesMemberExpressions) {
  EXPECT_TRUE(matches("class Y { void x() { this->x(); } };",
                      callExpr(callee(memberExpr()))));
  EXPECT_TRUE(
    notMatches("class Y { void x() { this->x(); } };", callExpr(callee(callExpr()))));
}

TEST(Matcher, Argument) {
  StatementMatcher CallArgumentY = callExpr(
    hasArgument(0, declRefExpr(to(varDecl(hasName("y"))))));

  EXPECT_TRUE(matches("void x(int) { int y; x(y); }", CallArgumentY));
  EXPECT_TRUE(
    matches("class X { void x(int) { int y; x(y); } };", CallArgumentY));
  EXPECT_TRUE(notMatches("void x(int) { int z; x(z); }", CallArgumentY));

  StatementMatcher WrongIndex = callExpr(
    hasArgument(42, declRefExpr(to(varDecl(hasName("y"))))));
  EXPECT_TRUE(notMatches("void x(int) { int y; x(y); }", WrongIndex));
}

TEST(Matcher, AnyArgument) {
  auto HasArgumentY = hasAnyArgument(
      ignoringParenImpCasts(declRefExpr(to(varDecl(hasName("y"))))));
  StatementMatcher CallArgumentY = callExpr(HasArgumentY);
  StatementMatcher ObjCCallArgumentY = objcMessageExpr(HasArgumentY);
  EXPECT_TRUE(matches("void x(int, int) { int y; x(1, y); }", CallArgumentY));
  EXPECT_TRUE(matches("void x(int, int) { int y; x(y, 42); }", CallArgumentY));
  EXPECT_TRUE(matchesObjC("@interface I -(void)f:(int) y; @end "
                          "void x(I* i) { int y; [i f:y]; }",
                          ObjCCallArgumentY));
  EXPECT_FALSE(matchesObjC("@interface I -(void)f:(int) z; @end "
                           "void x(I* i) { int z; [i f:z]; }",
                           ObjCCallArgumentY));
  EXPECT_TRUE(notMatches("void x(int, int) { x(1, 2); }", CallArgumentY));

  StatementMatcher ImplicitCastedArgument = callExpr(
    hasAnyArgument(implicitCastExpr()));
  EXPECT_TRUE(matches("void x(long) { int y; x(y); }", ImplicitCastedArgument));
}

TEST(ForEachArgumentWithParam, ReportsNoFalsePositives) {
  StatementMatcher ArgumentY =
    declRefExpr(to(varDecl(hasName("y")))).bind("arg");
  DeclarationMatcher IntParam = parmVarDecl(hasType(isInteger())).bind("param");
  StatementMatcher CallExpr =
    callExpr(forEachArgumentWithParam(ArgumentY, IntParam));

  // IntParam does not match.
  EXPECT_TRUE(notMatches("void f(int* i) { int* y; f(y); }", CallExpr));
  // ArgumentY does not match.
  EXPECT_TRUE(notMatches("void f(int i) { int x; f(x); }", CallExpr));
}

TEST(ForEachArgumentWithParam, MatchesCXXMemberCallExpr) {
  StatementMatcher ArgumentY =
    declRefExpr(to(varDecl(hasName("y")))).bind("arg");
  DeclarationMatcher IntParam = parmVarDecl(hasType(isInteger())).bind("param");
  StatementMatcher CallExpr =
    callExpr(forEachArgumentWithParam(ArgumentY, IntParam));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "struct S {"
      "  const S& operator[](int i) { return *this; }"
      "};"
      "void f(S S1) {"
      "  int y = 1;"
      "  S1[y];"
      "}",
    CallExpr, llvm::make_unique<VerifyIdIsBoundTo<ParmVarDecl>>("param", 1)));

  StatementMatcher CallExpr2 =
    callExpr(forEachArgumentWithParam(ArgumentY, IntParam));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "struct S {"
      "  static void g(int i);"
      "};"
      "void f() {"
      "  int y = 1;"
      "  S::g(y);"
      "}",
    CallExpr2, llvm::make_unique<VerifyIdIsBoundTo<ParmVarDecl>>("param", 1)));
}

TEST(ForEachArgumentWithParam, MatchesCallExpr) {
  StatementMatcher ArgumentY =
    declRefExpr(to(varDecl(hasName("y")))).bind("arg");
  DeclarationMatcher IntParam = parmVarDecl(hasType(isInteger())).bind("param");
  StatementMatcher CallExpr =
    callExpr(forEachArgumentWithParam(ArgumentY, IntParam));

  EXPECT_TRUE(
    matchAndVerifyResultTrue("void f(int i) { int y; f(y); }", CallExpr,
                             llvm::make_unique<VerifyIdIsBoundTo<ParmVarDecl>>(
                               "param")));
  EXPECT_TRUE(
    matchAndVerifyResultTrue("void f(int i) { int y; f(y); }", CallExpr,
                             llvm::make_unique<VerifyIdIsBoundTo<DeclRefExpr>>(
                               "arg")));

  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void f(int i, int j) { int y; f(y, y); }", CallExpr,
    llvm::make_unique<VerifyIdIsBoundTo<ParmVarDecl>>("param", 2)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void f(int i, int j) { int y; f(y, y); }", CallExpr,
    llvm::make_unique<VerifyIdIsBoundTo<DeclRefExpr>>("arg", 2)));
}

TEST(ForEachArgumentWithParam, MatchesConstructExpr) {
  StatementMatcher ArgumentY =
    declRefExpr(to(varDecl(hasName("y")))).bind("arg");
  DeclarationMatcher IntParam = parmVarDecl(hasType(isInteger())).bind("param");
  StatementMatcher ConstructExpr =
    cxxConstructExpr(forEachArgumentWithParam(ArgumentY, IntParam));

  EXPECT_TRUE(matchAndVerifyResultTrue(
    "struct C {"
      "  C(int i) {}"
      "};"
      "int y = 0;"
      "C Obj(y);",
    ConstructExpr,
    llvm::make_unique<VerifyIdIsBoundTo<ParmVarDecl>>("param")));
}

TEST(ForEachArgumentWithParam, HandlesBoundNodesForNonMatches) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void g(int i, int j) {"
      "  int a;"
      "  int b;"
      "  int c;"
      "  g(a, 0);"
      "  g(a, b);"
      "  g(0, b);"
      "}",
    functionDecl(
      forEachDescendant(varDecl().bind("v")),
      forEachDescendant(callExpr(forEachArgumentWithParam(
        declRefExpr(to(decl(equalsBoundNode("v")))), parmVarDecl())))),
    llvm::make_unique<VerifyIdIsBoundTo<VarDecl>>("v", 4)));
}

TEST(QualType, hasCanonicalType) {
  EXPECT_TRUE(notMatches("typedef int &int_ref;"
                           "int a;"
                           "int_ref b = a;",
                         varDecl(hasType(qualType(referenceType())))));
  EXPECT_TRUE(
    matches("typedef int &int_ref;"
              "int a;"
              "int_ref b = a;",
            varDecl(hasType(qualType(hasCanonicalType(referenceType()))))));
}

TEST(HasParameter, CallsInnerMatcher) {
  EXPECT_TRUE(matches("class X { void x(int) {} };",
                      cxxMethodDecl(hasParameter(0, varDecl()))));
  EXPECT_TRUE(notMatches("class X { void x(int) {} };",
                         cxxMethodDecl(hasParameter(0, hasName("x")))));
}

TEST(HasParameter, DoesNotMatchIfIndexOutOfBounds) {
  EXPECT_TRUE(notMatches("class X { void x(int) {} };",
                         cxxMethodDecl(hasParameter(42, varDecl()))));
}

TEST(HasType, MatchesParameterVariableTypesStrictly) {
  EXPECT_TRUE(matches(
    "class X { void x(X x) {} };",
    cxxMethodDecl(hasParameter(0, hasType(recordDecl(hasName("X")))))));
  EXPECT_TRUE(notMatches(
    "class X { void x(const X &x) {} };",
    cxxMethodDecl(hasParameter(0, hasType(recordDecl(hasName("X")))))));
  EXPECT_TRUE(matches("class X { void x(const X *x) {} };",
                      cxxMethodDecl(hasParameter(
                        0, hasType(pointsTo(recordDecl(hasName("X"))))))));
  EXPECT_TRUE(matches("class X { void x(const X &x) {} };",
                      cxxMethodDecl(hasParameter(
                        0, hasType(references(recordDecl(hasName("X"))))))));
}

TEST(HasAnyParameter, MatchesIndependentlyOfPosition) {
  EXPECT_TRUE(matches(
    "class Y {}; class X { void x(X x, Y y) {} };",
    cxxMethodDecl(hasAnyParameter(hasType(recordDecl(hasName("X")))))));
  EXPECT_TRUE(matches(
    "class Y {}; class X { void x(Y y, X x) {} };",
    cxxMethodDecl(hasAnyParameter(hasType(recordDecl(hasName("X")))))));
}

TEST(Returns, MatchesReturnTypes) {
  EXPECT_TRUE(matches("class Y { int f() { return 1; } };",
                      functionDecl(returns(asString("int")))));
  EXPECT_TRUE(notMatches("class Y { int f() { return 1; } };",
                         functionDecl(returns(asString("float")))));
  EXPECT_TRUE(matches("class Y { Y getMe() { return *this; } };",
                      functionDecl(returns(hasDeclaration(
                        recordDecl(hasName("Y")))))));
}

TEST(HasAnyParameter, DoesntMatchIfInnerMatcherDoesntMatch) {
  EXPECT_TRUE(notMatches(
    "class Y {}; class X { void x(int) {} };",
    cxxMethodDecl(hasAnyParameter(hasType(recordDecl(hasName("X")))))));
}

TEST(HasAnyParameter, DoesNotMatchThisPointer) {
  EXPECT_TRUE(notMatches("class Y {}; class X { void x() {} };",
                         cxxMethodDecl(hasAnyParameter(
                           hasType(pointsTo(recordDecl(hasName("X"))))))));
}

TEST(HasName, MatchesParameterVariableDeclarations) {
  EXPECT_TRUE(matches("class Y {}; class X { void x(int x) {} };",
                      cxxMethodDecl(hasAnyParameter(hasName("x")))));
  EXPECT_TRUE(notMatches("class Y {}; class X { void x(int) {} };",
                         cxxMethodDecl(hasAnyParameter(hasName("x")))));
}

TEST(Matcher, MatchesTypeTemplateArgument) {
  EXPECT_TRUE(matches(
    "template<typename T> struct B {};"
      "B<int> b;",
    classTemplateSpecializationDecl(hasAnyTemplateArgument(refersToType(
      asString("int"))))));
}

TEST(Matcher, MatchesTemplateTemplateArgument) {
  EXPECT_TRUE(matches("template<template <typename> class S> class X {};"
                      "template<typename T> class Y {};"
                      "X<Y> xi;",
                      classTemplateSpecializationDecl(hasAnyTemplateArgument(
                          refersToTemplate(templateName())))));
}

TEST(Matcher, MatchesDeclarationReferenceTemplateArgument) {
  EXPECT_TRUE(matches(
    "struct B { int next; };"
      "template<int(B::*next_ptr)> struct A {};"
      "A<&B::next> a;",
    classTemplateSpecializationDecl(hasAnyTemplateArgument(
      refersToDeclaration(fieldDecl(hasName("next")))))));

  EXPECT_TRUE(notMatches(
    "template <typename T> struct A {};"
      "A<int> a;",
    classTemplateSpecializationDecl(hasAnyTemplateArgument(
      refersToDeclaration(decl())))));

  EXPECT_TRUE(matches(
    "struct B { int next; };"
      "template<int(B::*next_ptr)> struct A {};"
      "A<&B::next> a;",
    templateSpecializationType(hasAnyTemplateArgument(isExpr(
      hasDescendant(declRefExpr(to(fieldDecl(hasName("next"))))))))));

  EXPECT_TRUE(notMatches(
    "template <typename T> struct A {};"
      "A<int> a;",
    templateSpecializationType(hasAnyTemplateArgument(
      refersToDeclaration(decl())))));
}


TEST(Matcher, MatchesSpecificArgument) {
  EXPECT_TRUE(matches(
    "template<typename T, typename U> class A {};"
      "A<bool, int> a;",
    classTemplateSpecializationDecl(hasTemplateArgument(
      1, refersToType(asString("int"))))));
  EXPECT_TRUE(notMatches(
    "template<typename T, typename U> class A {};"
      "A<int, bool> a;",
    classTemplateSpecializationDecl(hasTemplateArgument(
      1, refersToType(asString("int"))))));

  EXPECT_TRUE(matches(
    "template<typename T, typename U> class A {};"
      "A<bool, int> a;",
    templateSpecializationType(hasTemplateArgument(
      1, refersToType(asString("int"))))));
  EXPECT_TRUE(notMatches(
    "template<typename T, typename U> class A {};"
      "A<int, bool> a;",
    templateSpecializationType(hasTemplateArgument(
      1, refersToType(asString("int"))))));

  EXPECT_TRUE(matches(
    "template<typename T> void f() {};"
      "void func() { f<int>(); }",
    functionDecl(hasTemplateArgument(0, refersToType(asString("int"))))));
  EXPECT_TRUE(notMatches(
    "template<typename T> void f() {};",
    functionDecl(hasTemplateArgument(0, refersToType(asString("int"))))));
}

TEST(TemplateArgument, Matches) {
  EXPECT_TRUE(matches("template<typename T> struct C {}; C<int> c;",
                      classTemplateSpecializationDecl(
                        hasAnyTemplateArgument(templateArgument()))));
  EXPECT_TRUE(matches(
    "template<typename T> struct C {}; C<int> c;",
    templateSpecializationType(hasAnyTemplateArgument(templateArgument()))));

  EXPECT_TRUE(matches(
    "template<typename T> void f() {};"
      "void func() { f<int>(); }",
    functionDecl(hasAnyTemplateArgument(templateArgument()))));
}

TEST(TemplateTypeParmDecl, CXXMethodDecl) {
  const char input[] =
      "template<typename T>\n"
      "class Class {\n"
      "  void method();\n"
      "};\n"
      "template<typename U>\n"
      "void Class<U>::method() {}\n";
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U"))));
}

TEST(TemplateTypeParmDecl, VarDecl) {
  const char input[] =
      "template<typename T>\n"
      "class Class {\n"
      "  static T pi;\n"
      "};\n"
      "template<typename U>\n"
      "U Class<U>::pi = U(3.1415926535897932385);\n";
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U"))));
}

TEST(TemplateTypeParmDecl, VarTemplatePartialSpecializationDecl) {
  const char input[] =
      "template<typename T>\n"
      "struct Struct {\n"
      "  template<typename T2> static int field;\n"
      "};\n"
      "template<typename U>\n"
      "template<typename U2>\n"
      "int Struct<U>::field<U2*> = 123;\n";
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T2"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U2"))));
}

TEST(TemplateTypeParmDecl, ClassTemplatePartialSpecializationDecl) {
  const char input[] =
      "template<typename T>\n"
      "class Class {\n"
      "  template<typename T2> struct Struct;\n"
      "};\n"
      "template<typename U>\n"
      "template<typename U2>\n"
      "struct Class<U>::Struct<U2*> {};\n";
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T2"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U2"))));
}

TEST(TemplateTypeParmDecl, EnumDecl) {
  const char input[] =
      "template<typename T>\n"
      "struct Struct {\n"
      "  enum class Enum : T;\n"
      "};\n"
      "template<typename U>\n"
      "enum class Struct<U>::Enum : U {\n"
      "  e1,\n"
      "  e2\n"
      "};\n";
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U"))));
}

TEST(TemplateTypeParmDecl, RecordDecl) {
  const char input[] =
      "template<typename T>\n"
      "class Class {\n"
      "  struct Struct;\n"
      "};\n"
      "template<typename U>\n"
      "struct Class<U>::Struct {\n"
      "  U field;\n"
      "};\n";
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("T"))));
  EXPECT_TRUE(matches(input, templateTypeParmDecl(hasName("U"))));
}

TEST(RefersToIntegralType, Matches) {
  EXPECT_TRUE(matches("template<int T> struct C {}; C<42> c;",
                      classTemplateSpecializationDecl(
                        hasAnyTemplateArgument(refersToIntegralType(
                          asString("int"))))));
  EXPECT_TRUE(notMatches("template<unsigned T> struct C {}; C<42> c;",
                         classTemplateSpecializationDecl(hasAnyTemplateArgument(
                           refersToIntegralType(asString("int"))))));
}

TEST(ConstructorDeclaration, SimpleCase) {
  EXPECT_TRUE(matches("class Foo { Foo(int i); };",
                      cxxConstructorDecl(ofClass(hasName("Foo")))));
  EXPECT_TRUE(notMatches("class Foo { Foo(int i); };",
                         cxxConstructorDecl(ofClass(hasName("Bar")))));
}

TEST(DestructorDeclaration, MatchesVirtualDestructor) {
  EXPECT_TRUE(matches("class Foo { virtual ~Foo(); };",
                      cxxDestructorDecl(ofClass(hasName("Foo")))));
}

TEST(DestructorDeclaration, DoesNotMatchImplicitDestructor) {
  EXPECT_TRUE(notMatches("class Foo {};",
                         cxxDestructorDecl(ofClass(hasName("Foo")))));
}

TEST(HasAnyConstructorInitializer, SimpleCase) {
  EXPECT_TRUE(
    notMatches("class Foo { Foo() { } };",
               cxxConstructorDecl(hasAnyConstructorInitializer(anything()))));
  EXPECT_TRUE(
    matches("class Foo {"
              "  Foo() : foo_() { }"
              "  int foo_;"
              "};",
            cxxConstructorDecl(hasAnyConstructorInitializer(anything()))));
}

TEST(HasAnyConstructorInitializer, ForField) {
  static const char Code[] =
    "class Baz { };"
      "class Foo {"
      "  Foo() : foo_(), bar_() { }"
      "  Baz foo_;"
      "  struct {"
      "    Baz bar_;"
      "  };"
      "};";
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    forField(hasType(recordDecl(hasName("Baz"))))))));
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    forField(hasName("foo_"))))));
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    forField(hasName("bar_"))))));
  EXPECT_TRUE(notMatches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    forField(hasType(recordDecl(hasName("Bar"))))))));
}

TEST(HasAnyConstructorInitializer, WithInitializer) {
  static const char Code[] =
    "class Foo {"
      "  Foo() : foo_(0) { }"
      "  int foo_;"
      "};";
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    withInitializer(integerLiteral(equals(0)))))));
  EXPECT_TRUE(notMatches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    withInitializer(integerLiteral(equals(1)))))));
}

TEST(HasAnyConstructorInitializer, IsWritten) {
  static const char Code[] =
    "struct Bar { Bar(){} };"
      "class Foo {"
      "  Foo() : foo_() { }"
      "  Bar foo_;"
      "  Bar bar_;"
      "};";
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    allOf(forField(hasName("foo_")), isWritten())))));
  EXPECT_TRUE(notMatches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    allOf(forField(hasName("bar_")), isWritten())))));
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(hasAnyConstructorInitializer(
    allOf(forField(hasName("bar_")), unless(isWritten()))))));
}

TEST(HasAnyConstructorInitializer, IsBaseInitializer) {
  static const char Code[] =
    "struct B {};"
      "struct D : B {"
      "  int I;"
      "  D(int i) : I(i) {}"
      "};"
      "struct E : B {"
      "  E() : B() {}"
      "};";
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(allOf(
    hasAnyConstructorInitializer(allOf(isBaseInitializer(), isWritten())),
    hasName("E")))));
  EXPECT_TRUE(notMatches(Code, cxxConstructorDecl(allOf(
    hasAnyConstructorInitializer(allOf(isBaseInitializer(), isWritten())),
    hasName("D")))));
  EXPECT_TRUE(matches(Code, cxxConstructorDecl(allOf(
    hasAnyConstructorInitializer(allOf(isMemberInitializer(), isWritten())),
    hasName("D")))));
  EXPECT_TRUE(notMatches(Code, cxxConstructorDecl(allOf(
    hasAnyConstructorInitializer(allOf(isMemberInitializer(), isWritten())),
    hasName("E")))));
}

TEST(IfStmt, ChildTraversalMatchers) {
  EXPECT_TRUE(matches("void f() { if (false) true; else false; }",
                      ifStmt(hasThen(cxxBoolLiteral(equals(true))))));
  EXPECT_TRUE(notMatches("void f() { if (false) false; else true; }",
                         ifStmt(hasThen(cxxBoolLiteral(equals(true))))));
  EXPECT_TRUE(matches("void f() { if (false) false; else true; }",
                      ifStmt(hasElse(cxxBoolLiteral(equals(true))))));
  EXPECT_TRUE(notMatches("void f() { if (false) true; else false; }",
                         ifStmt(hasElse(cxxBoolLiteral(equals(true))))));
}

TEST(MatchBinaryOperator, HasOperatorName) {
  StatementMatcher OperatorOr = binaryOperator(hasOperatorName("||"));

  EXPECT_TRUE(matches("void x() { true || false; }", OperatorOr));
  EXPECT_TRUE(notMatches("void x() { true && false; }", OperatorOr));
}

TEST(MatchBinaryOperator, HasLHSAndHasRHS) {
  StatementMatcher OperatorTrueFalse =
    binaryOperator(hasLHS(cxxBoolLiteral(equals(true))),
                   hasRHS(cxxBoolLiteral(equals(false))));

  EXPECT_TRUE(matches("void x() { true || false; }", OperatorTrueFalse));
  EXPECT_TRUE(matches("void x() { true && false; }", OperatorTrueFalse));
  EXPECT_TRUE(notMatches("void x() { false || true; }", OperatorTrueFalse));

  StatementMatcher OperatorIntPointer = arraySubscriptExpr(
    hasLHS(hasType(isInteger())), hasRHS(hasType(pointsTo(qualType()))));
  EXPECT_TRUE(matches("void x() { 1[\"abc\"]; }", OperatorIntPointer));
  EXPECT_TRUE(notMatches("void x() { \"abc\"[1]; }", OperatorIntPointer));
}

TEST(MatchBinaryOperator, HasEitherOperand) {
  StatementMatcher HasOperand =
    binaryOperator(hasEitherOperand(cxxBoolLiteral(equals(false))));

  EXPECT_TRUE(matches("void x() { true || false; }", HasOperand));
  EXPECT_TRUE(matches("void x() { false && true; }", HasOperand));
  EXPECT_TRUE(notMatches("void x() { true || true; }", HasOperand));
}

TEST(Matcher, BinaryOperatorTypes) {
  // Integration test that verifies the AST provides all binary operators in
  // a way we expect.
  // FIXME: Operator ','
  EXPECT_TRUE(
    matches("void x() { 3, 4; }", binaryOperator(hasOperatorName(","))));
  EXPECT_TRUE(
    matches("bool b; bool c = (b = true);",
            binaryOperator(hasOperatorName("="))));
  EXPECT_TRUE(
    matches("bool b = 1 != 2;", binaryOperator(hasOperatorName("!="))));
  EXPECT_TRUE(
    matches("bool b = 1 == 2;", binaryOperator(hasOperatorName("=="))));
  EXPECT_TRUE(matches("bool b = 1 < 2;", binaryOperator(hasOperatorName("<"))));
  EXPECT_TRUE(
    matches("bool b = 1 <= 2;", binaryOperator(hasOperatorName("<="))));
  EXPECT_TRUE(
    matches("int i = 1 << 2;", binaryOperator(hasOperatorName("<<"))));
  EXPECT_TRUE(
    matches("int i = 1; int j = (i <<= 2);",
            binaryOperator(hasOperatorName("<<="))));
  EXPECT_TRUE(matches("bool b = 1 > 2;", binaryOperator(hasOperatorName(">"))));
  EXPECT_TRUE(
    matches("bool b = 1 >= 2;", binaryOperator(hasOperatorName(">="))));
  EXPECT_TRUE(
    matches("int i = 1 >> 2;", binaryOperator(hasOperatorName(">>"))));
  EXPECT_TRUE(
    matches("int i = 1; int j = (i >>= 2);",
            binaryOperator(hasOperatorName(">>="))));
  EXPECT_TRUE(
    matches("int i = 42 ^ 23;", binaryOperator(hasOperatorName("^"))));
  EXPECT_TRUE(
    matches("int i = 42; int j = (i ^= 42);",
            binaryOperator(hasOperatorName("^="))));
  EXPECT_TRUE(
    matches("int i = 42 % 23;", binaryOperator(hasOperatorName("%"))));
  EXPECT_TRUE(
    matches("int i = 42; int j = (i %= 42);",
            binaryOperator(hasOperatorName("%="))));
  EXPECT_TRUE(
    matches("bool b = 42  &23;", binaryOperator(hasOperatorName("&"))));
  EXPECT_TRUE(
    matches("bool b = true && false;",
            binaryOperator(hasOperatorName("&&"))));
  EXPECT_TRUE(
    matches("bool b = true; bool c = (b &= false);",
            binaryOperator(hasOperatorName("&="))));
  EXPECT_TRUE(
    matches("bool b = 42 | 23;", binaryOperator(hasOperatorName("|"))));
  EXPECT_TRUE(
    matches("bool b = true || false;",
            binaryOperator(hasOperatorName("||"))));
  EXPECT_TRUE(
    matches("bool b = true; bool c = (b |= false);",
            binaryOperator(hasOperatorName("|="))));
  EXPECT_TRUE(
    matches("int i = 42  *23;", binaryOperator(hasOperatorName("*"))));
  EXPECT_TRUE(
    matches("int i = 42; int j = (i *= 23);",
            binaryOperator(hasOperatorName("*="))));
  EXPECT_TRUE(
    matches("int i = 42 / 23;", binaryOperator(hasOperatorName("/"))));
  EXPECT_TRUE(
    matches("int i = 42; int j = (i /= 23);",
            binaryOperator(hasOperatorName("/="))));
  EXPECT_TRUE(
    matches("int i = 42 + 23;", binaryOperator(hasOperatorName("+"))));
  EXPECT_TRUE(
    matches("int i = 42; int j = (i += 23);",
            binaryOperator(hasOperatorName("+="))));
  EXPECT_TRUE(
    matches("int i = 42 - 23;", binaryOperator(hasOperatorName("-"))));
  EXPECT_TRUE(
    matches("int i = 42; int j = (i -= 23);",
            binaryOperator(hasOperatorName("-="))));
  EXPECT_TRUE(
    matches("struct A { void x() { void (A::*a)(); (this->*a)(); } };",
            binaryOperator(hasOperatorName("->*"))));
  EXPECT_TRUE(
    matches("struct A { void x() { void (A::*a)(); ((*this).*a)(); } };",
            binaryOperator(hasOperatorName(".*"))));

  // Member expressions as operators are not supported in matches.
  EXPECT_TRUE(
    notMatches("struct A { void x(A *a) { a->x(this); } };",
               binaryOperator(hasOperatorName("->"))));

  // Initializer assignments are not represented as operator equals.
  EXPECT_TRUE(
    notMatches("bool b = true;", binaryOperator(hasOperatorName("="))));

  // Array indexing is not represented as operator.
  EXPECT_TRUE(notMatches("int a[42]; void x() { a[23]; }", unaryOperator()));

  // Overloaded operators do not match at all.
  EXPECT_TRUE(notMatches(
    "struct A { bool operator&&(const A &a) const { return false; } };"
      "void x() { A a, b; a && b; }",
    binaryOperator()));
}

TEST(MatchUnaryOperator, HasOperatorName) {
  StatementMatcher OperatorNot = unaryOperator(hasOperatorName("!"));

  EXPECT_TRUE(matches("void x() { !true; } ", OperatorNot));
  EXPECT_TRUE(notMatches("void x() { true; } ", OperatorNot));
}

TEST(MatchUnaryOperator, HasUnaryOperand) {
  StatementMatcher OperatorOnFalse =
    unaryOperator(hasUnaryOperand(cxxBoolLiteral(equals(false))));

  EXPECT_TRUE(matches("void x() { !false; }", OperatorOnFalse));
  EXPECT_TRUE(notMatches("void x() { !true; }", OperatorOnFalse));
}

TEST(Matcher, UnaryOperatorTypes) {
  // Integration test that verifies the AST provides all unary operators in
  // a way we expect.
  EXPECT_TRUE(matches("bool b = !true;", unaryOperator(hasOperatorName("!"))));
  EXPECT_TRUE(
    matches("bool b; bool *p = &b;", unaryOperator(hasOperatorName("&"))));
  EXPECT_TRUE(matches("int i = ~ 1;", unaryOperator(hasOperatorName("~"))));
  EXPECT_TRUE(
    matches("bool *p; bool b = *p;", unaryOperator(hasOperatorName("*"))));
  EXPECT_TRUE(
    matches("int i; int j = +i;", unaryOperator(hasOperatorName("+"))));
  EXPECT_TRUE(
    matches("int i; int j = -i;", unaryOperator(hasOperatorName("-"))));
  EXPECT_TRUE(
    matches("int i; int j = ++i;", unaryOperator(hasOperatorName("++"))));
  EXPECT_TRUE(
    matches("int i; int j = i++;", unaryOperator(hasOperatorName("++"))));
  EXPECT_TRUE(
    matches("int i; int j = --i;", unaryOperator(hasOperatorName("--"))));
  EXPECT_TRUE(
    matches("int i; int j = i--;", unaryOperator(hasOperatorName("--"))));

  // We don't match conversion operators.
  EXPECT_TRUE(notMatches("int i; double d = (double)i;", unaryOperator()));

  // Function calls are not represented as operator.
  EXPECT_TRUE(notMatches("void f(); void x() { f(); }", unaryOperator()));

  // Overloaded operators do not match at all.
  // FIXME: We probably want to add that.
  EXPECT_TRUE(notMatches(
    "struct A { bool operator!() const { return false; } };"
      "void x() { A a; !a; }", unaryOperator(hasOperatorName("!"))));
}

TEST(ArraySubscriptMatchers, ArrayIndex) {
  EXPECT_TRUE(matches(
    "int i[2]; void f() { i[1] = 1; }",
    arraySubscriptExpr(hasIndex(integerLiteral(equals(1))))));
  EXPECT_TRUE(matches(
    "int i[2]; void f() { 1[i] = 1; }",
    arraySubscriptExpr(hasIndex(integerLiteral(equals(1))))));
  EXPECT_TRUE(notMatches(
    "int i[2]; void f() { i[1] = 1; }",
    arraySubscriptExpr(hasIndex(integerLiteral(equals(0))))));
}

TEST(ArraySubscriptMatchers, MatchesArrayBase) {
  EXPECT_TRUE(matches(
    "int i[2]; void f() { i[1] = 2; }",
    arraySubscriptExpr(hasBase(implicitCastExpr(
      hasSourceExpression(declRefExpr()))))));
}

TEST(Matcher, OfClass) {
  StatementMatcher Constructor = cxxConstructExpr(hasDeclaration(cxxMethodDecl(
    ofClass(hasName("X")))));

  EXPECT_TRUE(
    matches("class X { public: X(); }; void x(int) { X x; }", Constructor));
  EXPECT_TRUE(
    matches("class X { public: X(); }; void x(int) { X x = X(); }",
            Constructor));
  EXPECT_TRUE(
    notMatches("class Y { public: Y(); }; void x(int) { Y y; }",
               Constructor));
}

TEST(Matcher, VisitsTemplateInstantiations) {
  EXPECT_TRUE(matches(
    "class A { public: void x(); };"
      "template <typename T> class B { public: void y() { T t; t.x(); } };"
      "void f() { B<A> b; b.y(); }",
    callExpr(callee(cxxMethodDecl(hasName("x"))))));

  EXPECT_TRUE(matches(
    "class A { public: void x(); };"
      "class C {"
      " public:"
      "  template <typename T> class B { public: void y() { T t; t.x(); } };"
      "};"
      "void f() {"
      "  C::B<A> b; b.y();"
      "}",
    recordDecl(hasName("C"), hasDescendant(callExpr(
      callee(cxxMethodDecl(hasName("x"))))))));
}

TEST(Matcher, HasCondition) {
  StatementMatcher IfStmt =
    ifStmt(hasCondition(cxxBoolLiteral(equals(true))));
  EXPECT_TRUE(matches("void x() { if (true) {} }", IfStmt));
  EXPECT_TRUE(notMatches("void x() { if (false) {} }", IfStmt));

  StatementMatcher ForStmt =
    forStmt(hasCondition(cxxBoolLiteral(equals(true))));
  EXPECT_TRUE(matches("void x() { for (;true;) {} }", ForStmt));
  EXPECT_TRUE(notMatches("void x() { for (;false;) {} }", ForStmt));

  StatementMatcher WhileStmt =
    whileStmt(hasCondition(cxxBoolLiteral(equals(true))));
  EXPECT_TRUE(matches("void x() { while (true) {} }", WhileStmt));
  EXPECT_TRUE(notMatches("void x() { while (false) {} }", WhileStmt));

  StatementMatcher SwitchStmt =
    switchStmt(hasCondition(integerLiteral(equals(42))));
  EXPECT_TRUE(matches("void x() { switch (42) {case 42:;} }", SwitchStmt));
  EXPECT_TRUE(notMatches("void x() { switch (43) {case 43:;} }", SwitchStmt));
}

TEST(For, ForLoopInternals) {
  EXPECT_TRUE(matches("void f(){ int i; for (; i < 3 ; ); }",
                      forStmt(hasCondition(anything()))));
  EXPECT_TRUE(matches("void f() { for (int i = 0; ;); }",
                      forStmt(hasLoopInit(anything()))));
}

TEST(For, ForRangeLoopInternals) {
  EXPECT_TRUE(matches("void f(){ int a[] {1, 2}; for (int i : a); }",
                      cxxForRangeStmt(hasLoopVariable(anything()))));
  EXPECT_TRUE(matches(
    "void f(){ int a[] {1, 2}; for (int i : a); }",
    cxxForRangeStmt(hasRangeInit(declRefExpr(to(varDecl(hasName("a"))))))));
}

TEST(For, NegativeForLoopInternals) {
  EXPECT_TRUE(notMatches("void f(){ for (int i = 0; ; ++i); }",
                         forStmt(hasCondition(expr()))));
  EXPECT_TRUE(notMatches("void f() {int i; for (; i < 4; ++i) {} }",
                         forStmt(hasLoopInit(anything()))));
}

TEST(HasBody, FindsBodyOfForWhileDoLoops) {
  EXPECT_TRUE(matches("void f() { for(;;) {} }",
                      forStmt(hasBody(compoundStmt()))));
  EXPECT_TRUE(notMatches("void f() { for(;;); }",
                         forStmt(hasBody(compoundStmt()))));
  EXPECT_TRUE(matches("void f() { while(true) {} }",
                      whileStmt(hasBody(compoundStmt()))));
  EXPECT_TRUE(matches("void f() { do {} while(true); }",
                      doStmt(hasBody(compoundStmt()))));
  EXPECT_TRUE(matches("void f() { int p[2]; for (auto x : p) {} }",
                      cxxForRangeStmt(hasBody(compoundStmt()))));
  EXPECT_TRUE(matches("void f() {}", functionDecl(hasBody(compoundStmt()))));
  EXPECT_TRUE(notMatches("void f();", functionDecl(hasBody(compoundStmt()))));
  EXPECT_TRUE(matches("void f(); void f() {}",
                      functionDecl(hasBody(compoundStmt()))));
}

TEST(HasAnySubstatement, MatchesForTopLevelCompoundStatement) {
  // The simplest case: every compound statement is in a function
  // definition, and the function body itself must be a compound
  // statement.
  EXPECT_TRUE(matches("void f() { for (;;); }",
                      compoundStmt(hasAnySubstatement(forStmt()))));
}

TEST(HasAnySubstatement, IsNotRecursive) {
  // It's really "has any immediate substatement".
  EXPECT_TRUE(notMatches("void f() { if (true) for (;;); }",
                         compoundStmt(hasAnySubstatement(forStmt()))));
}

TEST(HasAnySubstatement, MatchesInNestedCompoundStatements) {
  EXPECT_TRUE(matches("void f() { if (true) { for (;;); } }",
                      compoundStmt(hasAnySubstatement(forStmt()))));
}

TEST(HasAnySubstatement, FindsSubstatementBetweenOthers) {
  EXPECT_TRUE(matches("void f() { 1; 2; 3; for (;;); 4; 5; 6; }",
                      compoundStmt(hasAnySubstatement(forStmt()))));
}

TEST(Member, MatchesMemberAllocationFunction) {
  // Fails in C++11 mode
  EXPECT_TRUE(matchesConditionally(
    "namespace std { typedef typeof(sizeof(int)) size_t; }"
      "class X { void *operator new(std::size_t); };",
    cxxMethodDecl(ofClass(hasName("X"))), true, "-std=gnu++98"));

  EXPECT_TRUE(matches("class X { void operator delete(void*); };",
                      cxxMethodDecl(ofClass(hasName("X")))));

  // Fails in C++11 mode
  EXPECT_TRUE(matchesConditionally(
    "namespace std { typedef typeof(sizeof(int)) size_t; }"
      "class X { void operator delete[](void*, std::size_t); };",
    cxxMethodDecl(ofClass(hasName("X"))), true, "-std=gnu++98"));
}

TEST(HasDestinationType, MatchesSimpleCase) {
  EXPECT_TRUE(matches("char* p = static_cast<char*>(0);",
                      cxxStaticCastExpr(hasDestinationType(
                        pointsTo(TypeMatcher(anything()))))));
}

TEST(HasImplicitDestinationType, MatchesSimpleCase) {
  // This test creates an implicit const cast.
  EXPECT_TRUE(matches("int x; const int i = x;",
                      implicitCastExpr(
                        hasImplicitDestinationType(isInteger()))));
  // This test creates an implicit array-to-pointer cast.
  EXPECT_TRUE(matches("int arr[3]; int *p = arr;",
                      implicitCastExpr(hasImplicitDestinationType(
                        pointsTo(TypeMatcher(anything()))))));
}

TEST(HasImplicitDestinationType, DoesNotMatchIncorrectly) {
  // This test creates an implicit cast from int to char.
  EXPECT_TRUE(notMatches("char c = 0;",
                         implicitCastExpr(hasImplicitDestinationType(
                           unless(anything())))));
  // This test creates an implicit array-to-pointer cast.
  EXPECT_TRUE(notMatches("int arr[3]; int *p = arr;",
                         implicitCastExpr(hasImplicitDestinationType(
                           unless(anything())))));
}

TEST(IgnoringImplicit, MatchesImplicit) {
  EXPECT_TRUE(matches("class C {}; C a = C();",
                      varDecl(has(ignoringImplicit(cxxConstructExpr())))));
}

TEST(IgnoringImplicit, DoesNotMatchIncorrectly) {
  EXPECT_TRUE(
      notMatches("class C {}; C a = C();", varDecl(has(cxxConstructExpr()))));
}

TEST(IgnoringImpCasts, MatchesImpCasts) {
  // This test checks that ignoringImpCasts matches when implicit casts are
  // present and its inner matcher alone does not match.
  // Note that this test creates an implicit const cast.
  EXPECT_TRUE(matches("int x = 0; const int y = x;",
                      varDecl(hasInitializer(ignoringImpCasts(
                        declRefExpr(to(varDecl(hasName("x")))))))));
  // This test creates an implict cast from int to char.
  EXPECT_TRUE(matches("char x = 0;",
                      varDecl(hasInitializer(ignoringImpCasts(
                        integerLiteral(equals(0)))))));
}

TEST(IgnoringImpCasts, DoesNotMatchIncorrectly) {
  // These tests verify that ignoringImpCasts does not match if the inner
  // matcher does not match.
  // Note that the first test creates an implicit const cast.
  EXPECT_TRUE(notMatches("int x; const int y = x;",
                         varDecl(hasInitializer(ignoringImpCasts(
                           unless(anything()))))));
  EXPECT_TRUE(notMatches("int x; int y = x;",
                         varDecl(hasInitializer(ignoringImpCasts(
                           unless(anything()))))));

  // These tests verify that ignoringImplictCasts does not look through explicit
  // casts or parentheses.
  EXPECT_TRUE(notMatches("char* p = static_cast<char*>(0);",
                         varDecl(hasInitializer(ignoringImpCasts(
                           integerLiteral())))));
  EXPECT_TRUE(notMatches("int i = (0);",
                         varDecl(hasInitializer(ignoringImpCasts(
                           integerLiteral())))));
  EXPECT_TRUE(notMatches("float i = (float)0;",
                         varDecl(hasInitializer(ignoringImpCasts(
                           integerLiteral())))));
  EXPECT_TRUE(notMatches("float i = float(0);",
                         varDecl(hasInitializer(ignoringImpCasts(
                           integerLiteral())))));
}

TEST(IgnoringImpCasts, MatchesWithoutImpCasts) {
  // This test verifies that expressions that do not have implicit casts
  // still match the inner matcher.
  EXPECT_TRUE(matches("int x = 0; int &y = x;",
                      varDecl(hasInitializer(ignoringImpCasts(
                        declRefExpr(to(varDecl(hasName("x")))))))));
}

TEST(IgnoringParenCasts, MatchesParenCasts) {
  // This test checks that ignoringParenCasts matches when parentheses and/or
  // casts are present and its inner matcher alone does not match.
  EXPECT_TRUE(matches("int x = (0);",
                      varDecl(hasInitializer(ignoringParenCasts(
                        integerLiteral(equals(0)))))));
  EXPECT_TRUE(matches("int x = (((((0)))));",
                      varDecl(hasInitializer(ignoringParenCasts(
                        integerLiteral(equals(0)))))));

  // This test creates an implict cast from int to char in addition to the
  // parentheses.
  EXPECT_TRUE(matches("char x = (0);",
                      varDecl(hasInitializer(ignoringParenCasts(
                        integerLiteral(equals(0)))))));

  EXPECT_TRUE(matches("char x = (char)0;",
                      varDecl(hasInitializer(ignoringParenCasts(
                        integerLiteral(equals(0)))))));
  EXPECT_TRUE(matches("char* p = static_cast<char*>(0);",
                      varDecl(hasInitializer(ignoringParenCasts(
                        integerLiteral(equals(0)))))));
}

TEST(IgnoringParenCasts, MatchesWithoutParenCasts) {
  // This test verifies that expressions that do not have any casts still match.
  EXPECT_TRUE(matches("int x = 0;",
                      varDecl(hasInitializer(ignoringParenCasts(
                        integerLiteral(equals(0)))))));
}

TEST(IgnoringParenCasts, DoesNotMatchIncorrectly) {
  // These tests verify that ignoringImpCasts does not match if the inner
  // matcher does not match.
  EXPECT_TRUE(notMatches("int x = ((0));",
                         varDecl(hasInitializer(ignoringParenCasts(
                           unless(anything()))))));

  // This test creates an implicit cast from int to char in addition to the
  // parentheses.
  EXPECT_TRUE(notMatches("char x = ((0));",
                         varDecl(hasInitializer(ignoringParenCasts(
                           unless(anything()))))));

  EXPECT_TRUE(notMatches("char *x = static_cast<char *>((0));",
                         varDecl(hasInitializer(ignoringParenCasts(
                           unless(anything()))))));
}

TEST(IgnoringParenAndImpCasts, MatchesParenImpCasts) {
  // This test checks that ignoringParenAndImpCasts matches when
  // parentheses and/or implicit casts are present and its inner matcher alone
  // does not match.
  // Note that this test creates an implicit const cast.
  EXPECT_TRUE(matches("int x = 0; const int y = x;",
                      varDecl(hasInitializer(ignoringParenImpCasts(
                        declRefExpr(to(varDecl(hasName("x")))))))));
  // This test creates an implicit cast from int to char.
  EXPECT_TRUE(matches("const char x = (0);",
                      varDecl(hasInitializer(ignoringParenImpCasts(
                        integerLiteral(equals(0)))))));
}

TEST(IgnoringParenAndImpCasts, MatchesWithoutParenImpCasts) {
  // This test verifies that expressions that do not have parentheses or
  // implicit casts still match.
  EXPECT_TRUE(matches("int x = 0; int &y = x;",
                      varDecl(hasInitializer(ignoringParenImpCasts(
                        declRefExpr(to(varDecl(hasName("x")))))))));
  EXPECT_TRUE(matches("int x = 0;",
                      varDecl(hasInitializer(ignoringParenImpCasts(
                        integerLiteral(equals(0)))))));
}

TEST(IgnoringParenAndImpCasts, DoesNotMatchIncorrectly) {
  // These tests verify that ignoringParenImpCasts does not match if
  // the inner matcher does not match.
  // This test creates an implicit cast.
  EXPECT_TRUE(notMatches("char c = ((3));",
                         varDecl(hasInitializer(ignoringParenImpCasts(
                           unless(anything()))))));
  // These tests verify that ignoringParenAndImplictCasts does not look
  // through explicit casts.
  EXPECT_TRUE(notMatches("float y = (float(0));",
                         varDecl(hasInitializer(ignoringParenImpCasts(
                           integerLiteral())))));
  EXPECT_TRUE(notMatches("float y = (float)0;",
                         varDecl(hasInitializer(ignoringParenImpCasts(
                           integerLiteral())))));
  EXPECT_TRUE(notMatches("char* p = static_cast<char*>(0);",
                         varDecl(hasInitializer(ignoringParenImpCasts(
                           integerLiteral())))));
}

TEST(HasSourceExpression, MatchesImplicitCasts) {
  EXPECT_TRUE(matches("class string {}; class URL { public: URL(string s); };"
                        "void r() {string a_string; URL url = a_string; }",
                      implicitCastExpr(
                        hasSourceExpression(cxxConstructExpr()))));
}

TEST(HasSourceExpression, MatchesExplicitCasts) {
  EXPECT_TRUE(matches("float x = static_cast<float>(42);",
                      explicitCastExpr(
                        hasSourceExpression(hasDescendant(
                          expr(integerLiteral()))))));
}

TEST(UsingDeclaration, MatchesSpecificTarget) {
  EXPECT_TRUE(matches("namespace f { int a; void b(); } using f::b;",
                      usingDecl(hasAnyUsingShadowDecl(
                        hasTargetDecl(functionDecl())))));
  EXPECT_TRUE(notMatches("namespace f { int a; void b(); } using f::a;",
                         usingDecl(hasAnyUsingShadowDecl(
                           hasTargetDecl(functionDecl())))));
}

TEST(UsingDeclaration, ThroughUsingDeclaration) {
  EXPECT_TRUE(matches(
    "namespace a { void f(); } using a::f; void g() { f(); }",
    declRefExpr(throughUsingDecl(anything()))));
  EXPECT_TRUE(notMatches(
    "namespace a { void f(); } using a::f; void g() { a::f(); }",
    declRefExpr(throughUsingDecl(anything()))));
}

TEST(SingleDecl, IsSingleDecl) {
  StatementMatcher SingleDeclStmt =
    declStmt(hasSingleDecl(varDecl(hasInitializer(anything()))));
  EXPECT_TRUE(matches("void f() {int a = 4;}", SingleDeclStmt));
  EXPECT_TRUE(notMatches("void f() {int a;}", SingleDeclStmt));
  EXPECT_TRUE(notMatches("void f() {int a = 4, b = 3;}",
                         SingleDeclStmt));
}

TEST(DeclStmt, ContainsDeclaration) {
  DeclarationMatcher MatchesInit = varDecl(hasInitializer(anything()));

  EXPECT_TRUE(matches("void f() {int a = 4;}",
                      declStmt(containsDeclaration(0, MatchesInit))));
  EXPECT_TRUE(matches("void f() {int a = 4, b = 3;}",
                      declStmt(containsDeclaration(0, MatchesInit),
                               containsDeclaration(1, MatchesInit))));
  unsigned WrongIndex = 42;
  EXPECT_TRUE(notMatches("void f() {int a = 4, b = 3;}",
                         declStmt(containsDeclaration(WrongIndex,
                                                      MatchesInit))));
}

TEST(SwitchCase, MatchesEachCase) {
  EXPECT_TRUE(notMatches("void x() { switch(42); }",
                         switchStmt(forEachSwitchCase(caseStmt()))));
  EXPECT_TRUE(matches("void x() { switch(42) case 42:; }",
                      switchStmt(forEachSwitchCase(caseStmt()))));
  EXPECT_TRUE(matches("void x() { switch(42) { case 42:; } }",
                      switchStmt(forEachSwitchCase(caseStmt()))));
  EXPECT_TRUE(notMatches(
    "void x() { if (1) switch(42) { case 42: switch (42) { default:; } } }",
    ifStmt(has(switchStmt(forEachSwitchCase(defaultStmt()))))));
  EXPECT_TRUE(matches("void x() { switch(42) { case 1+1: case 4:; } }",
                      switchStmt(forEachSwitchCase(
                        caseStmt(hasCaseConstant(integerLiteral()))))));
  EXPECT_TRUE(notMatches("void x() { switch(42) { case 1+1: case 2+2:; } }",
                         switchStmt(forEachSwitchCase(
                           caseStmt(hasCaseConstant(integerLiteral()))))));
  EXPECT_TRUE(notMatches("void x() { switch(42) { case 1 ... 2:; } }",
                         switchStmt(forEachSwitchCase(
                           caseStmt(hasCaseConstant(integerLiteral()))))));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void x() { switch (42) { case 1: case 2: case 3: default:; } }",
    switchStmt(forEachSwitchCase(caseStmt().bind("x"))),
    llvm::make_unique<VerifyIdIsBoundTo<CaseStmt>>("x", 3)));
}

TEST(ForEachConstructorInitializer, MatchesInitializers) {
  EXPECT_TRUE(matches(
    "struct X { X() : i(42), j(42) {} int i, j; };",
    cxxConstructorDecl(forEachConstructorInitializer(cxxCtorInitializer()))));
}

TEST(HasConditionVariableStatement, DoesNotMatchCondition) {
  EXPECT_TRUE(notMatches(
    "void x() { if(true) {} }",
    ifStmt(hasConditionVariableStatement(declStmt()))));
  EXPECT_TRUE(notMatches(
    "void x() { int x; if((x = 42)) {} }",
    ifStmt(hasConditionVariableStatement(declStmt()))));
}

TEST(HasConditionVariableStatement, MatchesConditionVariables) {
  EXPECT_TRUE(matches(
    "void x() { if(int* a = 0) {} }",
    ifStmt(hasConditionVariableStatement(declStmt()))));
}

TEST(ForEach, BindsOneNode) {
  EXPECT_TRUE(matchAndVerifyResultTrue("class C { int x; };",
                                       recordDecl(hasName("C"), forEach(fieldDecl(hasName("x")).bind("x"))),
                                       llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("x", 1)));
}

TEST(ForEach, BindsMultipleNodes) {
  EXPECT_TRUE(matchAndVerifyResultTrue("class C { int x; int y; int z; };",
                                       recordDecl(hasName("C"), forEach(fieldDecl().bind("f"))),
                                       llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("f", 3)));
}

TEST(ForEach, BindsRecursiveCombinations) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { class D { int x; int y; }; class E { int y; int z; }; };",
    recordDecl(hasName("C"),
               forEach(recordDecl(forEach(fieldDecl().bind("f"))))),
    llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("f", 4)));
}

TEST(ForEachDescendant, BindsOneNode) {
  EXPECT_TRUE(matchAndVerifyResultTrue("class C { class D { int x; }; };",
                                       recordDecl(hasName("C"),
                                                  forEachDescendant(fieldDecl(hasName("x")).bind("x"))),
                                       llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("x", 1)));
}

TEST(ForEachDescendant, NestedForEachDescendant) {
  DeclarationMatcher m = recordDecl(
    isDefinition(), decl().bind("x"), hasName("C"));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { class B { class C {}; }; };",
    recordDecl(hasName("A"), anyOf(m, forEachDescendant(m))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", "C")));

  // Check that a partial match of 'm' that binds 'x' in the
  // first part of anyOf(m, anything()) will not overwrite the
  // binding created by the earlier binding in the hasDescendant.
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { class B { class C {}; }; };",
    recordDecl(hasName("A"), allOf(hasDescendant(m), anyOf(m, anything()))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", "C")));
}

TEST(ForEachDescendant, BindsMultipleNodes) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { class D { int x; int y; }; "
      "          class E { class F { int y; int z; }; }; };",
    recordDecl(hasName("C"), forEachDescendant(fieldDecl().bind("f"))),
    llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("f", 4)));
}

TEST(ForEachDescendant, BindsRecursiveCombinations) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { class D { "
      "          class E { class F { class G { int y; int z; }; }; }; }; };",
    recordDecl(hasName("C"), forEachDescendant(recordDecl(
      forEachDescendant(fieldDecl().bind("f"))))),
    llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("f", 8)));
}

TEST(ForEachDescendant, BindsCombinations) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void f() { if(true) {} if (true) {} while (true) {} if (true) {} while "
      "(true) {} }",
    compoundStmt(forEachDescendant(ifStmt().bind("if")),
                 forEachDescendant(whileStmt().bind("while"))),
    llvm::make_unique<VerifyIdIsBoundTo<IfStmt>>("if", 6)));
}

TEST(Has, DoesNotDeleteBindings) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X { int a; };", recordDecl(decl().bind("x"), has(fieldDecl())),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
}

TEST(LoopingMatchers, DoNotOverwritePreviousMatchResultOnFailure) {
  // Those matchers cover all the cases where an inner matcher is called
  // and there is not a 1:1 relationship between the match of the outer
  // matcher and the match of the inner matcher.
  // The pattern to look for is:
  //   ... return InnerMatcher.matches(...); ...
  // In which case no special handling is needed.
  //
  // On the other hand, if there are multiple alternative matches
  // (for example forEach*) or matches might be discarded (for example has*)
  // the implementation must make sure that the discarded matches do not
  // affect the bindings.
  // When new such matchers are added, add a test here that:
  // - matches a simple node, and binds it as the first thing in the matcher:
  //     recordDecl(decl().bind("x"), hasName("X")))
  // - uses the matcher under test afterwards in a way that not the first
  //   alternative is matched; for anyOf, that means the first branch
  //   would need to return false; for hasAncestor, it means that not
  //   the direct parent matches the inner matcher.

  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X { int y; };",
    recordDecl(
      recordDecl().bind("x"), hasName("::X"),
      anyOf(forEachDescendant(recordDecl(hasName("Y"))), anything())),
    llvm::make_unique<VerifyIdIsBoundTo<CXXRecordDecl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X {};", recordDecl(recordDecl().bind("x"), hasName("::X"),
                              anyOf(unless(anything()), anything())),
    llvm::make_unique<VerifyIdIsBoundTo<CXXRecordDecl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "template<typename T1, typename T2> class X {}; X<float, int> x;",
    classTemplateSpecializationDecl(
      decl().bind("x"),
      hasAnyTemplateArgument(refersToType(asString("int")))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X { void f(); void g(); };",
    cxxRecordDecl(decl().bind("x"), hasMethod(hasName("g"))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X { X() : a(1), b(2) {} double a; int b; };",
    recordDecl(decl().bind("x"),
               has(cxxConstructorDecl(
                 hasAnyConstructorInitializer(forField(hasName("b")))))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void x(int, int) { x(0, 42); }",
    callExpr(expr().bind("x"), hasAnyArgument(integerLiteral(equals(42)))),
    llvm::make_unique<VerifyIdIsBoundTo<Expr>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void x(int, int y) {}",
    functionDecl(decl().bind("x"), hasAnyParameter(hasName("y"))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void x() { return; if (true) {} }",
    functionDecl(decl().bind("x"),
                 has(compoundStmt(hasAnySubstatement(ifStmt())))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "namespace X { void b(int); void b(); }"
      "using X::b;",
    usingDecl(decl().bind("x"), hasAnyUsingShadowDecl(hasTargetDecl(
      functionDecl(parameterCountIs(1))))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A{}; class B{}; class C : B, A {};",
    cxxRecordDecl(decl().bind("x"), isDerivedFrom("::A")),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A{}; typedef A B; typedef A C; typedef A D;"
      "class E : A {};",
    cxxRecordDecl(decl().bind("x"), isDerivedFrom("C")),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { class B { void f() {} }; };",
    functionDecl(decl().bind("x"), hasAncestor(recordDecl(hasName("::A")))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "template <typename T> struct A { struct B {"
      "  void f() { if(true) {} }"
      "}; };"
      "void t() { A<int>::B b; b.f(); }",
    ifStmt(stmt().bind("x"), hasAncestor(recordDecl(hasName("::A")))),
    llvm::make_unique<VerifyIdIsBoundTo<Stmt>>("x", 2)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A {};",
    recordDecl(hasName("::A"), decl().bind("x"), unless(hasName("fooble"))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { A() : s(), i(42) {} const char *s; int i; };",
    cxxConstructorDecl(hasName("::A::A"), decl().bind("x"),
                       forEachConstructorInitializer(forField(hasName("i")))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("x", 1)));
}

TEST(ForEachDescendant, BindsCorrectNodes) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { void f(); int i; };",
    recordDecl(hasName("C"), forEachDescendant(decl().bind("decl"))),
    llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("decl", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { void f() {} int i; };",
    recordDecl(hasName("C"), forEachDescendant(decl().bind("decl"))),
    llvm::make_unique<VerifyIdIsBoundTo<FunctionDecl>>("decl", 1)));
}

TEST(FindAll, BindsNodeOnMatch) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A {};",
    recordDecl(hasName("::A"), findAll(recordDecl(hasName("::A")).bind("v"))),
    llvm::make_unique<VerifyIdIsBoundTo<CXXRecordDecl>>("v", 1)));
}

TEST(FindAll, BindsDescendantNodeOnMatch) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { int a; int b; };",
    recordDecl(hasName("::A"), findAll(fieldDecl().bind("v"))),
    llvm::make_unique<VerifyIdIsBoundTo<FieldDecl>>("v", 2)));
}

TEST(FindAll, BindsNodeAndDescendantNodesOnOneMatch) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { int a; int b; };",
    recordDecl(hasName("::A"),
               findAll(decl(anyOf(recordDecl(hasName("::A")).bind("v"),
                                  fieldDecl().bind("v"))))),
    llvm::make_unique<VerifyIdIsBoundTo<Decl>>("v", 3)));

  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class A { class B {}; class C {}; };",
    recordDecl(hasName("::A"), findAll(recordDecl(isDefinition()).bind("v"))),
    llvm::make_unique<VerifyIdIsBoundTo<CXXRecordDecl>>("v", 3)));
}

TEST(HasAncenstor, MatchesDeclarationAncestors) {
  EXPECT_TRUE(matches(
    "class A { class B { class C {}; }; };",
    recordDecl(hasName("C"), hasAncestor(recordDecl(hasName("A"))))));
}

TEST(HasAncenstor, FailsIfNoAncestorMatches) {
  EXPECT_TRUE(notMatches(
    "class A { class B { class C {}; }; };",
    recordDecl(hasName("C"), hasAncestor(recordDecl(hasName("X"))))));
}

TEST(HasAncestor, MatchesDeclarationsThatGetVisitedLater) {
  EXPECT_TRUE(matches(
    "class A { class B { void f() { C c; } class C {}; }; };",
    varDecl(hasName("c"), hasType(recordDecl(hasName("C"),
                                             hasAncestor(recordDecl(hasName("A"))))))));
}

TEST(HasAncenstor, MatchesStatementAncestors) {
  EXPECT_TRUE(matches(
    "void f() { if (true) { while (false) { 42; } } }",
    integerLiteral(equals(42), hasAncestor(ifStmt()))));
}

TEST(HasAncestor, DrillsThroughDifferentHierarchies) {
  EXPECT_TRUE(matches(
    "void f() { if (true) { int x = 42; } }",
    integerLiteral(equals(42), hasAncestor(functionDecl(hasName("f"))))));
}

TEST(HasAncestor, BindsRecursiveCombinations) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { class D { class E { class F { int y; }; }; }; };",
    fieldDecl(hasAncestor(recordDecl(hasAncestor(recordDecl().bind("r"))))),
    llvm::make_unique<VerifyIdIsBoundTo<CXXRecordDecl>>("r", 1)));
}

TEST(HasAncestor, BindsCombinationsWithHasDescendant) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class C { class D { class E { class F { int y; }; }; }; };",
    fieldDecl(hasAncestor(
      decl(
        hasDescendant(recordDecl(isDefinition(),
                                 hasAncestor(recordDecl())))
      ).bind("d")
    )),
    llvm::make_unique<VerifyIdIsBoundTo<CXXRecordDecl>>("d", "E")));
}

TEST(HasAncestor, MatchesClosestAncestor) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "template <typename T> struct C {"
      "  void f(int) {"
      "    struct I { void g(T) { int x; } } i; i.g(42);"
      "  }"
      "};"
      "template struct C<int>;",
    varDecl(hasName("x"),
            hasAncestor(functionDecl(hasParameter(
              0, varDecl(hasType(asString("int"))))).bind("f"))).bind("v"),
    llvm::make_unique<VerifyIdIsBoundTo<FunctionDecl>>("f", "g", 2)));
}

TEST(HasAncestor, MatchesInTemplateInstantiations) {
  EXPECT_TRUE(matches(
    "template <typename T> struct A { struct B { struct C { T t; }; }; }; "
      "A<int>::B::C a;",
    fieldDecl(hasType(asString("int")),
              hasAncestor(recordDecl(hasName("A"))))));
}

TEST(HasAncestor, MatchesInImplicitCode) {
  EXPECT_TRUE(matches(
    "struct X {}; struct A { A() {} X x; };",
    cxxConstructorDecl(
      hasAnyConstructorInitializer(withInitializer(expr(
        hasAncestor(recordDecl(hasName("A")))))))));
}

TEST(HasParent, MatchesOnlyParent) {
  EXPECT_TRUE(matches(
    "void f() { if (true) { int x = 42; } }",
    compoundStmt(hasParent(ifStmt()))));
  EXPECT_TRUE(notMatches(
    "void f() { for (;;) { int x = 42; } }",
    compoundStmt(hasParent(ifStmt()))));
  EXPECT_TRUE(notMatches(
    "void f() { if (true) for (;;) { int x = 42; } }",
    compoundStmt(hasParent(ifStmt()))));
}

TEST(HasAncestor, MatchesAllAncestors) {
  EXPECT_TRUE(matches(
    "template <typename T> struct C { static void f() { 42; } };"
      "void t() { C<int>::f(); }",
    integerLiteral(
      equals(42),
      allOf(
        hasAncestor(cxxRecordDecl(isTemplateInstantiation())),
        hasAncestor(cxxRecordDecl(unless(isTemplateInstantiation())))))));
}

TEST(HasAncestor, ImplicitArrayCopyCtorDeclRefExpr) {
  EXPECT_TRUE(matches("struct MyClass {\n"
                        "  int c[1];\n"
                        "  static MyClass Create() { return MyClass(); }\n"
                        "};",
                      declRefExpr(to(decl(hasAncestor(decl()))))));
}

TEST(HasAncestor, AnonymousUnionMemberExpr) {
  EXPECT_TRUE(matches("int F() {\n"
                        "  union { int i; };\n"
                        "  return i;\n"
                        "}\n",
                      memberExpr(member(hasAncestor(decl())))));
  EXPECT_TRUE(matches("void f() {\n"
                        "  struct {\n"
                        "    struct { int a; int b; };\n"
                        "  } s;\n"
                        "  s.a = 4;\n"
                        "}\n",
                      memberExpr(member(hasAncestor(decl())))));
  EXPECT_TRUE(matches("void f() {\n"
                        "  struct {\n"
                        "    struct { int a; int b; };\n"
                        "  } s;\n"
                        "  s.a = 4;\n"
                        "}\n",
                      declRefExpr(to(decl(hasAncestor(decl()))))));
}
TEST(HasAncestor, NonParmDependentTemplateParmVarDeclRefExpr) {
  EXPECT_TRUE(matches("struct PartitionAllocator {\n"
                        "  template<typename T>\n"
                        "  static int quantizedSize(int count) {\n"
                        "    return count;\n"
                        "  }\n"
                        "  void f() { quantizedSize<int>(10); }\n"
                        "};",
                      declRefExpr(to(decl(hasAncestor(decl()))))));
}

TEST(HasAncestor, AddressOfExplicitSpecializationFunction) {
  EXPECT_TRUE(matches("template <class T> void f();\n"
                        "template <> void f<int>();\n"
                        "void (*get_f())() { return f<int>; }\n",
                      declRefExpr(to(decl(hasAncestor(decl()))))));
}

TEST(HasParent, MatchesAllParents) {
  EXPECT_TRUE(matches(
    "template <typename T> struct C { static void f() { 42; } };"
      "void t() { C<int>::f(); }",
    integerLiteral(
      equals(42),
      hasParent(compoundStmt(hasParent(functionDecl(
        hasParent(cxxRecordDecl(isTemplateInstantiation())))))))));
  EXPECT_TRUE(
    matches("template <typename T> struct C { static void f() { 42; } };"
              "void t() { C<int>::f(); }",
            integerLiteral(
              equals(42),
              hasParent(compoundStmt(hasParent(functionDecl(hasParent(
                cxxRecordDecl(unless(isTemplateInstantiation()))))))))));
  EXPECT_TRUE(matches(
    "template <typename T> struct C { static void f() { 42; } };"
      "void t() { C<int>::f(); }",
    integerLiteral(equals(42),
                   hasParent(compoundStmt(
                     allOf(hasParent(functionDecl(hasParent(
                       cxxRecordDecl(isTemplateInstantiation())))),
                           hasParent(functionDecl(hasParent(cxxRecordDecl(
                             unless(isTemplateInstantiation())))))))))));
  EXPECT_TRUE(
    notMatches("template <typename T> struct C { static void f() {} };"
                 "void t() { C<int>::f(); }",
               compoundStmt(hasParent(recordDecl()))));
}

TEST(HasParent, NoDuplicateParents) {
  class HasDuplicateParents : public BoundNodesCallback {
  public:
    bool run(const BoundNodes *Nodes) override { return false; }
    bool run(const BoundNodes *Nodes, ASTContext *Context) override {
      const Stmt *Node = Nodes->getNodeAs<Stmt>("node");
      std::set<const void *> Parents;
      for (const auto &Parent : Context->getParents(*Node)) {
        if (!Parents.insert(Parent.getMemoizationData()).second) {
          return true;
        }
      }
      return false;
    }
  };
  EXPECT_FALSE(matchAndVerifyResultTrue(
    "template <typename T> int Foo() { return 1 + 2; }\n"
      "int x = Foo<int>() + Foo<unsigned>();",
    stmt().bind("node"), llvm::make_unique<HasDuplicateParents>()));
}

TEST(TypeMatching, PointeeTypes) {
  EXPECT_TRUE(matches("int b; int &a = b;",
                      referenceType(pointee(builtinType()))));
  EXPECT_TRUE(matches("int *a;", pointerType(pointee(builtinType()))));

  EXPECT_TRUE(matches("int *a;",
                      loc(pointerType(pointee(builtinType())))));

  EXPECT_TRUE(matches(
    "int const *A;",
    pointerType(pointee(isConstQualified(), builtinType()))));
  EXPECT_TRUE(notMatches(
    "int *A;",
    pointerType(pointee(isConstQualified(), builtinType()))));
}

TEST(ElaboratedTypeNarrowing, hasQualifier) {
  EXPECT_TRUE(matches(
    "namespace N {"
      "  namespace M {"
      "    class D {};"
      "  }"
      "}"
      "N::M::D d;",
    elaboratedType(hasQualifier(hasPrefix(specifiesNamespace(hasName("N")))))));
  EXPECT_TRUE(notMatches(
    "namespace M {"
      "  class D {};"
      "}"
      "M::D d;",
    elaboratedType(hasQualifier(hasPrefix(specifiesNamespace(hasName("N")))))));
  EXPECT_TRUE(notMatches(
    "struct D {"
      "} d;",
    elaboratedType(hasQualifier(nestedNameSpecifier()))));
}

TEST(ElaboratedTypeNarrowing, namesType) {
  EXPECT_TRUE(matches(
    "namespace N {"
      "  namespace M {"
      "    class D {};"
      "  }"
      "}"
      "N::M::D d;",
    elaboratedType(elaboratedType(namesType(recordType(
      hasDeclaration(namedDecl(hasName("D")))))))));
  EXPECT_TRUE(notMatches(
    "namespace M {"
      "  class D {};"
      "}"
      "M::D d;",
    elaboratedType(elaboratedType(namesType(typedefType())))));
}

TEST(NNS, BindsNestedNameSpecifiers) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "namespace ns { struct E { struct B {}; }; } ns::E::B b;",
    nestedNameSpecifier(specifiesType(asString("struct ns::E"))).bind("nns"),
    llvm::make_unique<VerifyIdIsBoundTo<NestedNameSpecifier>>(
      "nns", "ns::struct E::")));
}

TEST(NNS, BindsNestedNameSpecifierLocs) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "namespace ns { struct B {}; } ns::B b;",
    loc(nestedNameSpecifier()).bind("loc"),
    llvm::make_unique<VerifyIdIsBoundTo<NestedNameSpecifierLoc>>("loc", 1)));
}

TEST(NNS, DescendantsOfNestedNameSpecifiers) {
  std::string Fragment =
    "namespace a { struct A { struct B { struct C {}; }; }; };"
      "void f() { a::A::B::C c; }";
  EXPECT_TRUE(matches(
    Fragment,
    nestedNameSpecifier(specifiesType(asString("struct a::A::B")),
                        hasDescendant(nestedNameSpecifier(
                          specifiesNamespace(hasName("a")))))));
  EXPECT_TRUE(notMatches(
    Fragment,
    nestedNameSpecifier(specifiesType(asString("struct a::A::B")),
                        has(nestedNameSpecifier(
                          specifiesNamespace(hasName("a")))))));
  EXPECT_TRUE(matches(
    Fragment,
    nestedNameSpecifier(specifiesType(asString("struct a::A")),
                        has(nestedNameSpecifier(
                          specifiesNamespace(hasName("a")))))));

  // Not really useful because a NestedNameSpecifier can af at most one child,
  // but to complete the interface.
  EXPECT_TRUE(matchAndVerifyResultTrue(
    Fragment,
    nestedNameSpecifier(specifiesType(asString("struct a::A::B")),
                        forEach(nestedNameSpecifier().bind("x"))),
    llvm::make_unique<VerifyIdIsBoundTo<NestedNameSpecifier>>("x", 1)));
}

TEST(NNS, NestedNameSpecifiersAsDescendants) {
  std::string Fragment =
    "namespace a { struct A { struct B { struct C {}; }; }; };"
      "void f() { a::A::B::C c; }";
  EXPECT_TRUE(matches(
    Fragment,
    decl(hasDescendant(nestedNameSpecifier(specifiesType(
      asString("struct a::A")))))));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    Fragment,
    functionDecl(hasName("f"),
                 forEachDescendant(nestedNameSpecifier().bind("x"))),
    // Nested names: a, a::A and a::A::B.
    llvm::make_unique<VerifyIdIsBoundTo<NestedNameSpecifier>>("x", 3)));
}

TEST(NNSLoc, DescendantsOfNestedNameSpecifierLocs) {
  std::string Fragment =
    "namespace a { struct A { struct B { struct C {}; }; }; };"
      "void f() { a::A::B::C c; }";
  EXPECT_TRUE(matches(
    Fragment,
    nestedNameSpecifierLoc(loc(specifiesType(asString("struct a::A::B"))),
                           hasDescendant(loc(nestedNameSpecifier(
                             specifiesNamespace(hasName("a"))))))));
  EXPECT_TRUE(notMatches(
    Fragment,
    nestedNameSpecifierLoc(loc(specifiesType(asString("struct a::A::B"))),
                           has(loc(nestedNameSpecifier(
                             specifiesNamespace(hasName("a"))))))));
  EXPECT_TRUE(matches(
    Fragment,
    nestedNameSpecifierLoc(loc(specifiesType(asString("struct a::A"))),
                           has(loc(nestedNameSpecifier(
                             specifiesNamespace(hasName("a"))))))));

  EXPECT_TRUE(matchAndVerifyResultTrue(
    Fragment,
    nestedNameSpecifierLoc(loc(specifiesType(asString("struct a::A::B"))),
                           forEach(nestedNameSpecifierLoc().bind("x"))),
    llvm::make_unique<VerifyIdIsBoundTo<NestedNameSpecifierLoc>>("x", 1)));
}

TEST(NNSLoc, NestedNameSpecifierLocsAsDescendants) {
  std::string Fragment =
    "namespace a { struct A { struct B { struct C {}; }; }; };"
      "void f() { a::A::B::C c; }";
  EXPECT_TRUE(matches(
    Fragment,
    decl(hasDescendant(loc(nestedNameSpecifier(specifiesType(
      asString("struct a::A"))))))));
  EXPECT_TRUE(matchAndVerifyResultTrue(
    Fragment,
    functionDecl(hasName("f"),
                 forEachDescendant(nestedNameSpecifierLoc().bind("x"))),
    // Nested names: a, a::A and a::A::B.
    llvm::make_unique<VerifyIdIsBoundTo<NestedNameSpecifierLoc>>("x", 3)));
}
template <typename T> class VerifyMatchOnNode : public BoundNodesCallback {
public:
  VerifyMatchOnNode(StringRef Id, const internal::Matcher<T> &InnerMatcher,
                    StringRef InnerId)
    : Id(Id), InnerMatcher(InnerMatcher), InnerId(InnerId) {
  }

  bool run(const BoundNodes *Nodes) override { return false; }

  bool run(const BoundNodes *Nodes, ASTContext *Context) override {
    const T *Node = Nodes->getNodeAs<T>(Id);
    return selectFirst<T>(InnerId, match(InnerMatcher, *Node, *Context)) !=
      nullptr;
  }
private:
  std::string Id;
  internal::Matcher<T> InnerMatcher;
  std::string InnerId;
};

TEST(MatchFinder, CanMatchDeclarationsRecursively) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X { class Y {}; };", recordDecl(hasName("::X")).bind("X"),
    llvm::make_unique<VerifyMatchOnNode<Decl>>(
      "X", decl(hasDescendant(recordDecl(hasName("X::Y")).bind("Y"))),
      "Y")));
  EXPECT_TRUE(matchAndVerifyResultFalse(
    "class X { class Y {}; };", recordDecl(hasName("::X")).bind("X"),
    llvm::make_unique<VerifyMatchOnNode<Decl>>(
      "X", decl(hasDescendant(recordDecl(hasName("X::Z")).bind("Z"))),
      "Z")));
}

TEST(MatchFinder, CanMatchStatementsRecursively) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "void f() { if (1) { for (;;) { } } }", ifStmt().bind("if"),
    llvm::make_unique<VerifyMatchOnNode<Stmt>>(
      "if", stmt(hasDescendant(forStmt().bind("for"))), "for")));
  EXPECT_TRUE(matchAndVerifyResultFalse(
    "void f() { if (1) { for (;;) { } } }", ifStmt().bind("if"),
    llvm::make_unique<VerifyMatchOnNode<Stmt>>(
      "if", stmt(hasDescendant(declStmt().bind("decl"))), "decl")));
}

TEST(MatchFinder, CanMatchSingleNodesRecursively) {
  EXPECT_TRUE(matchAndVerifyResultTrue(
    "class X { class Y {}; };", recordDecl(hasName("::X")).bind("X"),
    llvm::make_unique<VerifyMatchOnNode<Decl>>(
      "X", recordDecl(has(recordDecl(hasName("X::Y")).bind("Y"))), "Y")));
  EXPECT_TRUE(matchAndVerifyResultFalse(
    "class X { class Y {}; };", recordDecl(hasName("::X")).bind("X"),
    llvm::make_unique<VerifyMatchOnNode<Decl>>(
      "X", recordDecl(has(recordDecl(hasName("X::Z")).bind("Z"))), "Z")));
}

TEST(StatementMatcher, HasReturnValue) {
  StatementMatcher RetVal = returnStmt(hasReturnValue(binaryOperator()));
  EXPECT_TRUE(matches("int F() { int a, b; return a + b; }", RetVal));
  EXPECT_FALSE(matches("int F() { int a; return a; }", RetVal));
  EXPECT_FALSE(matches("void F() { return; }", RetVal));
}

TEST(StatementMatcher, ForFunction) {
  const auto CppString1 =
    "struct PosVec {"
      "  PosVec& operator=(const PosVec&) {"
      "    auto x = [] { return 1; };"
      "    return *this;"
      "  }"
      "};";
  const auto CppString2 =
    "void F() {"
      "  struct S {"
      "    void F2() {"
      "       return;"
      "    }"
      "  };"
      "}";
  EXPECT_TRUE(
    matches(
      CppString1,
      returnStmt(forFunction(hasName("operator=")),
                 has(unaryOperator(hasOperatorName("*"))))));
  EXPECT_TRUE(
    notMatches(
      CppString1,
      returnStmt(forFunction(hasName("operator=")),
                 has(integerLiteral()))));
  EXPECT_TRUE(
    matches(
      CppString1,
      returnStmt(forFunction(hasName("operator()")),
                 has(integerLiteral()))));
  EXPECT_TRUE(matches(CppString2, returnStmt(forFunction(hasName("F2")))));
  EXPECT_TRUE(notMatches(CppString2, returnStmt(forFunction(hasName("F")))));
}

TEST(Matcher, ForEachOverriden) {
  const auto ForEachOverriddenInClass = [](const char *ClassName) {
    return cxxMethodDecl(ofClass(hasName(ClassName)), isVirtual(),
                         forEachOverridden(cxxMethodDecl().bind("overridden")))
        .bind("override");
  };
  static const char Code1[] = "class A { virtual void f(); };"
                              "class B : public A { void f(); };"
                              "class C : public B { void f(); };";
  // C::f overrides A::f.
  EXPECT_TRUE(matchAndVerifyResultTrue(
      Code1, ForEachOverriddenInClass("C"),
      llvm::make_unique<VerifyIdIsBoundTo<CXXMethodDecl>>("override", "f", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
      Code1, ForEachOverriddenInClass("C"),
      llvm::make_unique<VerifyIdIsBoundTo<CXXMethodDecl>>("overridden", "f",
                                                          1)));
  // B::f overrides A::f.
  EXPECT_TRUE(matchAndVerifyResultTrue(
      Code1, ForEachOverriddenInClass("B"),
      llvm::make_unique<VerifyIdIsBoundTo<CXXMethodDecl>>("override", "f", 1)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
      Code1, ForEachOverriddenInClass("B"),
      llvm::make_unique<VerifyIdIsBoundTo<CXXMethodDecl>>("overridden", "f",
                                                          1)));
  // A::f overrides nothing.
  EXPECT_TRUE(notMatches(Code1, ForEachOverriddenInClass("A")));

  static const char Code2[] =
      "class A1 { virtual void f(); };"
      "class A2 { virtual void f(); };"
      "class B : public A1, public A2 { void f(); };";
  // B::f overrides A1::f and A2::f. This produces two matches.
  EXPECT_TRUE(matchAndVerifyResultTrue(
      Code2, ForEachOverriddenInClass("B"),
      llvm::make_unique<VerifyIdIsBoundTo<CXXMethodDecl>>("override", "f", 2)));
  EXPECT_TRUE(matchAndVerifyResultTrue(
      Code2, ForEachOverriddenInClass("B"),
      llvm::make_unique<VerifyIdIsBoundTo<CXXMethodDecl>>("overridden", "f",
                                                          2)));
  // A1::f overrides nothing.
  EXPECT_TRUE(notMatches(Code2, ForEachOverriddenInClass("A1")));
}

TEST(Matcher, HasAnyDeclaration) {
  std::string Fragment = "void foo(int p1);"
                         "void foo(int *p2);"
                         "void bar(int p3);"
                         "template <typename T> void baz(T t) { foo(t); }";

  EXPECT_TRUE(
      matches(Fragment, unresolvedLookupExpr(hasAnyDeclaration(functionDecl(
                            hasParameter(0, parmVarDecl(hasName("p1"))))))));
  EXPECT_TRUE(
      matches(Fragment, unresolvedLookupExpr(hasAnyDeclaration(functionDecl(
                            hasParameter(0, parmVarDecl(hasName("p2"))))))));
  EXPECT_TRUE(
      notMatches(Fragment, unresolvedLookupExpr(hasAnyDeclaration(functionDecl(
                               hasParameter(0, parmVarDecl(hasName("p3"))))))));
  EXPECT_TRUE(notMatches(Fragment, unresolvedLookupExpr(hasAnyDeclaration(
                                       functionDecl(hasName("bar"))))));
}

TEST(SubstTemplateTypeParmType, HasReplacementType) {
  std::string Fragment = "template<typename T>"
                         "double F(T t);"
                         "int i;"
                         "double j = F(i);";
  EXPECT_TRUE(matches(Fragment, substTemplateTypeParmType(hasReplacementType(
                                    qualType(asString("int"))))));
  EXPECT_TRUE(notMatches(Fragment, substTemplateTypeParmType(hasReplacementType(
                                       qualType(asString("double"))))));
  EXPECT_TRUE(
      notMatches("template<int N>"
                 "double F();"
                 "double j = F<5>();",
                 substTemplateTypeParmType(hasReplacementType(qualType()))));
}

TEST(ClassTemplateSpecializationDecl, HasSpecializedTemplate) {
  auto Matcher = classTemplateSpecializationDecl(
      hasSpecializedTemplate(classTemplateDecl()));
  EXPECT_TRUE(
      matches("template<typename T> class A {}; typedef A<int> B;", Matcher));
  EXPECT_TRUE(notMatches("template<typename T> class A {};", Matcher));
}

} // namespace ast_matchers
} // namespace clang
