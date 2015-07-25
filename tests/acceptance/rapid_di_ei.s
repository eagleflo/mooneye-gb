; This tests how sequential DI/EI instructions work by forcing a serial
; interrupt with a write to IE/IF. The interrupt handler increments
; E, so we can track how many times the interrupt has been
; triggered

.incdir "../common"
.include "common.s"

.macro reset
  ld a, INTR_SERIAL
  ld (IF), a
  ld (IE), a
  xor a
  ld e, a
.endm

  di
  reset

  ; Rapid EI/DI should *not* result in any interrupts
  ei
  di
  ei
  di
  ld b, e

  reset

  ; EI followed by DI should *not* result in any interrupts
  ei
  di
  nop
  nop
  ld c, e

  reset

  ; A nop after EI should cause an interrupt
  ei
  nop
  di
  ld d, e

  reset

  ; Two nops after EI should cause an interrupt
  ei
  nop
  nop
  di

test_finish:
  ; GBP MGB-001 / GBC CGB-001 / GBASP AGS-101 (probably DMG/GBA as well)
  save_results
  assert_b $00
  assert_c $00
  assert_d $01
  assert_e $01
  jp process_results

.org INTR_VEC_SERIAL
  inc e
  reti