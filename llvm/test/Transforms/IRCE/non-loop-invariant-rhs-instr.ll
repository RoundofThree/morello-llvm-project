; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt -S -irce -verify-loop-info -verify < %s 2>&1 | FileCheck %s
; RUN: opt -S -passes=irce -verify-loop-info -verify < %s 2>&1 | FileCheck %s

define i32 @test_01(i32 %A, i64 %Len, i32 *%array) {
; CHECK-LABEL: @test_01(
; CHECK-NEXT:  preheader:
; CHECK-NEXT:    [[TRIPCHECK:%.*]] = icmp sgt i64 [[LEN:%.*]], 2
; CHECK-NEXT:    br i1 [[TRIPCHECK]], label [[LOOP_PREHEADER:%.*]], label [[ZERO:%.*]]
; CHECK:       loop.preheader:
; CHECK-NEXT:    [[TMP0:%.*]] = zext i32 [[A:%.*]] to i64
; CHECK-NEXT:    [[TMP1:%.*]] = add nuw nsw i64 [[TMP0]], 1
; CHECK-NEXT:    [[TMP2:%.*]] = icmp slt i64 [[LEN]], 0
; CHECK-NEXT:    [[SMIN:%.*]] = select i1 [[TMP2]], i64 [[LEN]], i64 0
; CHECK-NEXT:    [[TMP3:%.*]] = sub i64 [[LEN]], [[SMIN]]
; CHECK-NEXT:    [[TMP4:%.*]] = icmp ult i64 [[TMP3]], [[TMP1]]
; CHECK-NEXT:    [[UMIN:%.*]] = select i1 [[TMP4]], i64 [[TMP3]], i64 [[TMP1]]
; CHECK-NEXT:    [[TMP5:%.*]] = icmp ugt i64 [[UMIN]], 1
; CHECK-NEXT:    [[EXIT_MAINLOOP_AT:%.*]] = select i1 [[TMP5]], i64 [[UMIN]], i64 1
; CHECK-NEXT:    [[TMP6:%.*]] = icmp ult i64 1, [[EXIT_MAINLOOP_AT]]
; CHECK-NEXT:    br i1 [[TMP6]], label [[LOOP_PREHEADER2:%.*]], label [[MAIN_PSEUDO_EXIT:%.*]]
; CHECK:       loop.preheader2:
; CHECK-NEXT:    br label [[LOOP:%.*]]
; CHECK:       loop:
; CHECK-NEXT:    [[INDVAR:%.*]] = phi i64 [ [[INDVAR_NEXT:%.*]], [[LATCH:%.*]] ], [ 1, [[LOOP_PREHEADER2]] ]
; CHECK-NEXT:    [[TMP7:%.*]] = icmp ult i64 [[INDVAR]], [[LEN]]
; CHECK-NEXT:    br i1 true, label [[GUARDED:%.*]], label [[DEOPT_LOOPEXIT3:%.*]]
; CHECK:       guarded:
; CHECK-NEXT:    [[ADDR:%.*]] = getelementptr inbounds i32, i32* [[ARRAY:%.*]], i64 [[INDVAR]]
; CHECK-NEXT:    [[RES:%.*]] = load i32, i32* [[ADDR]]
; CHECK-NEXT:    [[CMP:%.*]] = icmp eq i32 [[RES]], 0
; CHECK-NEXT:    br i1 [[CMP]], label [[ZERO_LOOPEXIT_LOOPEXIT4:%.*]], label [[LATCH]]
; CHECK:       latch:
; CHECK-NEXT:    [[INDVAR_NEXT]] = add nuw nsw i64 [[INDVAR]], 2
; CHECK-NEXT:    [[RES2:%.*]] = mul i32 [[RES]], 3
; CHECK-NEXT:    [[TMP8:%.*]] = zext i32 [[A]] to i64
; CHECK-NEXT:    [[CMP2:%.*]] = icmp ugt i64 [[INDVAR_NEXT]], [[TMP8]]
; CHECK-NEXT:    [[TMP9:%.*]] = icmp ult i64 [[INDVAR_NEXT]], [[EXIT_MAINLOOP_AT]]
; CHECK-NEXT:    [[TMP10:%.*]] = xor i1 [[TMP9]], true
; CHECK-NEXT:    br i1 [[TMP10]], label [[MAIN_EXIT_SELECTOR:%.*]], label [[LOOP]]
; CHECK:       main.exit.selector:
; CHECK-NEXT:    [[INDVAR_NEXT_LCSSA:%.*]] = phi i64 [ [[INDVAR_NEXT]], [[LATCH]] ]
; CHECK-NEXT:    [[RES2_LCSSA1:%.*]] = phi i32 [ [[RES2]], [[LATCH]] ]
; CHECK-NEXT:    [[TMP11:%.*]] = icmp ult i64 [[INDVAR_NEXT_LCSSA]], [[TMP1]]
; CHECK-NEXT:    br i1 [[TMP11]], label [[MAIN_PSEUDO_EXIT]], label [[LOOPEXIT:%.*]]
; CHECK:       main.pseudo.exit:
; CHECK-NEXT:    [[INDVAR_COPY:%.*]] = phi i64 [ 1, [[LOOP_PREHEADER]] ], [ [[INDVAR_NEXT_LCSSA]], [[MAIN_EXIT_SELECTOR]] ]
; CHECK-NEXT:    [[INDVAR_END:%.*]] = phi i64 [ 1, [[LOOP_PREHEADER]] ], [ [[INDVAR_NEXT_LCSSA]], [[MAIN_EXIT_SELECTOR]] ]
; CHECK-NEXT:    br label [[POSTLOOP:%.*]]
; CHECK:       loopexit.loopexit:
; CHECK-NEXT:    [[RES2_LCSSA_PH:%.*]] = phi i32 [ [[RES2_POSTLOOP:%.*]], [[LATCH_POSTLOOP:%.*]] ]
; CHECK-NEXT:    br label [[LOOPEXIT]]
; CHECK:       loopexit:
; CHECK-NEXT:    [[RES2_LCSSA:%.*]] = phi i32 [ [[RES2_LCSSA1]], [[MAIN_EXIT_SELECTOR]] ], [ [[RES2_LCSSA_PH]], [[LOOPEXIT_LOOPEXIT:%.*]] ]
; CHECK-NEXT:    ret i32 [[RES2_LCSSA]]
; CHECK:       zero.loopexit.loopexit:
; CHECK-NEXT:    br label [[ZERO_LOOPEXIT:%.*]]
; CHECK:       zero.loopexit.loopexit4:
; CHECK-NEXT:    br label [[ZERO_LOOPEXIT]]
; CHECK:       zero.loopexit:
; CHECK-NEXT:    br label [[ZERO]]
; CHECK:       zero:
; CHECK-NEXT:    ret i32 0
; CHECK:       deopt.loopexit:
; CHECK-NEXT:    br label [[DEOPT:%.*]]
; CHECK:       deopt.loopexit3:
; CHECK-NEXT:    br label [[DEOPT]]
; CHECK:       deopt:
; CHECK-NEXT:    ret i32 1
; CHECK:       postloop:
; CHECK-NEXT:    br label [[LOOP_POSTLOOP:%.*]]
; CHECK:       loop.postloop:
; CHECK-NEXT:    [[INDVAR_POSTLOOP:%.*]] = phi i64 [ [[INDVAR_NEXT_POSTLOOP:%.*]], [[LATCH_POSTLOOP]] ], [ [[INDVAR_COPY]], [[POSTLOOP]] ]
; CHECK-NEXT:    [[TMP12:%.*]] = icmp ult i64 [[INDVAR_POSTLOOP]], [[LEN]]
; CHECK-NEXT:    br i1 [[TMP12]], label [[GUARDED_POSTLOOP:%.*]], label [[DEOPT_LOOPEXIT:%.*]]
; CHECK:       guarded.postloop:
; CHECK-NEXT:    [[ADDR_POSTLOOP:%.*]] = getelementptr inbounds i32, i32* [[ARRAY]], i64 [[INDVAR_POSTLOOP]]
; CHECK-NEXT:    [[RES_POSTLOOP:%.*]] = load i32, i32* [[ADDR_POSTLOOP]]
; CHECK-NEXT:    [[CMP_POSTLOOP:%.*]] = icmp eq i32 [[RES_POSTLOOP]], 0
; CHECK-NEXT:    br i1 [[CMP_POSTLOOP]], label [[ZERO_LOOPEXIT_LOOPEXIT:%.*]], label [[LATCH_POSTLOOP]]
; CHECK:       latch.postloop:
; CHECK-NEXT:    [[INDVAR_NEXT_POSTLOOP]] = add nuw nsw i64 [[INDVAR_POSTLOOP]], 2
; CHECK-NEXT:    [[RES2_POSTLOOP]] = mul i32 [[RES_POSTLOOP]], 3
; CHECK-NEXT:    [[TMP13:%.*]] = zext i32 [[A]] to i64
; CHECK-NEXT:    [[CMP2_POSTLOOP:%.*]] = icmp ugt i64 [[INDVAR_NEXT_POSTLOOP]], [[TMP13]]
; CHECK-NEXT:    br i1 [[CMP2_POSTLOOP]], label [[LOOPEXIT_LOOPEXIT]], label [[LOOP_POSTLOOP]], !llvm.loop !0, !irce.loop.clone !5
;
preheader:
  %tripcheck = icmp sgt i64 %Len, 2
  br i1 %tripcheck, label %loop, label %zero

loop:
  %indvar = phi i64 [ 1, %preheader ], [ %indvar.next, %latch ]
  %0 = icmp ult i64 %indvar, %Len
  br i1 %0, label %guarded, label %deopt

guarded:
  %addr = getelementptr inbounds i32, i32* %array, i64 %indvar
  %res = load i32, i32* %addr
  %cmp = icmp eq i32 %res, 0
  br i1 %cmp, label %zero, label %latch

latch:
  %indvar.next = add nuw nsw i64 %indvar, 2
  %res2 = mul i32 %res, 3
; NOTE: this is loop invariant value, but not loop invariant instruction!
  %1 = zext i32 %A to i64
  %cmp2 = icmp ugt i64 %indvar.next, %1
  br i1 %cmp2, label %loopexit, label %loop

loopexit:
  ret i32 %res2

zero:
  ret i32 0

deopt:
  ret i32 1

}
