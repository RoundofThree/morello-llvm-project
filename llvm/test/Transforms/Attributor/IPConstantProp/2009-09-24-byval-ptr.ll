; NOTE: Assertions have been autogenerated by utils/update_test_checks.py UTC_ARGS: --function-signature --scrub-attributes
; RUN: opt -S -passes=attributor -aa-pipeline='basic-aa' -attributor-disable=false -attributor-max-iterations-verify -attributor-max-iterations=2 < %s | FileCheck %s
; Don't constant-propagate byval pointers, since they are not pointers!
; PR5038
%struct.MYstr = type { i8, i32 }
@mystr = internal global %struct.MYstr zeroinitializer ; <%struct.MYstr*> [#uses=3]
define internal void @vfu1(%struct.MYstr* byval align 4 %u) nounwind {
; CHECK-LABEL: define {{[^@]+}}@vfu1
; CHECK-SAME: (%struct.MYstr* noalias nocapture nofree nonnull writeonly byval align 8 dereferenceable(8) [[U:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_MYSTR:%.*]], %struct.MYstr* [[U]], i32 0, i32 1
; CHECK-NEXT:    store i32 99, i32* [[TMP0]], align 4
; CHECK-NEXT:    [[TMP1:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 0
; CHECK-NEXT:    store i8 97, i8* [[TMP1]], align 8
; CHECK-NEXT:    br label [[RETURN:%.*]]
; CHECK:       return:
; CHECK-NEXT:    ret void
;
entry:
  %0 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1 ; <i32*> [#uses=1]
  store i32 99, i32* %0, align 4
  %1 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 0 ; <i8*> [#uses=1]
  store i8 97, i8* %1, align 4
  br label %return

return:                                           ; preds = %entry
  ret void
}

define internal i32 @vfu2(%struct.MYstr* byval align 4 %u) nounwind readonly {
; CHECK-LABEL: define {{[^@]+}}@vfu2
; CHECK-SAME: (%struct.MYstr* noalias nocapture nofree nonnull readonly byval align 8 dereferenceable(8) [[U:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_MYSTR:%.*]], %struct.MYstr* @mystr, i32 0, i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* @mystr, i32 0, i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, i8* [[TMP2]], align 8
; CHECK-NEXT:    [[TMP4:%.*]] = zext i8 [[TMP3]] to i32
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[TMP4]], [[TMP1]]
; CHECK-NEXT:    ret i32 [[TMP5]]
;
entry:
  %0 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1 ; <i32*> [#uses=1]
  %1 = load i32, i32* %0
  %2 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 0 ; <i8*> [#uses=1]
  %3 = load i8, i8* %2
  %4 = zext i8 %3 to i32
  %5 = add i32 %4, %1
  ret i32 %5
}

define i32 @unions() nounwind {
; CHECK-LABEL: define {{[^@]+}}@unions()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @vfu1(%struct.MYstr* nofree nonnull readonly byval align 8 dereferenceable(8) @mystr)
; CHECK-NEXT:    [[RESULT:%.*]] = call i32 @vfu2(%struct.MYstr* nofree nonnull readonly byval align 8 dereferenceable(8) @mystr)
; CHECK-NEXT:    ret i32 [[RESULT]]
;
entry:
  call void @vfu1(%struct.MYstr* byval align 4 @mystr) nounwind
  %result = call i32 @vfu2(%struct.MYstr* byval align 4 @mystr) nounwind
  ret i32 %result
}

define internal i32 @vfu2_v2(%struct.MYstr* byval align 4 %u) nounwind readonly {
; CHECK-LABEL: define {{[^@]+}}@vfu2_v2
; CHECK-SAME: (%struct.MYstr* noalias nocapture nofree nonnull byval align 8 dereferenceable(8) [[U:%.*]])
; CHECK-NEXT:  entry:
; CHECK-NEXT:    [[Z:%.*]] = getelementptr [[STRUCT_MYSTR:%.*]], %struct.MYstr* [[U]], i32 0, i32 1
; CHECK-NEXT:    store i32 99, i32* [[Z]], align 4
; CHECK-NEXT:    [[TMP0:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 1
; CHECK-NEXT:    [[TMP1:%.*]] = load i32, i32* [[TMP0]]
; CHECK-NEXT:    [[TMP2:%.*]] = getelementptr [[STRUCT_MYSTR]], %struct.MYstr* [[U]], i32 0, i32 0
; CHECK-NEXT:    [[TMP3:%.*]] = load i8, i8* [[TMP2]], align 8
; CHECK-NEXT:    [[TMP4:%.*]] = zext i8 [[TMP3]] to i32
; CHECK-NEXT:    [[TMP5:%.*]] = add i32 [[TMP4]], [[TMP1]]
; CHECK-NEXT:    ret i32 [[TMP5]]
;
entry:
  %z = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1
  store i32 99, i32* %z, align 4
  %0 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 1 ; <i32*> [#uses=1]
  %1 = load i32, i32* %0
  %2 = getelementptr %struct.MYstr, %struct.MYstr* %u, i32 0, i32 0 ; <i8*> [#uses=1]
  %3 = load i8, i8* %2
  %4 = zext i8 %3 to i32
  %5 = add i32 %4, %1
  ret i32 %5
}

define i32 @unions_v2() nounwind {
; CHECK-LABEL: define {{[^@]+}}@unions_v2()
; CHECK-NEXT:  entry:
; CHECK-NEXT:    call void @vfu1(%struct.MYstr* nofree nonnull readonly byval align 8 dereferenceable(8) @mystr)
; CHECK-NEXT:    [[RESULT:%.*]] = call i32 @vfu2_v2(%struct.MYstr* nofree nonnull readonly byval align 8 dereferenceable(8) @mystr)
; CHECK-NEXT:    ret i32 [[RESULT]]
;
entry:
  call void @vfu1(%struct.MYstr* byval align 4 @mystr) nounwind
  %result = call i32 @vfu2_v2(%struct.MYstr* byval align 4 @mystr) nounwind
  ret i32 %result
}
