; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc < %s -mtriple=i686-unknown-unknown | FileCheck %s --check-prefix=X32
; RUN: llc < %s -mtriple=x86_64-unknown-unknown | FileCheck %s --check-prefix=X64

define i16 @foo(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: foo:
; X32:       # %bb.0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    rolw %cl, %ax
; X32-NEXT:    retl
;
; X64-LABEL: foo:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    rolw %cl, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = shl i16 %x, %z
	%t1 = sub i16 16, %z
	%t2 = lshr i16 %x, %t1
	%t3 = or i16 %t2, %t0
	ret i16 %t3
}

define i16 @bar(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: bar:
; X32:       # %bb.0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    shldw %cl, %dx, %ax
; X32-NEXT:    retl
;
; X64-LABEL: bar:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    shldw %cl, %di, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = shl i16 %y, %z
	%t1 = sub i16 16, %z
	%t2 = lshr i16 %x, %t1
	%t3 = or i16 %t2, %t0
	ret i16 %t3
}

define i16 @un(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: un:
; X32:       # %bb.0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    rorw %cl, %ax
; X32-NEXT:    retl
;
; X64-LABEL: un:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    rorw %cl, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = lshr i16 %x, %z
	%t1 = sub i16 16, %z
	%t2 = shl i16 %x, %t1
	%t3 = or i16 %t2, %t0
	ret i16 %t3
}

define i16 @bu(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: bu:
; X32:       # %bb.0:
; X32-NEXT:    movb {{[0-9]+}}(%esp), %cl
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %edx
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    shrdw %cl, %dx, %ax
; X32-NEXT:    retl
;
; X64-LABEL: bu:
; X64:       # %bb.0:
; X64-NEXT:    movl %edx, %ecx
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    # kill: def $cl killed $cl killed $ecx
; X64-NEXT:    shrdw %cl, %di, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = lshr i16 %y, %z
	%t1 = sub i16 16, %z
	%t2 = shl i16 %x, %t1
	%t3 = or i16 %t2, %t0
	ret i16 %t3
}

define i16 @xfoo(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: xfoo:
; X32:       # %bb.0:
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    rolw $5, %ax
; X32-NEXT:    retl
;
; X64-LABEL: xfoo:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    rolw $5, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = lshr i16 %x, 11
	%t1 = shl i16 %x, 5
	%t2 = or i16 %t0, %t1
	ret i16 %t2
}

define i16 @xbar(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: xbar:
; X32:       # %bb.0:
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    shldw $5, %cx, %ax
; X32-NEXT:    retl
;
; X64-LABEL: xbar:
; X64:       # %bb.0:
; X64-NEXT:    movl %esi, %eax
; X64-NEXT:    shldw $5, %di, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = shl i16 %y, 5
	%t1 = lshr i16 %x, 11
	%t2 = or i16 %t0, %t1
	ret i16 %t2
}

define i16 @xun(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: xun:
; X32:       # %bb.0:
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    rolw $11, %ax
; X32-NEXT:    retl
;
; X64-LABEL: xun:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    rolw $11, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = lshr i16 %x, 5
	%t1 = shl i16 %x, 11
	%t2 = or i16 %t0, %t1
	ret i16 %t2
}

define i16 @xbu(i16 %x, i16 %y, i16 %z) nounwind {
; X32-LABEL: xbu:
; X32:       # %bb.0:
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %ecx
; X32-NEXT:    movzwl {{[0-9]+}}(%esp), %eax
; X32-NEXT:    shldw $11, %cx, %ax
; X32-NEXT:    retl
;
; X64-LABEL: xbu:
; X64:       # %bb.0:
; X64-NEXT:    movl %edi, %eax
; X64-NEXT:    shldw $11, %si, %ax
; X64-NEXT:    # kill: def $ax killed $ax killed $eax
; X64-NEXT:    retq
	%t0 = lshr i16 %y, 5
	%t1 = shl i16 %x, 11
	%t2 = or i16 %t0, %t1
	ret i16 %t2
}
