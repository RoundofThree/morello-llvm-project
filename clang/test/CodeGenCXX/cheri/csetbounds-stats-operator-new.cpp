// RUN: rm -f %t.csv
// Use -emit-llvm here to ignore all bounds added in the backend
// RUN: %cheri128_purecap_cc1 %s -std=c++2a -cheri-bounds=aggressive \
// RUN:   -mllvm -collect-csetbounds-stats=csv -mllvm -collect-csetbounds-output=%t.csv -emit-llvm -o /dev/null
// RUN: FileCheck -input-file %t.csv %s -check-prefixes CSV

// CSV: alignment_bits,size,kind,source_loc,compiler_pass,details

typedef decltype(sizeof(0)) size_t;
namespace std {
  enum class align_val_t : size_t {};
  struct nothrow_t {};
  typedef ::size_t size_t;
}
std::nothrow_t nothrow;

void* operator new(std::size_t count, void* p) { return __builtin_cheri_bounds_set(p, count); }
void* operator new[](std::size_t count, void* p) { return __builtin_cheri_bounds_set(p, count); }
void* operator new(std::size_t count, const std::nothrow_t& tag) { return ::operator new(count); }
void* operator new[](std::size_t count, const std::nothrow_t& tag) { return ::operator new[](count); }
struct Foo {
  int x;
};


void *test_foo_not_aligned() { return new Foo; }
// CSV-NEXT: 2,4,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:39, col:43>","operator new for Foo * __capability","allocating type struct Foo"
void *test_foo_not_aligned_nothrow() { return new (nothrow) Foo; }
// CSV-NEXT: 0,1,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:52","Add subobject bounds","C++ reference on const std::nothrow_t"
// CSV-NEXT: 2,4,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-2]]:47, col:61>","operator new for Foo * __capability","allocating type struct Foo"
void *test_foo_not_aligned_array() { return new Foo[2]; }
// CSV-NEXT: 2,8,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:45, col:54>","operator new[] for Foo * __capability","allocating type struct Foo"
void *test_foo_not_aligned_array_nonconst(int n) { return new Foo[n]; }
// CSV-NEXT: 2,<unknown multiple of 4>,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:59, col:68>","operator new[] for Foo * __capability","allocating type struct Foo"
void *test_foo_nonalloc(void* buffer) { return new (buffer) Foo; }
// CSV-NEXT: 0,4,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:48","non-allocating placement new[]","for type struct Foo"
void *test_foo_nonalloc_array(void* buffer) { return new (buffer) Foo[2]; }
// CSV-NEXT: 0,8,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:54","non-allocating placement new","for type struct Foo"
void *test_foo_nonalloc_array_nonconst(void* buffer, int n) { return new (buffer) Foo[n]; }
// CSV-NEXT: 0,<unknown>,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:70","non-allocating placement new","for type struct Foo"

struct alignas(256) FooAligned {
  char buffer[128];
};

void *test_foo_aligned() { return new FooAligned; }
// CSV-NEXT: 8,256,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:35, col:39>","operator new for FooAligned * __capability","allocating type struct FooAligned"
void *test_foo_aligned_nothrow() { return new (nothrow) FooAligned; }
// CSV-NEXT: 0,1,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:48","Add subobject bounds","C++ reference on const std::nothrow_t"
// CSV-NEXT: 8,256,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-2]]:43, col:57>","operator new for FooAligned * __capability","allocating type struct FooAligned"
void *test_foo_aligned_array() { return new FooAligned[3]; }
// CSV-NEXT: 8,768,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:41, col:57>","operator new[] for FooAligned * __capability","allocating type struct FooAligned"
void *test_foo_aligned_array_nonconst(int n) { return new FooAligned[n]; }
// CSV-NEXT: 8,<unknown multiple of 256>,h,"<{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:55, col:71>","operator new[] for FooAligned * __capability","allocating type struct FooAligned"
void *test_foo_aligned_nonalloc(void* buffer) {  return new (buffer) FooAligned; }
// CSV-NEXT: 0,256,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:57","non-allocating placement new[]","for type struct FooAligned"
void *test_foo_aligned_nonalloc_array(void* buffer) { return new (buffer) FooAligned[2]; }
// CSV-NEXT: 0,512,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:62","non-allocating placement new","for type struct FooAligned"
void *test_foo_aligned_nonalloc_array_nonconst(void* buffer, int n) { return new (buffer) FooAligned[n]; }
// CSV-NEXT: 0,<unknown>,?,"{{.+}}csetbounds-stats-operator-new.cpp:[[@LINE-1]]:78","non-allocating placement new","for type struct FooAligned"

// CSV-EMPTY:
