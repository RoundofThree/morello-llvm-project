; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -loop-reduce -S | FileCheck %s

target datalayout = "e-m:x-p:32:32-i64:64-f80:32-n8:16:32-a:0:32-S32"
target triple = "i686-pc-windows-msvc"

declare i32 @_except_handler3(...)
declare i32 @__CxxFrameHandler3(...)

declare void @external(i32*)
declare void @reserve()

define void @f() personality i32 (...)* @_except_handler3 {
; CHECK-LABEL: @f(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[THROW:%.*]]
; CHECK:       throw:
; CHECK-NEXT:    [[TMP96:%.*]] = getelementptr inbounds i8, i8* undef, i32 1
; CHECK-NEXT:    invoke void @reserve()
; CHECK-NEXT:    to label [[THROW]] unwind label [[PAD:%.*]]
; CHECK:       pad:
; CHECK-NEXT:    [[PHI2:%.*]] = phi i8* [ [[TMP96]], [[THROW]] ]
; CHECK-NEXT:    [[CS:%.*]] = catchswitch within none [label %unreachable] unwind label [[BLAH2:%.*]]
; CHECK:       unreachable:
; CHECK-NEXT:    [[TMP0:%.*]] = catchpad within [[CS]] []
; CHECK-NEXT:    unreachable
; CHECK:       blah2:
; CHECK-NEXT:    [[CLEANUPPADI4_I_I_I:%.*]] = cleanuppad within none []
; CHECK-NEXT:    [[PHI21:%.*]] = ptrtoint i8* [[PHI2]] to i32
; CHECK-NEXT:    [[TMP1:%.*]] = sub i32 1, [[PHI21]]
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, i8* undef, i32 [[TMP1]]
; CHECK-NEXT:    br label [[LOOP_BODY:%.*]]
; CHECK:       loop_body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i8* [ [[SCEVGEP2:%.*]], [[ITER:%.*]] ], [ [[SCEVGEP]], [[BLAH2]] ]
; CHECK-NEXT:    [[SCEVGEP2]] = getelementptr i8, i8* [[LSR_IV]], i32 -1
; CHECK-NEXT:    [[TMP100:%.*]] = icmp eq i8* [[SCEVGEP2]], null
; CHECK-NEXT:    br i1 [[TMP100]], label [[UNWIND_OUT:%.*]], label [[ITER]]
; CHECK:       iter:
; CHECK-NEXT:    br i1 true, label [[UNWIND_OUT]], label [[LOOP_BODY]]
; CHECK:       unwind_out:
; CHECK-NEXT:    cleanupret from [[CLEANUPPADI4_I_I_I]] unwind to caller
;
entry:
  br label %throw

throw:                                            ; preds = %throw, %entry
  %tmp96 = getelementptr inbounds i8, i8* undef, i32 1
  invoke void @reserve()
  to label %throw unwind label %pad

pad:                                              ; preds = %throw
  %phi2 = phi i8* [ %tmp96, %throw ]
  %cs = catchswitch within none [label %unreachable] unwind label %blah2

unreachable:
  catchpad within %cs []
  unreachable

blah2:
  %cleanuppadi4.i.i.i = cleanuppad within none []
  br label %loop_body

loop_body:                                        ; preds = %iter, %pad
  %tmp99 = phi i8* [ %tmp101, %iter ], [ %phi2, %blah2 ]
  %tmp100 = icmp eq i8* %tmp99, undef
  br i1 %tmp100, label %unwind_out, label %iter

iter:                                             ; preds = %loop_body
  %tmp101 = getelementptr inbounds i8, i8* %tmp99, i32 1
  br i1 undef, label %unwind_out, label %loop_body

unwind_out:                                       ; preds = %iter, %loop_body
  cleanupret from %cleanuppadi4.i.i.i unwind to caller
}

define void @g() personality i32 (...)* @_except_handler3 {
; CHECK-LABEL: @g(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[THROW:%.*]]
; CHECK:       throw:
; CHECK-NEXT:    [[TMP96:%.*]] = getelementptr inbounds i8, i8* undef, i32 1
; CHECK-NEXT:    invoke void @reserve()
; CHECK-NEXT:    to label [[THROW]] unwind label [[PAD:%.*]]
; CHECK:       pad:
; CHECK-NEXT:    [[PHI2:%.*]] = phi i8* [ [[TMP96]], [[THROW]] ]
; CHECK-NEXT:    [[CS:%.*]] = catchswitch within none [label [[UNREACHABLE:%.*]], label %blah] unwind to caller
; CHECK:       unreachable:
; CHECK-NEXT:    [[TMP0:%.*]] = catchpad within [[CS]] []
; CHECK-NEXT:    unreachable
; CHECK:       blah:
; CHECK-NEXT:    [[CATCHPAD:%.*]] = catchpad within [[CS]] []
; CHECK-NEXT:    [[PHI21:%.*]] = ptrtoint i8* [[PHI2]] to i32
; CHECK-NEXT:    [[TMP1:%.*]] = sub i32 1, [[PHI21]]
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, i8* undef, i32 [[TMP1]]
; CHECK-NEXT:    br label [[LOOP_BODY:%.*]]
; CHECK:       unwind_out:
; CHECK-NEXT:    catchret from [[CATCHPAD]] to label [[LEAVE:%.*]]
; CHECK:       leave:
; CHECK-NEXT:    ret void
; CHECK:       loop_body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i8* [ [[SCEVGEP2:%.*]], [[ITER:%.*]] ], [ [[SCEVGEP]], [[BLAH:%.*]] ]
; CHECK-NEXT:    [[SCEVGEP2]] = getelementptr i8, i8* [[LSR_IV]], i32 -1
; CHECK-NEXT:    [[TMP100:%.*]] = icmp eq i8* [[SCEVGEP2]], null
; CHECK-NEXT:    br i1 [[TMP100]], label [[UNWIND_OUT:%.*]], label [[ITER]]
; CHECK:       iter:
; CHECK-NEXT:    br i1 true, label [[UNWIND_OUT]], label [[LOOP_BODY]]
;
entry:
  br label %throw

throw:                                            ; preds = %throw, %entry
  %tmp96 = getelementptr inbounds i8, i8* undef, i32 1
  invoke void @reserve()
  to label %throw unwind label %pad

pad:
  %phi2 = phi i8* [ %tmp96, %throw ]
  %cs = catchswitch within none [label %unreachable, label %blah] unwind to caller

unreachable:
  catchpad within %cs []
  unreachable

blah:
  %catchpad = catchpad within %cs []
  br label %loop_body

unwind_out:
  catchret from %catchpad to label %leave

leave:
  ret void

loop_body:                                        ; preds = %iter, %pad
  %tmp99 = phi i8* [ %tmp101, %iter ], [ %phi2, %blah ]
  %tmp100 = icmp eq i8* %tmp99, undef
  br i1 %tmp100, label %unwind_out, label %iter

iter:                                             ; preds = %loop_body
  %tmp101 = getelementptr inbounds i8, i8* %tmp99, i32 1
  br i1 undef, label %unwind_out, label %loop_body
}

