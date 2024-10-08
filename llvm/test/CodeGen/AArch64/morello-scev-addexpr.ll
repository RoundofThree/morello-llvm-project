; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -loop-reduce -target-abi purecap -march=aarch64 -mattr=+morello,+c64 -o -  %s | FileCheck %s

target datalayout = "e-m:e-pf200:128:128:128:64-i8:8:32-i16:16:32-i64:64-i128:128-n32:64-S128-A200-P200-G200"
target triple = "aarch64-none--elf"

; Expand the integer part of a capability instead of constructing GEPs in the outer loops.
; This avoids the case where the GEPs would clear the tag of the capability.

define void @foo(i32 %x, i32 %y, i64 %z, i32 %u, i32 %v, i64 %end) addrspace(200) {
; CHECK-LABEL: @foo(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[CALL68:%.*]] = call double addrspace(200)* @bar()
; CHECK-NEXT:    [[CALL681:%.*]] = bitcast double addrspace(200)* [[CALL68]] to i8 addrspace(200)*
; CHECK-NEXT:    [[TMP0:%.*]] = sext i32 [[X:%.*]] to i64
; CHECK-NEXT:    [[TMP1:%.*]] = sub i64 0, [[END:%.*]]
; CHECK-NEXT:    [[TMP2:%.*]] = mul nsw i64 [[TMP0]], -8
; CHECK-NEXT:    [[TMP3:%.*]] = shl i64 [[Z:%.*]], 3
; CHECK-NEXT:    br label [[FOR_COND930_PREHEADER_US_US:%.*]]
; CHECK:       for.cond930.preheader.us.us:
; CHECK-NEXT:    [[IA_11463_US_US:%.*]] = phi i32 [ [[ADD960_US_US:%.*]], [[FOR_COND930_FOR_END_CRIT_EDGE_US_US:%.*]] ], [ [[Y:%.*]], [[ENTRY:%.*]] ]
; CHECK-NEXT:    [[TMP4:%.*]] = sext i32 [[IA_11463_US_US]] to i64
; CHECK-NEXT:    [[TMP5:%.*]] = add i64 [[TMP1]], [[TMP4]]
; CHECK-NEXT:    [[TMP6:%.*]] = shl nsw i64 [[TMP4]], 3
; CHECK-NEXT:    [[TMP7:%.*]] = add i64 [[TMP2]], [[TMP6]]
; CHECK-NEXT:    [[UGLYGEP:%.*]] = getelementptr i8, i8 addrspace(200)* [[CALL681]], i64 [[TMP7]]
; CHECK-NEXT:    [[UGLYGEP2:%.*]] = bitcast i8 addrspace(200)* [[UGLYGEP]] to double addrspace(200)*
; CHECK-NEXT:    br label [[FOR_BODY932_US_US:%.*]]
; CHECK:       for.cond930.for.end_crit_edge.us.us:
; CHECK-NEXT:    [[ADD960_US_US]] = add nsw i32 [[U:%.*]], [[V:%.*]]
; CHECK-NEXT:    br label [[FOR_COND930_PREHEADER_US_US]]
; CHECK:       for.body932.us.us:
; CHECK-NEXT:    [[LSR_IV3:%.*]] = phi double addrspace(200)* [ [[TMP9:%.*]], [[FOR_BODY932_US_US]] ], [ [[UGLYGEP2]], [[FOR_COND930_PREHEADER_US_US]] ]
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i64 [ [[LSR_IV_NEXT:%.*]], [[FOR_BODY932_US_US]] ], [ [[TMP5]], [[FOR_COND930_PREHEADER_US_US]] ]
; CHECK-NEXT:    [[LSR_IV34:%.*]] = bitcast double addrspace(200)* [[LSR_IV3]] to i8 addrspace(200)*
; CHECK-NEXT:    [[TMP8:%.*]] = load double, double addrspace(200)* [[LSR_IV3]], align 8
; CHECK-NEXT:    [[LSR_IV_NEXT]] = add i64 [[LSR_IV]], [[Z]]
; CHECK-NEXT:    [[UGLYGEP5:%.*]] = getelementptr i8, i8 addrspace(200)* [[LSR_IV34]], i64 [[TMP3]]
; CHECK-NEXT:    [[TMP9]] = bitcast i8 addrspace(200)* [[UGLYGEP5]] to double addrspace(200)*
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i64 [[LSR_IV_NEXT]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[FOR_COND930_FOR_END_CRIT_EDGE_US_US]], label [[FOR_BODY932_US_US]]
;
entry:
  %call68 = call double addrspace(200)* @bar()
  %0 = sext i32 %x to i64
  br label %for.cond930.preheader.us.us

for.cond930.preheader.us.us:
  %iA.11463.us.us = phi i32 [ %add960.us.us, %for.cond930.for.end_crit_edge.us.us ], [ %y, %entry ]
  %1 = sext i32 %iA.11463.us.us to i64
  br label %for.body932.us.us

for.cond930.for.end_crit_edge.us.us:
  %add960.us.us = add nsw i32 %u, %v
  br label %for.cond930.preheader.us.us

for.body932.us.us:
  %indvars.iv1537 = phi i64 [ %indvars.iv.next1538, %for.body932.us.us ], [ %1, %for.cond930.preheader.us.us ]
  %2 = sub nsw i64 %indvars.iv1537, %0
  %arrayidx940.us.us = getelementptr inbounds double, double addrspace(200)* %call68, i64 %2
  %3 = load double, double addrspace(200)* %arrayidx940.us.us, align 8
  %indvars.iv.next1538 = add i64 %indvars.iv1537, %z
  %cmp = icmp eq i64 %indvars.iv.next1538, %end
  br i1 %cmp, label %for.cond930.for.end_crit_edge.us.us, label %for.body932.us.us
}

declare double addrspace(200)* @bar() addrspace(200)
