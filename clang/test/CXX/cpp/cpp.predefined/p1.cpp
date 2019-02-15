// RUN: %clang_cc1 -std=c++1z %s -verify -triple x86_64-linux-gnu -DALIGN=16
// RUN: %clang_cc1 -std=c++1z %s -verify -fnew-alignment=2 -DALIGN=2
// RUN: %clang_cc1 -std=c++1z %s -verify -fnew-alignment=256 -DALIGN=256

// Check that the default new alignment for CHERI is capability size
// RUN: %cheri128_cc1 -std=c++1z %s -verify -DALIGN=16
// RUN: %cheri256_cc1 -std=c++1z %s -verify -DALIGN=32


// expected-no-diagnostics

#if ALIGN != __STDCPP_DEFAULT_NEW_ALIGNMENT__
#error wrong value for __STDCPP_DEFAULT_NEW_ALIGNMENT__
#endif
