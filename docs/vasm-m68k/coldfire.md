# ColdFire — vasm Reference

ColdFire is a streamlined M68k derivative by Freescale/NXP.
It removes many M68k instructions and addressing modes but adds new ones.

## vasm Target Flags

| Flag | Core | Notes |
|------|------|-------|
| `-mcf5200` | V2 | ColdFire V2 (5200 family) |
| `-mcf5202` | V2 | |
| `-mcf5204` | V2 | |
| `-mcf5206` | V2 | |
| `-mcf5206e` | V2 | with EMAC |
| `-mcf5207` | V2 | |
| `-mcf5208` | V2 | |
| `-mcf521x` | V2 | |
| `-mcf5249` | V2 | |
| `-mcf5250` | V2 | |
| `-mcf5271` | V2 | |
| `-mcf5272` | V2 | |
| `-mcf5275` | V2 | |
| `-mcf5282` | V2 | |
| `-mcf5307` | V3 | |
| `-mcf5329` | V3 | |
| `-mcf5373` | V3 | |
| `-mcf5407` | V4 | |
| `-mcf54418` | V4e | |
| `-mcf5475` | V4e | |
| `-mcfv4e` | V4e | generic V4e |

Additional feature flags (combine with core):

| Flag | Feature |
|------|---------|
| `-mac` | Hardware MAC (Multiply-Accumulate) |
| `-emac` | Enhanced MAC |
| `-emac_b` | EMAC-B variant |
| `-fpu` | FPU present (V4e only) |
| `-lpstop` | Low-power STOP instruction |
| `-usp` | User stack pointer instructions |

---

## Key Differences from M68k

### Removed addressing modes
ColdFire does NOT support:
- `(d8,An,Xn)` with word-size index (only `.l` index allowed)
- Memory indirect `([...])` modes
- `(d8,PC,Xn)` with word index
- Scale factors other than `*1` on some variants

### Simplified instruction set

ColdFire removes or restricts:
- **ABCD/SBCD/NBCD** — BCD arithmetic removed entirely
- **PACK/UNPK** — removed
- **MOVES** — removed on most variants
- **TAS** — removed (use EMAC or semaphores)
- **MOVEP** — removed
- **TRAPV/CHK** — removed or restricted
- **RTR** — removed (use MOVE (SP)+,CCR / RTS)
- **LINK.w** — replaced by `LINK.l` (always long displacement)
- **EXG An,Dn** — address↔data exchange removed; only Dn↔Dn and An↔An
- **DBcc** — removed on V2/V3; use `DBNZ` or restructure loops with `BNE`
- Shift by register count > `.l` — memory shifts removed

### New/different instructions

```asm
    ; ColdFire 32×32→32 multiply (replaces MULS.W)
    muls.l  d1,d0            ; d0 = d0 × d1 (signed, lower 32 bits)
    mulu.l  d1,d0            ; unsigned

    ; Move multiple (ColdFire form — no predecrement on load with list)
    movem.l d0-d5,-(sp)      ; push OK
    movem.l (sp)+,d0-d5      ; pop OK
    ; Note: CF only allows register lists in movem; no arbitrary EA forms

    ; BYTEREV — reverse byte order
    byterev d0               ; swap bytes within Dn (V2+)

    ; FF1 — find first one (like BSF/BSR on x86)
    ff1     d0               ; d0 = position of MSB set (undefined if d0=0)

    ; STLDSR — store/load SR (V2+ supervisor)
    stldsr  #<flags>
```

### EMAC (Enhanced MAC) instructions

```asm
    ; Accumulator registers: ACC0-ACC3 (V4e), ACC (V2/V3)
    mac.l   d0,d1,acc        ; ACC += d0 × d1
    msac.l  d0,d1,acc        ; ACC -= d0 × d1
    mac.w   d0.u,d1.l,acc    ; word × longword

    ; Move to/from accumulator
    move.l  acc,d0
    move.l  d0,acc
    move.l  accext01,d0      ; extended accumulator (V4e)

    ; Mask register
    move.l  mask,d0
    move.l  d0,mask
```

---

## ColdFire Assembly Tips

### Replace DBRA loop

M68k style (not available on CF V2/V3):
```asm
    moveq   #15,d0
.lp: ; body
    dbra    d0,.lp
```

ColdFire equivalent:
```asm
    moveq   #16,d0           ; count (not N-1)
.lp: ; body
    subq.l  #1,d0
    bne     .lp
```

Or for known-positive:
```asm
    moveq   #15,d0
.lp: ; body
    subq.l  #1,d0
    bpl     .lp
```

### Replace LINK.W

```asm
; M68k
    link    a6,#-16

; ColdFire (always .l)
    link    a6,#-16          ; vasm auto-selects .l for CF targets
```

### Index scaling
ColdFire only supports `.l` index registers (no `.w`), and scale factor is limited:

```asm
; OK on ColdFire:
    move.l  (a0,d0.l),d1
    move.l  (a0,d0.l*4),d1

; NOT OK (word index — will error):
    move.l  (a0,d0.w),d1
```

### Stack alignment
ColdFire requires **4-byte (longword) stack alignment** at all times. Misaligned stacks cause address errors.

---

## Linker Script Example (ColdFire embedded, GCC/GNU ld)

```ld
MEMORY {
    flash : ORIGIN = 0x00000000, LENGTH = 512K
    sram  : ORIGIN = 0x20000000, LENGTH = 64K
}
SECTIONS {
    .text  : { *(.text) } > flash
    .rodata: { *(.rodata) } > flash
    .data  : { *(.data) } > sram AT > flash
    .bss   : { *(.bss) } > sram
}
```