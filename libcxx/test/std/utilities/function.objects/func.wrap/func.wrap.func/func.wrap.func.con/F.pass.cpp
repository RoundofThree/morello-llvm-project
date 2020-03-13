//===----------------------------------------------------------------------===//
//
// Part of the LLVM Project, under the Apache License v2.0 with LLVM Exceptions.
// See https://llvm.org/LICENSE.txt for license information.
// SPDX-License-Identifier: Apache-2.0 WITH LLVM-exception
//
//===----------------------------------------------------------------------===//

// <functional>

// class function<R(ArgTypes...)>

// function(F);

#include <functional>
#include <cassert>

#include "test_macros.h"
#include "count_new.h"

class A
{
    int data_[10];
public:
    static int count;

    A()
    {
        ++count;
        for (int i = 0; i < 10; ++i)
            data_[i] = i;
    }

    A(const A&) {++count;}

    ~A() {--count;}

    int operator()(int i) const
    {
        for (int j = 0; j < 10; ++j)
            i += data_[j];
        return i;
    }

    int foo(int) const {return 1;}
};

int A::count = 0;

int g(int) {return 0;}

#if TEST_STD_VER >= 11
struct RValueCallable {
    template <class ...Args>
    void operator()(Args&&...) && {}
};
struct LValueCallable {
    template <class ...Args>
    void operator()(Args&&...) & {}
};
#endif

int main(int, char**)
{
    globalMemCounter.reset();
    assert(globalMemCounter.checkOutstandingNewEq(0));
    {
    std::function<int(int)> f = A();
    assert(A::count == 1);
    assert(globalMemCounter.checkOutstandingNewEq(1));
#ifndef _LIBCPP_NO_RTTI
    assert(f.target<A>());
    assert(f.target<int(*)(int)>() == 0);
#endif
    }
    assert(A::count == 0);
    assert(globalMemCounter.checkOutstandingNewEq(0));
    {
    std::function<int(int)> f = g;
    assert(globalMemCounter.checkOutstandingNewEq(0));
#ifndef _LIBCPP_NO_RTTI
    assert(f.target<int(*)(int)>());
    assert(f.target<A>() == 0);
#endif
    }
    assert(globalMemCounter.checkOutstandingNewEq(0));
    {
    std::function<int(int)> f = (int (*)(int))0;
    assert(!f);
    assert(globalMemCounter.checkOutstandingNewEq(0));
#ifndef _LIBCPP_NO_RTTI
    assert(f.target<int(*)(int)>() == 0);
    assert(f.target<A>() == 0);
#endif
    }
    {
    std::function<int(const A*, int)> f = &A::foo;
    assert(f);
    assert(globalMemCounter.checkOutstandingNewEq(0));
#ifndef _LIBCPP_NO_RTTI
    assert(f.target<int (A::*)(int) const>() != 0);
#endif
    }
    {
      std::function<void(int)> f(&g);
      assert(f);
#ifndef _LIBCPP_NO_RTTI
      assert(f.target<int(*)(int)>() != 0);
#endif
      f(1);
    }
    {
        std::function <void()> f(static_cast<void (*)()>(0));
        assert(!f);
    }
#if TEST_STD_VER >= 11
    {
        using Fn = std::function<void(int, int, int)>;
        static_assert(std::is_constructible<Fn, LValueCallable&>::value, "");
        static_assert(std::is_constructible<Fn, LValueCallable>::value, "");
        static_assert(!std::is_constructible<Fn, RValueCallable&>::value, "");
        static_assert(!std::is_constructible<Fn, RValueCallable>::value, "");
    }
#endif

  return 0;
}
