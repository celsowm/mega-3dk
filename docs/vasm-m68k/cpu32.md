# CPU32 — vasm Reference

CPU32 is an embedded M68k variant used in Motorola/Freescale MCUs
(68332, 68334, 68336, 68340, 68360, etc.).  
It is based on 68010/68020 but adds table-driven branching and background debug.

## vasm Target Flag

```bash
vasmm68k_mot -mcpu32 -Fbin -o firmware.bin main.asm
```

---

## Instruction Set

CPU32 supports the full 68010 ISA plus:

### Table-Driven Branching

**`TBLS`** / **`TBLSN`** — Table lookup and interpolate, signed  
**`TBLU`** / **`TBLUN`** — Table lookup and interpolate, unsigned

These instructions perform hardware-assisted lookup table interpolation — useful for trig tables, waveform synthesis, and control loop linearization.

```asm
; Syntax:
    tbls.b  (An),Dn          ; lookup byte table, signed interpolation
    tbls.w  (An),Dn          ; word table
    tbls.l  (An),Dn          ; longword table
    tblu.w  (An),Dn          ; unsigned version

; Register pair form (uses two adjacent Dn registers):
    tbls.w  (An),Dn:Dn+1     ; result in Dn:Dn+1 for extended precision
```

How it works:
- **Dn** contains a fractional index (upper N bits = integer index, lower bits = fraction)
- The instruction fetches `table[index]` and `table[index+1]`
- Interpolates linearly using the fractional part
- Stores the interpolated result in Dn

Example — sine wave via 256-entry table:

```asm
; Table of 256 sine values (words), stored at SineTable
; d0 = phase (8.8 fixed-point: upper byte = table index)
    lea     SineTable,a0
    tbls.w  (a0),d0          ; d0 = interpolated sine value
```

- `TBLSN` / `TBLUN` — no-interpolation variants (nearest entry only)

---

## Background Debug Mode (BDM)

CPU32 includes a hardware debug port. No assembly directives needed —
BDM is accessed via the external debug tool (P&E Micro, etc.).

The `BGND` instruction halts the CPU and enters BDM:

```asm
    bgnd                     ; enter background debug mode
```

Typically used with a conditional:

```asm
    ifdef   DEBUG
    bgnd
    endif
```

---

## Differences from 68020

- No bit-field instructions (`BFINS`, `BFEXTU`, etc.)
- No coprocessor interface (no 68881 FPU support — use software float)
- No `PACK`/`UNPK`
- No `CAS`/`CAS2` or `CHK2`/`CMP2` (some variants support CAS)
- 22-bit address bus on some variants (not full 32-bit)
- Supervisor stack pointer model differs slightly (MSP/ISP not always present)

---

## Common CPU32 MCU Peripheral Addresses (68332 example)

```asm
; SIM (System Integration Module)
SIM_BASE    equ     $FFFA00
SIMCR       equ     SIM_BASE+$00     ; SIM configuration register
SYPCR       equ     SIM_BASE+$22     ; System protection control
PICR        equ     SIM_BASE+$26     ; Periodic interrupt control
PITR        equ     SIM_BASE+$28     ; Periodic interrupt timing

; QSM (Queued Serial Module)
QSM_BASE    equ     $FFFC00
QSMCR       equ     QSM_BASE+$00
QILR        equ     QSM_BASE+$04
SCCR0       equ     QSM_BASE+$08
SCCR1       equ     QSM_BASE+$0A
SCSR        equ     QSM_BASE+$0C
SCDR        equ     QSM_BASE+$0E

; TPU (Time Processor Unit)
TPU_BASE    equ     $FFFE00
TPUMCR      equ     TPU_BASE+$00

; RAM/ROM mapping
INT_RAM     equ     $000000          ; internal RAM (2KB on 68332)
```

---

## Startup Code Example (68332)

```asm
    org     $000000
    ; Exception vector table
    dc.l    __stack_top          ; initial SSP
    dc.l    _start               ; reset PC
    ; vectors 2-255 follow...
    dcb.l   254,$00000000

    org     $000400
_start:
    move    #$2700,sr            ; supervisor, interrupts disabled
    lea     __stack_top,sp

    ; Initialize SIM
    move.w  #$7F1C,SIMCR         ; set EXOFF, FRZSW, FRZBIU

    ; Zero BSS
    lea     __bss_start,a0
    lea     __bss_end,a1
    bra.s   .zbss_check
.zbss_loop:
    clr.l   (a0)+
.zbss_check:
    cmpa.l  a1,a0
    blo.s   .zbss_loop

    ; Copy .data from ROM to RAM
    lea     __data_rom,a0
    lea     __data_start,a1
    lea     __data_end,a2
    bra.s   .copy_check
.copy_loop:
    move.l  (a0)+,(a1)+
.copy_check:
    cmpa.l  a2,a1
    blo.s   .copy_loop

    jsr     main
.hang:
    bra.s   .hang
```