define void @h() personality i32 (...)* @_except_handler3 {
; CHECK-LABEL: @h(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[THROW:%.*]]
; CHECK:       throw:
; CHECK-NEXT:    [[TMP96:%.*]] = getelementptr inbounds i8, i8* undef, i32 1
; CHECK-NEXT:    invoke void @reserve()
; CHECK-NEXT:    to label [[THROW]] unwind label [[PAD:%.*]]
; CHECK:       pad:
; CHECK-NEXT:    [[CS:%.*]] = catchswitch within none [label [[UNREACHABLE:%.*]], label %blug] unwind to caller
; CHECK:       unreachable:
; CHECK-NEXT:    [[TMP0:%.*]] = catchpad within [[CS]] []
; CHECK-NEXT:    unreachable
; CHECK:       blug:
; CHECK-NEXT:    [[PHI2:%.*]] = phi i8* [ [[TMP96]], [[PAD]] ]
; CHECK-NEXT:    [[CATCHPAD:%.*]] = catchpad within [[CS]] []
; CHECK-NEXT:    [[PHI21:%.*]] = ptrtoint i8* [[PHI2]] to i32
; CHECK-NEXT:    [[TMP1:%.*]] = sub i32 1, [[PHI21]]
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, i8* undef, i32 [[TMP1]]
; CHECK-NEXT:    br label [[LOOP_BODY:%.*]]
; CHECK:       unwind_out:
; CHECK-NEXT:    catchret from [[CATCHPAD]] to label [[LEAVE:%.*]]
; CHECK:       leave:
; CHECK-NEXT:    ret void
; CHECK:       loop_body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i8* [ [[SCEVGEP2:%.*]], [[ITER:%.*]] ], [ [[SCEVGEP]], [[BLUG:%.*]] ]
; CHECK-NEXT:    [[SCEVGEP2]] = getelementptr i8, i8* [[LSR_IV]], i32 -1
; CHECK-NEXT:    [[TMP100:%.*]] = icmp eq i8* [[SCEVGEP2]], null
; CHECK-NEXT:    br i1 [[TMP100]], label [[UNWIND_OUT:%.*]], label [[ITER]]
; CHECK:       iter:
; CHECK-NEXT:    br i1 true, label [[UNWIND_OUT]], label [[LOOP_BODY]]
;
entry:
  br label %throw

throw:                                            ; preds = %throw, %entry
  %tmp96 = getelementptr inbounds i8, i8* undef, i32 1
  invoke void @reserve()
  to label %throw unwind label %pad

pad:
  %cs = catchswitch within none [label %unreachable, label %blug] unwind to caller

unreachable:
  catchpad within %cs []
  unreachable

blug:
  %phi2 = phi i8* [ %tmp96, %pad ]
  %catchpad = catchpad within %cs []
  br label %loop_body

unwind_out:
  catchret from %catchpad to label %leave

leave:
  ret void

loop_body:                                        ; preds = %iter, %pad
  %tmp99 = phi i8* [ %tmp101, %iter ], [ %phi2, %blug ]
  %tmp100 = icmp eq i8* %tmp99, undef
  br i1 %tmp100, label %unwind_out, label %iter

iter:                                             ; preds = %loop_body
  %tmp101 = getelementptr inbounds i8, i8* %tmp99, i32 1
  br i1 undef, label %unwind_out, label %loop_body
}

