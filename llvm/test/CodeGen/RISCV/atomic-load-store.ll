; NOTE: Assertions have been autogenerated by utils/update_llc_test_checks.py
; RUN: llc -mtriple=riscv32 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32I %s
; RUN: llc -mtriple=riscv32 -mattr=+a -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV32IA %s
; RUN: llc -mtriple=riscv64 -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV64I %s
; RUN: llc -mtriple=riscv64 -mattr=+a -verify-machineinstrs < %s \
; RUN:   | FileCheck -check-prefix=RV64IA %s

define i8 @atomic_load_i8_unordered(i8 *%a) nounwind {
; RV32I-LABEL: atomic_load_i8_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i8_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lb a0, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i8_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i8_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lb a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i8, i8* %a unordered, align 1
  ret i8 %1
}

define i8 @atomic_load_i8_monotonic(i8 *%a) nounwind {
; RV32I-LABEL: atomic_load_i8_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i8_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lb a0, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i8_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i8_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lb a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i8, i8* %a monotonic, align 1
  ret i8 %1
}

define i8 @atomic_load_i8_acquire(i8 *%a) nounwind {
; RV32I-LABEL: atomic_load_i8_acquire:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 2
; RV32I-NEXT:    call __atomic_load_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i8_acquire:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lb a0, 0(a0)
; RV32IA-NEXT:    fence r, rw
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i8_acquire:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 2
; RV64I-NEXT:    call __atomic_load_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i8_acquire:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lb a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i8, i8* %a acquire, align 1
  ret i8 %1
}

define i8 @atomic_load_i8_seq_cst(i8 *%a) nounwind {
; RV32I-LABEL: atomic_load_i8_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 5
; RV32I-NEXT:    call __atomic_load_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i8_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, rw
; RV32IA-NEXT:    lb a0, 0(a0)
; RV32IA-NEXT:    fence r, rw
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i8_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 5
; RV64I-NEXT:    call __atomic_load_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i8_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, rw
; RV64IA-NEXT:    lb a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i8, i8* %a seq_cst, align 1
  ret i8 %1
}

define i16 @atomic_load_i16_unordered(i16 *%a) nounwind {
; RV32I-LABEL: atomic_load_i16_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i16_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lh a0, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i16_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i16_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lh a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i16, i16* %a unordered, align 2
  ret i16 %1
}

define i16 @atomic_load_i16_monotonic(i16 *%a) nounwind {
; RV32I-LABEL: atomic_load_i16_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i16_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lh a0, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i16_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i16_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lh a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i16, i16* %a monotonic, align 2
  ret i16 %1
}

define i16 @atomic_load_i16_acquire(i16 *%a) nounwind {
; RV32I-LABEL: atomic_load_i16_acquire:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 2
; RV32I-NEXT:    call __atomic_load_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i16_acquire:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lh a0, 0(a0)
; RV32IA-NEXT:    fence r, rw
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i16_acquire:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 2
; RV64I-NEXT:    call __atomic_load_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i16_acquire:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lh a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i16, i16* %a acquire, align 2
  ret i16 %1
}

define i16 @atomic_load_i16_seq_cst(i16 *%a) nounwind {
; RV32I-LABEL: atomic_load_i16_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 5
; RV32I-NEXT:    call __atomic_load_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i16_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, rw
; RV32IA-NEXT:    lh a0, 0(a0)
; RV32IA-NEXT:    fence r, rw
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i16_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 5
; RV64I-NEXT:    call __atomic_load_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i16_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, rw
; RV64IA-NEXT:    lh a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i16, i16* %a seq_cst, align 2
  ret i16 %1
}

define i32 @atomic_load_i32_unordered(i32 *%a) nounwind {
; RV32I-LABEL: atomic_load_i32_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i32_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lw a0, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i32_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i32_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lw a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i32, i32* %a unordered, align 4
  ret i32 %1
}

define i32 @atomic_load_i32_monotonic(i32 *%a) nounwind {
; RV32I-LABEL: atomic_load_i32_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i32_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lw a0, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i32_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i32_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lw a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i32, i32* %a monotonic, align 4
  ret i32 %1
}

define i32 @atomic_load_i32_acquire(i32 *%a) nounwind {
; RV32I-LABEL: atomic_load_i32_acquire:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 2
; RV32I-NEXT:    call __atomic_load_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i32_acquire:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    lw a0, 0(a0)
; RV32IA-NEXT:    fence r, rw
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i32_acquire:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 2
; RV64I-NEXT:    call __atomic_load_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i32_acquire:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    lw a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i32, i32* %a acquire, align 4
  ret i32 %1
}

define i32 @atomic_load_i32_seq_cst(i32 *%a) nounwind {
; RV32I-LABEL: atomic_load_i32_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 5
; RV32I-NEXT:    call __atomic_load_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i32_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, rw
; RV32IA-NEXT:    lw a0, 0(a0)
; RV32IA-NEXT:    fence r, rw
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i32_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 5
; RV64I-NEXT:    call __atomic_load_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i32_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, rw
; RV64IA-NEXT:    lw a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i32, i32* %a seq_cst, align 4
  ret i32 %1
}

define i64 @atomic_load_i64_unordered(i64 *%a) nounwind {
; RV32I-LABEL: atomic_load_i64_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i64_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    mv a1, zero
; RV32IA-NEXT:    call __atomic_load_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i64_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i64_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    ld a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i64, i64* %a unordered, align 8
  ret i64 %1
}

define i64 @atomic_load_i64_monotonic(i64 *%a) nounwind {
; RV32I-LABEL: atomic_load_i64_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a1, zero
; RV32I-NEXT:    call __atomic_load_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i64_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    mv a1, zero
; RV32IA-NEXT:    call __atomic_load_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i64_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a1, zero
; RV64I-NEXT:    call __atomic_load_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i64_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    ld a0, 0(a0)
; RV64IA-NEXT:    ret
  %1 = load atomic i64, i64* %a monotonic, align 8
  ret i64 %1
}

define i64 @atomic_load_i64_acquire(i64 *%a) nounwind {
; RV32I-LABEL: atomic_load_i64_acquire:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 2
; RV32I-NEXT:    call __atomic_load_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i64_acquire:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    addi a1, zero, 2
; RV32IA-NEXT:    call __atomic_load_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i64_acquire:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 2
; RV64I-NEXT:    call __atomic_load_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i64_acquire:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    ld a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i64, i64* %a acquire, align 8
  ret i64 %1
}

define i64 @atomic_load_i64_seq_cst(i64 *%a) nounwind {
; RV32I-LABEL: atomic_load_i64_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a1, zero, 5
; RV32I-NEXT:    call __atomic_load_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_load_i64_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    addi a1, zero, 5
; RV32IA-NEXT:    call __atomic_load_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_load_i64_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a1, zero, 5
; RV64I-NEXT:    call __atomic_load_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_load_i64_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, rw
; RV64IA-NEXT:    ld a0, 0(a0)
; RV64IA-NEXT:    fence r, rw
; RV64IA-NEXT:    ret
  %1 = load atomic i64, i64* %a seq_cst, align 8
  ret i64 %1
}

define void @atomic_store_i8_unordered(i8 *%a, i8 %b) nounwind {
; RV32I-LABEL: atomic_store_i8_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a2, zero
; RV32I-NEXT:    call __atomic_store_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i8_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    sb a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i8_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i8_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sb a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i8 %b, i8* %a unordered, align 1
  ret void
}

define void @atomic_store_i8_monotonic(i8 *%a, i8 %b) nounwind {
; RV32I-LABEL: atomic_store_i8_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a2, zero
; RV32I-NEXT:    call __atomic_store_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i8_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    sb a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i8_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i8_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sb a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i8 %b, i8* %a monotonic, align 1
  ret void
}

define void @atomic_store_i8_release(i8 *%a, i8 %b) nounwind {
; RV32I-LABEL: atomic_store_i8_release:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a2, zero, 3
; RV32I-NEXT:    call __atomic_store_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i8_release:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, w
; RV32IA-NEXT:    sb a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i8_release:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 3
; RV64I-NEXT:    call __atomic_store_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i8_release:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sb a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i8 %b, i8* %a release, align 1
  ret void
}

define void @atomic_store_i8_seq_cst(i8 *%a, i8 %b) nounwind {
; RV32I-LABEL: atomic_store_i8_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a2, zero, 5
; RV32I-NEXT:    call __atomic_store_1@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i8_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, w
; RV32IA-NEXT:    sb a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i8_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 5
; RV64I-NEXT:    call __atomic_store_1@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i8_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sb a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i8 %b, i8* %a seq_cst, align 1
  ret void
}

define void @atomic_store_i16_unordered(i16 *%a, i16 %b) nounwind {
; RV32I-LABEL: atomic_store_i16_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a2, zero
; RV32I-NEXT:    call __atomic_store_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i16_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    sh a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i16_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i16_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sh a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i16 %b, i16* %a unordered, align 2
  ret void
}

define void @atomic_store_i16_monotonic(i16 *%a, i16 %b) nounwind {
; RV32I-LABEL: atomic_store_i16_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a2, zero
; RV32I-NEXT:    call __atomic_store_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i16_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    sh a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i16_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i16_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sh a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i16 %b, i16* %a monotonic, align 2
  ret void
}

define void @atomic_store_i16_release(i16 *%a, i16 %b) nounwind {
; RV32I-LABEL: atomic_store_i16_release:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a2, zero, 3
; RV32I-NEXT:    call __atomic_store_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i16_release:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, w
; RV32IA-NEXT:    sh a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i16_release:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 3
; RV64I-NEXT:    call __atomic_store_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i16_release:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sh a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i16 %b, i16* %a release, align 2
  ret void
}

define void @atomic_store_i16_seq_cst(i16 *%a, i16 %b) nounwind {
; RV32I-LABEL: atomic_store_i16_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a2, zero, 5
; RV32I-NEXT:    call __atomic_store_2@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i16_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, w
; RV32IA-NEXT:    sh a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i16_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 5
; RV64I-NEXT:    call __atomic_store_2@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i16_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sh a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i16 %b, i16* %a seq_cst, align 2
  ret void
}

define void @atomic_store_i32_unordered(i32 *%a, i32 %b) nounwind {
; RV32I-LABEL: atomic_store_i32_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a2, zero
; RV32I-NEXT:    call __atomic_store_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i32_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    sw a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i32_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i32_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sw a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i32 %b, i32* %a unordered, align 4
  ret void
}

define void @atomic_store_i32_monotonic(i32 *%a, i32 %b) nounwind {
; RV32I-LABEL: atomic_store_i32_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a2, zero
; RV32I-NEXT:    call __atomic_store_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i32_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    sw a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i32_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i32_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sw a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i32 %b, i32* %a monotonic, align 4
  ret void
}

define void @atomic_store_i32_release(i32 *%a, i32 %b) nounwind {
; RV32I-LABEL: atomic_store_i32_release:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a2, zero, 3
; RV32I-NEXT:    call __atomic_store_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i32_release:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, w
; RV32IA-NEXT:    sw a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i32_release:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 3
; RV64I-NEXT:    call __atomic_store_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i32_release:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sw a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i32 %b, i32* %a release, align 4
  ret void
}

define void @atomic_store_i32_seq_cst(i32 *%a, i32 %b) nounwind {
; RV32I-LABEL: atomic_store_i32_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a2, zero, 5
; RV32I-NEXT:    call __atomic_store_4@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i32_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    fence rw, w
; RV32IA-NEXT:    sw a1, 0(a0)
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i32_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 5
; RV64I-NEXT:    call __atomic_store_4@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i32_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sw a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i32 %b, i32* %a seq_cst, align 4
  ret void
}

define void @atomic_store_i64_unordered(i64 *%a, i64 %b) nounwind {
; RV32I-LABEL: atomic_store_i64_unordered:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a3, zero
; RV32I-NEXT:    call __atomic_store_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i64_unordered:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    mv a3, zero
; RV32IA-NEXT:    call __atomic_store_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i64_unordered:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i64_unordered:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sd a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i64 %b, i64* %a unordered, align 8
  ret void
}

define void @atomic_store_i64_monotonic(i64 *%a, i64 %b) nounwind {
; RV32I-LABEL: atomic_store_i64_monotonic:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    mv a3, zero
; RV32I-NEXT:    call __atomic_store_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i64_monotonic:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    mv a3, zero
; RV32IA-NEXT:    call __atomic_store_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i64_monotonic:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    mv a2, zero
; RV64I-NEXT:    call __atomic_store_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i64_monotonic:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    sd a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i64 %b, i64* %a monotonic, align 8
  ret void
}

define void @atomic_store_i64_release(i64 *%a, i64 %b) nounwind {
; RV32I-LABEL: atomic_store_i64_release:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a3, zero, 3
; RV32I-NEXT:    call __atomic_store_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i64_release:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    addi a3, zero, 3
; RV32IA-NEXT:    call __atomic_store_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i64_release:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 3
; RV64I-NEXT:    call __atomic_store_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i64_release:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sd a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i64 %b, i64* %a release, align 8
  ret void
}

define void @atomic_store_i64_seq_cst(i64 *%a, i64 %b) nounwind {
; RV32I-LABEL: atomic_store_i64_seq_cst:
; RV32I:       # %bb.0:
; RV32I-NEXT:    addi sp, sp, -16
; RV32I-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32I-NEXT:    addi a3, zero, 5
; RV32I-NEXT:    call __atomic_store_8@plt
; RV32I-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32I-NEXT:    addi sp, sp, 16
; RV32I-NEXT:    ret
;
; RV32IA-LABEL: atomic_store_i64_seq_cst:
; RV32IA:       # %bb.0:
; RV32IA-NEXT:    addi sp, sp, -16
; RV32IA-NEXT:    sw ra, 12(sp) # 4-byte Folded Spill
; RV32IA-NEXT:    addi a3, zero, 5
; RV32IA-NEXT:    call __atomic_store_8@plt
; RV32IA-NEXT:    lw ra, 12(sp) # 4-byte Folded Reload
; RV32IA-NEXT:    addi sp, sp, 16
; RV32IA-NEXT:    ret
;
; RV64I-LABEL: atomic_store_i64_seq_cst:
; RV64I:       # %bb.0:
; RV64I-NEXT:    addi sp, sp, -16
; RV64I-NEXT:    sd ra, 8(sp) # 8-byte Folded Spill
; RV64I-NEXT:    addi a2, zero, 5
; RV64I-NEXT:    call __atomic_store_8@plt
; RV64I-NEXT:    ld ra, 8(sp) # 8-byte Folded Reload
; RV64I-NEXT:    addi sp, sp, 16
; RV64I-NEXT:    ret
;
; RV64IA-LABEL: atomic_store_i64_seq_cst:
; RV64IA:       # %bb.0:
; RV64IA-NEXT:    fence rw, w
; RV64IA-NEXT:    sd a1, 0(a0)
; RV64IA-NEXT:    ret
  store atomic i64 %b, i64* %a seq_cst, align 8
  ret void
}
