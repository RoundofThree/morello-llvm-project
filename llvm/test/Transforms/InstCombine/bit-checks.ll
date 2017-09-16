; NOTE: Assertions have been autogenerated by utils/update_test_checks.py
; RUN: opt < %s -instcombine -S | FileCheck %s

define i32 @main1(i32 %argc) {
; CHECK-LABEL: @main1(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 3
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 3
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 2, i32 1
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %and = and i32 %argc, 1
  %tobool = icmp ne i32 %and, 0
  %and2 = and i32 %argc, 2
  %tobool3 = icmp ne i32 %and2, 0
  %or.cond = and i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main2(i32 %argc) {
; CHECK-LABEL: @main2(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 3
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 3
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 1
  %tobool = icmp eq i32 %and, 0
  %and2 = and i32 %argc, 2
  %tobool3 = icmp eq i32 %and2, 0
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

; tests to check combining (icmp eq (A & B), C) & (icmp eq (A & D), E)
; tests to check if (icmp eq (A & B), 0) is treated like (icmp eq (A & B), B)
; if B is a single bit constant

; (icmp eq (A & B), 0) & (icmp eq (A & D), 0) -> (icmp eq (A & (B|D)), 0)
define i32 @main3(i32 %argc) {
; CHECK-LABEL: @main3(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 55
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 0
  %and2 = and i32 %argc, 48
  %tobool3 = icmp eq i32 %and2, 0
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main3b(i32 %argc) {
; CHECK-LABEL: @main3b(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 23
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP1]], 0
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 0
  %and2 = and i32 %argc, 16
  %tobool3 = icmp ne i32 %and2, 16
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main3e_like(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main3e_like(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], 0
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, %argc2
  %tobool = icmp eq i32 %and, 0
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp eq i32 %and2, 0
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp ne (A & B), 0) | (icmp ne (A & D), 0) -> (icmp ne (A & (B|D)), 0)
define i32 @main3c(i32 %argc) {
; CHECK-LABEL: @main3c(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 55
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 0
  %and2 = and i32 %argc, 48
  %tobool3 = icmp ne i32 %and2, 0
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main3d(i32 %argc) {
; CHECK-LABEL: @main3d(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 23
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 0
  %and2 = and i32 %argc, 16
  %tobool3 = icmp eq i32 %and2, 16
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main3f_like(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main3f_like(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP2]], 0
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, %argc2
  %tobool = icmp ne i32 %and, 0
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp ne i32 %and2, 0
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp eq (A & B), B) & (icmp eq (A & D), D) -> (icmp eq (A & (B|D)), (B|D))
define i32 @main4(i32 %argc) {
; CHECK-LABEL: @main4(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 55
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP1]], 55
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 7
  %and2 = and i32 %argc, 48
  %tobool3 = icmp eq i32 %and2, 48
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main4b(i32 %argc) {
; CHECK-LABEL: @main4b(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 23
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP1]], 23
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 7
  %and2 = and i32 %argc, 16
  %tobool3 = icmp ne i32 %and2, 0
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main4e_like(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main4e_like(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, %argc2
  %tobool = icmp eq i32 %and, %argc2
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp eq i32 %and2, %argc3
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp ne (A & B), B) | (icmp ne (A & D), D) -> (icmp ne (A & (B|D)), (B|D))
define i32 @main4c(i32 %argc) {
; CHECK-LABEL: @main4c(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 55
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 55
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 7
  %and2 = and i32 %argc, 48
  %tobool3 = icmp ne i32 %and2, 48
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main4d(i32 %argc) {
; CHECK-LABEL: @main4d(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 23
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 23
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 7
  %and2 = and i32 %argc, 16
  %tobool3 = icmp eq i32 %and2, 0
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main4f_like(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main4f_like(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, %argc2
  %tobool = icmp ne i32 %and, %argc2
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp ne i32 %and2, %argc3
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp eq (A & B), A) & (icmp eq (A & D), A) -> (icmp eq (A & (B&D)), A)
define i32 @main5_like(i32 %argc, i32 %argc2) {
; CHECK-LABEL: @main5_like(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, %argc2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], 7
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], 7
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 7
  %and2 = and i32 %argc2, 7
  %tobool3 = icmp eq i32 %and2, 7
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main5e_like(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main5e_like(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], %argc
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, %argc2
  %tobool = icmp eq i32 %and, %argc
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp eq i32 %and2, %argc
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp ne (A & B), A) | (icmp ne (A & D), A) -> (icmp ne (A & (B&D)), A)
define i32 @main5c_like(i32 %argc, i32 %argc2) {
; CHECK-LABEL: @main5c_like(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, %argc2
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], 7
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP2]], 7
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 7
  %and2 = and i32 %argc2, 7
  %tobool3 = icmp ne i32 %and2, 7
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main5f_like(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main5f_like(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP2]], %argc
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, %argc2
  %tobool = icmp ne i32 %and, %argc
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp ne i32 %and2, %argc
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp eq (A & B), C) & (icmp eq (A & D), E) -> (icmp eq (A & (B|D)), (C|E))
; if B, C, D, E are constant, and it's possible
define i32 @main6(i32 %argc) {
; CHECK-LABEL: @main6(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 55
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP1]], 19
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 3
  %and2 = and i32 %argc, 48
  %tobool3 = icmp eq i32 %and2, 16
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main6b(i32 %argc) {
; CHECK-LABEL: @main6b(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 23
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP1]], 19
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp eq i32 %and, 3
  %and2 = and i32 %argc, 16
  %tobool3 = icmp ne i32 %and2, 0
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (icmp ne (A & B), C) | (icmp ne (A & D), E) -> (icmp ne (A & (B|D)), (C|E))
; if B, C, D, E are constant, and it's possible
define i32 @main6c(i32 %argc) {
; CHECK-LABEL: @main6c(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 55
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 19
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 3
  %and2 = and i32 %argc, 48
  %tobool3 = icmp ne i32 %and2, 16
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main6d(i32 %argc) {
; CHECK-LABEL: @main6d(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 %argc, 23
; CHECK-NEXT:    [[NOT_:%.*]] = icmp eq i32 [[TMP1]], 19
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and = and i32 %argc, 7
  %tobool = icmp ne i32 %and, 3
  %and2 = and i32 %argc, 16
  %tobool3 = icmp eq i32 %and2, 0
  %or.cond = or i1 %tobool, %tobool3
  %storemerge = select i1 %or.cond, i32 0, i32 1
  ret i32 %storemerge
}

; test parameter permutations
; (B & A) == B & (D & A) == D
define i32 @main7a(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main7a(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and1 = and i32 %argc2, %argc
  %tobool = icmp eq i32 %and1, %argc2
  %and2 = and i32 %argc3, %argc
  %tobool3 = icmp eq i32 %and2, %argc3
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; B == (A & B) & D == (A & D)
define i32 @main7b(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main7b(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and1 = and i32 %argc, %argc2
  %tobool = icmp eq i32 %argc2, %and1
  %and2 = and i32 %argc, %argc3
  %tobool3 = icmp eq i32 %argc3, %and2
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; B == (B & A) & D == (D & A)
define i32 @main7c(i32 %argc, i32 %argc2, i32 %argc3) {
; CHECK-LABEL: @main7c(
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 %argc2, %argc3
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %and1 = and i32 %argc2, %argc
  %tobool = icmp eq i32 %argc2, %and1
  %and2 = and i32 %argc3, %argc
  %tobool3 = icmp eq i32 %argc3, %and2
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (A & (B & C)) == (B & C) & (A & (D & E)) == (D & E)
define i32 @main7d(i32 %argc, i32 %argc2, i32 %argc3, i32 %argc4, i32 %argc5) {
; CHECK-LABEL: @main7d(
; CHECK-NEXT:    [[BC:%.*]] = and i32 %argc2, %argc4
; CHECK-NEXT:    [[DE:%.*]] = and i32 %argc3, %argc5
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[BC]], [[DE]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %bc = and i32 %argc2, %argc4
  %de = and i32 %argc3, %argc5
  %and1 = and i32 %argc, %bc
  %tobool = icmp eq i32 %and1, %bc
  %and2 = and i32 %argc, %de
  %tobool3 = icmp eq i32 %and2, %de
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; ((B & C) & A) == (B & C) & ((D & E) & A) == (D & E)
define i32 @main7e(i32 %argc, i32 %argc2, i32 %argc3, i32 %argc4, i32 %argc5) {
; CHECK-LABEL: @main7e(
; CHECK-NEXT:    [[BC:%.*]] = and i32 %argc2, %argc4
; CHECK-NEXT:    [[DE:%.*]] = and i32 %argc3, %argc5
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[BC]], [[DE]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %bc = and i32 %argc2, %argc4
  %de = and i32 %argc3, %argc5
  %and1 = and i32 %bc, %argc
  %tobool = icmp eq i32 %and1, %bc
  %and2 = and i32 %de, %argc
  %tobool3 = icmp eq i32 %and2, %de
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (B & C) == (A & (B & C)) & (D & E) == (A & (D & E))
define i32 @main7f(i32 %argc, i32 %argc2, i32 %argc3, i32 %argc4, i32 %argc5) {
; CHECK-LABEL: @main7f(
; CHECK-NEXT:    [[BC:%.*]] = and i32 %argc2, %argc4
; CHECK-NEXT:    [[DE:%.*]] = and i32 %argc3, %argc5
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[BC]], [[DE]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %bc = and i32 %argc2, %argc4
  %de = and i32 %argc3, %argc5
  %and1 = and i32 %argc, %bc
  %tobool = icmp eq i32 %bc, %and1
  %and2 = and i32 %argc, %de
  %tobool3 = icmp eq i32 %de, %and2
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

; (B & C) == ((B & C) & A) & (D & E) == ((D & E) & A)
define i32 @main7g(i32 %argc, i32 %argc2, i32 %argc3, i32 %argc4, i32 %argc5) {
; CHECK-LABEL: @main7g(
; CHECK-NEXT:    [[BC:%.*]] = and i32 %argc2, %argc4
; CHECK-NEXT:    [[DE:%.*]] = and i32 %argc3, %argc5
; CHECK-NEXT:    [[TMP1:%.*]] = or i32 [[BC]], [[DE]]
; CHECK-NEXT:    [[TMP2:%.*]] = and i32 [[TMP1]], %argc
; CHECK-NEXT:    [[NOT_:%.*]] = icmp ne i32 [[TMP2]], [[TMP1]]
; CHECK-NEXT:    [[STOREMERGE:%.*]] = zext i1 [[NOT_]] to i32
; CHECK-NEXT:    ret i32 [[STOREMERGE]]
;
  %bc = and i32 %argc2, %argc4
  %de = and i32 %argc3, %argc5
  %and1 = and i32 %bc, %argc
  %tobool = icmp eq i32 %bc, %and1
  %and2 = and i32 %de, %argc
  %tobool3 = icmp eq i32 %de, %and2
  %and.cond = and i1 %tobool, %tobool3
  %storemerge = select i1 %and.cond, i32 0, i32 1
  ret i32 %storemerge
}

define i32 @main8(i32 %argc) {
; CHECK-LABEL: @main8(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 192
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 1, i32 2
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %and = and i32 %argc, 64
  %tobool = icmp ne i32 %and, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp slt i8 %trunc2, 0
  %or.cond = or i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main9(i32 %argc) {
; CHECK-LABEL: @main9(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 192
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 192
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 2, i32 1
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %and = and i32 %argc, 64
  %tobool = icmp ne i32 %and, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp slt i8 %trunc2, 0
  %or.cond = and i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main10(i32 %argc) {
; CHECK-LABEL: @main10(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 192
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 2, i32 1
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %and = and i32 %argc, 64
  %tobool = icmp eq i32 %and, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp sge i8 %trunc2, 0
  %or.cond = and i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main11(i32 %argc) {
; CHECK-LABEL: @main11(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 192
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 192
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 1, i32 2
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %and = and i32 %argc, 64
  %tobool = icmp eq i32 %and, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp sge i8 %trunc2, 0
  %or.cond = or i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main12(i32 %argc) {
; CHECK-LABEL: @main12(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 32896
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 1, i32 2
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %trunc = trunc i32 %argc to i16
  %tobool = icmp slt i16 %trunc, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp slt i8 %trunc2, 0
  %or.cond = or i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main13(i32 %argc) {
; CHECK-LABEL: @main13(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 32896
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 32896
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 2, i32 1
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %trunc = trunc i32 %argc to i16
  %tobool = icmp slt i16 %trunc, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp slt i8 %trunc2, 0
  %or.cond = and i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main14(i32 %argc) {
; CHECK-LABEL: @main14(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 32896
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 0
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 2, i32 1
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %trunc = trunc i32 %argc to i16
  %tobool = icmp sge i16 %trunc, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp sge i8 %trunc2, 0
  %or.cond = and i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}

define i32 @main15(i32 %argc) {
; CHECK-LABEL: @main15(
; CHECK-NEXT:    [[TMP1:%.*]] = and i32 [[ARGC:%.*]], 32896
; CHECK-NEXT:    [[TMP2:%.*]] = icmp eq i32 [[TMP1]], 32896
; CHECK-NEXT:    [[RETVAL_0:%.*]] = select i1 [[TMP2]], i32 1, i32 2
; CHECK-NEXT:    ret i32 [[RETVAL_0]]
;
  %trunc = trunc i32 %argc to i16
  %tobool = icmp sge i16 %trunc, 0
  %trunc2 = trunc i32 %argc to i8
  %tobool3 = icmp sge i8 %trunc2, 0
  %or.cond = or i1 %tobool, %tobool3
  %retval.0 = select i1 %or.cond, i32 2, i32 1
  ret i32 %retval.0
}