define void @i() personality i32 (...)* @_except_handler3 {
; CHECK-LABEL: @i(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[THROW:%.*]]
; CHECK:       throw:
; CHECK-NEXT:    [[TMP96:%.*]] = getelementptr inbounds i8, i8* undef, i32 1
; CHECK-NEXT:    invoke void @reserve()
; CHECK-NEXT:    to label [[THROW]] unwind label [[CATCHPAD:%.*]]
; CHECK:       catchpad:
; CHECK-NEXT:    [[PHI2:%.*]] = phi i8* [ [[TMP96]], [[THROW]] ]
; CHECK-NEXT:    [[CS:%.*]] = catchswitch within none [label %cp_body] unwind label [[CLEANUPPAD:%.*]]
; CHECK:       cp_body:
; CHECK-NEXT:    [[TMP0:%.*]] = catchpad within [[CS]] []
; CHECK-NEXT:    br label [[LOOP_HEAD:%.*]]
; CHECK:       cleanuppad:
; CHECK-NEXT:    [[TMP1:%.*]] = cleanuppad within none []
; CHECK-NEXT:    br label [[LOOP_HEAD]]
; CHECK:       loop_head:
; CHECK-NEXT:    [[PHI21:%.*]] = ptrtoint i8* [[PHI2]] to i32
; CHECK-NEXT:    [[TMP2:%.*]] = sub i32 1, [[PHI21]]
; CHECK-NEXT:    [[SCEVGEP:%.*]] = getelementptr i8, i8* undef, i32 [[TMP2]]
; CHECK-NEXT:    br label [[LOOP_BODY:%.*]]
; CHECK:       loop_body:
; CHECK-NEXT:    [[LSR_IV:%.*]] = phi i8* [ [[SCEVGEP2:%.*]], [[ITER:%.*]] ], [ [[SCEVGEP]], [[LOOP_HEAD]] ]
; CHECK-NEXT:    [[SCEVGEP2]] = getelementptr i8, i8* [[LSR_IV]], i32 -1
; CHECK-NEXT:    [[TMP100:%.*]] = icmp eq i8* [[SCEVGEP2]], null
; CHECK-NEXT:    br i1 [[TMP100]], label [[UNWIND_OUT:%.*]], label [[ITER]]
; CHECK:       iter:
; CHECK-NEXT:    br i1 true, label [[UNWIND_OUT]], label [[LOOP_BODY]]
; CHECK:       unwind_out:
; CHECK-NEXT:    unreachable
;
entry:
  br label %throw

throw:                                            ; preds = %throw, %entry
  %tmp96 = getelementptr inbounds i8, i8* undef, i32 1
  invoke void @reserve()
  to label %throw unwind label %catchpad

catchpad:                                              ; preds = %throw
  %phi2 = phi i8* [ %tmp96, %throw ]
  %cs = catchswitch within none [label %cp_body] unwind label %cleanuppad

cp_body:
  catchpad within %cs []
  br label %loop_head

cleanuppad:
  cleanuppad within none []
  br label %loop_head

loop_head:
  br label %loop_body

loop_body:                                        ; preds = %iter, %catchpad
  %tmp99 = phi i8* [ %tmp101, %iter ], [ %phi2, %loop_head ]
  %tmp100 = icmp eq i8* %tmp99, undef
  br i1 %tmp100, label %unwind_out, label %iter

iter:                                             ; preds = %loop_body
  %tmp101 = getelementptr inbounds i8, i8* %tmp99, i32 1
  br i1 undef, label %unwind_out, label %loop_body

unwind_out:                                       ; preds = %iter, %loop_body
  unreachable
}

define void @test1(i32* %b, i32* %c) personality i32 (...)* @__CxxFrameHandler3 {
; CHECK-LABEL: @test1(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_COND:%.*]]
; CHECK:       for.cond:
; CHECK-NEXT:    [[D_0:%.*]] = phi i32* [ [[B:%.*]], [[ENTRY:%.*]] ], [ [[INCDEC_PTR:%.*]], [[FOR_INC:%.*]] ]
; CHECK-NEXT:    invoke void @external(i32* [[D_0]])
; CHECK-NEXT:    to label [[FOR_INC]] unwind label [[CATCH_DISPATCH:%.*]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INCDEC_PTR]] = getelementptr inbounds i32, i32* [[D_0]], i32 1
; CHECK-NEXT:    br label [[FOR_COND]]
; CHECK:       catch.dispatch:
; CHECK-NEXT:    [[CS:%.*]] = catchswitch within none [label %catch] unwind label [[CATCH_DISPATCH_2:%.*]]
; CHECK:       catch:
; CHECK-NEXT:    [[TMP0:%.*]] = catchpad within [[CS]] [i8* null, i32 64, i8* null]
; CHECK-NEXT:    catchret from [[TMP0]] to label [[TRY_CONT:%.*]]
; CHECK:       try.cont:
; CHECK-NEXT:    invoke void @external(i32* [[C:%.*]])
; CHECK-NEXT:    to label [[TRY_CONT_7:%.*]] unwind label [[CATCH_DISPATCH_2]]
; CHECK:       catch.dispatch.2:
; CHECK-NEXT:    [[E_0:%.*]] = phi i32* [ [[C]], [[TRY_CONT]] ], [ [[B]], [[CATCH_DISPATCH]] ]
; CHECK-NEXT:    [[CS2:%.*]] = catchswitch within none [label %catch.4] unwind to caller
; CHECK:       catch.4:
; CHECK-NEXT:    [[TMP1:%.*]] = catchpad within [[CS2]] [i8* null, i32 64, i8* null]
; CHECK-NEXT:    unreachable
; CHECK:       try.cont.7:
; CHECK-NEXT:    ret void
;
entry:
  br label %for.cond

for.cond:                                         ; preds = %for.inc, %entry
  %d.0 = phi i32* [ %b, %entry ], [ %incdec.ptr, %for.inc ]
  invoke void @external(i32* %d.0)
  to label %for.inc unwind label %catch.dispatch

for.inc:                                          ; preds = %for.cond
  %incdec.ptr = getelementptr inbounds i32, i32* %d.0, i32 1
  br label %for.cond

catch.dispatch:                                   ; preds = %for.cond
  %cs = catchswitch within none [label %catch] unwind label %catch.dispatch.2

catch:                                            ; preds = %catch.dispatch
  %0 = catchpad within %cs [i8* null, i32 64, i8* null]
  catchret from %0 to label %try.cont

try.cont:                                         ; preds = %catch
  invoke void @external(i32* %c)
  to label %try.cont.7 unwind label %catch.dispatch.2

catch.dispatch.2:                                 ; preds = %try.cont, %catchendblock
  %e.0 = phi i32* [ %c, %try.cont ], [ %b, %catch.dispatch ]
  %cs2 = catchswitch within none [label %catch.4] unwind to caller

catch.4:                                          ; preds = %catch.dispatch.2
  catchpad within %cs2 [i8* null, i32 64, i8* null]
  unreachable

try.cont.7:                                       ; preds = %try.cont
  ret void
}

define i32 @test2() personality i32 (...)* @_except_handler3 {
; CHECK-LABEL: @test2(
; CHECK-NEXT:  entry:
; CHECK-NEXT:    br label [[FOR_BODY:%.*]]
; CHECK:       for.body:
; CHECK-NEXT:    [[PHI:%.*]] = phi i32 [ [[INC:%.*]], [[FOR_INC:%.*]] ], [ 0, [[ENTRY:%.*]] ]
; CHECK-NEXT:    invoke void @reserve()
; CHECK-NEXT:    to label [[FOR_INC]] unwind label [[CATCH_DISPATCH:%.*]]
; CHECK:       catch.dispatch:
; CHECK-NEXT:    [[TMP18:%.*]] = catchswitch within none [label %catch.handler] unwind to caller
; CHECK:       catch.handler:
; CHECK-NEXT:    [[PHI_LCSSA:%.*]] = phi i32 [ [[PHI]], [[CATCH_DISPATCH]] ]
; CHECK-NEXT:    [[TMP19:%.*]] = catchpad within [[TMP18]] [i8* null]
; CHECK-NEXT:    catchret from [[TMP19]] to label [[DONE:%.*]]
; CHECK:       done:
; CHECK-NEXT:    ret i32 [[PHI_LCSSA]]
; CHECK:       for.inc:
; CHECK-NEXT:    [[INC]] = add i32 [[PHI]], 1
; CHECK-NEXT:    br label [[FOR_BODY]]
;
entry:
  br label %for.body

for.body:                                         ; preds = %for.inc, %entry
  %phi = phi i32 [ %inc, %for.inc ], [ 0, %entry ]
  invoke void @reserve()
  to label %for.inc unwind label %catch.dispatch

catch.dispatch:                                   ; preds = %for.body
  %tmp18 = catchswitch within none [label %catch.handler] unwind to caller

catch.handler:                                    ; preds = %catch.dispatch
  %phi.lcssa = phi i32 [ %phi, %catch.dispatch ]
  %tmp19 = catchpad within %tmp18 [i8* null]
  catchret from %tmp19 to label %done

done:
  ret i32 %phi.lcssa

for.inc:                                          ; preds = %for.body
  %inc = add i32 %phi, 1
  br label %for.body
}
