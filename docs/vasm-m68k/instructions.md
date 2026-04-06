# M68k Instruction Set — vasm Reference

## Table of Contents
1. [Data Transfer](#data-transfer)
2. [Integer Arithmetic](#integer-arithmetic)
3. [BCD Arithmetic](#bcd-arithmetic)
4. [Logic](#logic)
5. [Shift & Rotate](#shift--rotate)
6. [Bit Manipulation](#bit-manipulation)
7. [Program Control](#program-control)
8. [System Control](#system-control)
9. [68020+ Extensions](#68020-extensions)
10. [FPU Instructions (68881/68882/68040/68060)](#fpu)
11. [Addressing Mode Constraints](#addressing-mode-constraints)

---

## Data Transfer

| Mnemonic | Sizes | Src modes | Dst modes | Notes |
|----------|-------|-----------|-----------|-------|
| `MOVE` | b/w/l | all | all (not An for .b) | general move |
| `MOVEA` | w/l | all | An | address register; `.w` sign-extends |
| `MOVEQ` | — | #imm(-128..127) | Dn | fast 1-word encoding |
| `MOVEM` | w/l | (An)/d16(An)/d8(An,Xn)/abs/d16(PC) | same | register list transfer |
| `MOVEP` | w/l | d16(An) | Dn / Dn | peripheral; alternating byte lanes |
| `MOVE CCR` | w | all data | CCR | write condition codes |
| `MOVE SR` | w | SR | all data | read SR (supervisor) |
| `MOVE USP` | l | USP/An | An/USP | user stack pointer (supervisor) |
| `LEA` | l | control modes | An | load effective address |
| `PEA` | l | control modes | — | push EA onto stack |
| `EXG` | l | Dn/An | Dn/An | exchange registers |
| `LINK` | w (l on 020+) | An | #disp | stack frame allocate |
| `UNLK` | — | An | — | release stack frame |
| `CLR` | b/w/l | alterable | — | clear to zero |
| `SWAP` | w | Dn | — | swap upper/lower words of Dn |

---

## Integer Arithmetic

| Mnemonic | Sizes | Notes |
|----------|-------|-------|
| `ADD` | b/w/l | Dn↔EA |
| `ADDA` | w/l | EA→An; `.w` sign-extends |
| `ADDI` | b/w/l | #imm→EA |
| `ADDQ` | b/w/l | #1-8→EA (fast) |
| `ADDX` | b/w/l | Dn+Dn+X or -(An)+-(An)+X |
| `SUB` | b/w/l | Dn↔EA |
| `SUBA` | w/l | EA−An |
| `SUBI` | b/w/l | #imm−EA |
| `SUBQ` | b/w/l | EA−#1-8 |
| `SUBX` | b/w/l | Dn−Dn−X or -(An)−-(An)−X |
| `MULS` | w→l | Dn×EA signed (020: l×l→64) |
| `MULU` | w→l | Dn×EA unsigned (020: l×l→64) |
| `DIVS` | w→l | Dn÷EA signed |
| `DIVU` | w→l | Dn÷EA unsigned |
| `DIVSL` / `DIVUL` | l | 020+ 32÷32 or 64÷32 |
| `NEG` | b/w/l | negate |
| `NEGX` | b/w/l | negate with extend |
| `EXT` | w/l | sign-extend Dn (byte→word or word→long) |
| `EXTB` | l | byte→long sign-extend (020+) |
| `ABCD` | b | add BCD with X |
| `SBCD` | b | subtract BCD with X |
| `NBCD` | b | negate BCD with X |
| `CMP` | b/w/l | compare, set flags (no result stored) |
| `CMPA` | w/l | compare An |
| `CMPI` | b/w/l | compare #imm |
| `CMPM` | b/w/l | compare (An)+ vs (An)+ |
| `TST` | b/w/l | test and set N/Z flags |
| `TAS` | b | test-and-set byte, atomic bus cycle |

---

## BCD Arithmetic

All BCD instructions operate on byte-sized packed BCD values.

| Mnemonic | Notes |
|----------|-------|
| `ABCD Dx,Dy` | Dy ← Dy + Dx + X (BCD) |
| `ABCD -(Ax),-(Ay)` | memory form |
| `SBCD Dx,Dy` | Dy ← Dy − Dx − X (BCD) |
| `NBCD <ea>` | negate BCD with extend |
| `PACK` | 020+ unpack BCD |
| `UNPK` | 020+ pack BCD |

---

## Logic

| Mnemonic | Sizes | Notes |
|----------|-------|-------|
| `AND` | b/w/l | Dn & EA → Dn (or Dn & EA → EA) |
| `ANDI` | b/w/l | #imm & EA |
| `ANDI CCR` | b | AND into CCR |
| `ANDI SR` | w | AND into SR (supervisor) |
| `OR` | b/w/l | Dn \| EA |
| `ORI` | b/w/l | #imm \| EA |
| `ORI CCR` | b | OR into CCR |
| `EOR` | b/w/l | Dn ^ EA (source must be Dn) |
| `EORI` | b/w/l | #imm ^ EA |
| `NOT` | b/w/l | bitwise invert |

---

## Shift & Rotate

All shift/rotate: count can be `#1-8` (immediate) or `Dn` (register, mod 64).  
Memory forms shift/rotate by 1 only; word-size only.

| Mnemonic | Direction | Type | Carry | X |
|----------|-----------|------|-------|---|
| `ASL` | left | Arithmetic | MSB out | ← C |
| `ASR` | right | Arithmetic (sign fill) | LSB out | ← C |
| `LSL` | left | Logical (0 fill) | MSB out | ← C |
| `LSR` | right | Logical (0 fill) | LSB out | ← C |
| `ROL` | left | Rotate | MSB out, wraps | unchanged |
| `ROR` | right | Rotate | LSB out, wraps | unchanged |
| `ROXL` | left | Rotate through X | MSB→C, X in LSB | ← MSB |
| `ROXR` | right | Rotate through X | LSB→C, X in MSB | ← LSB |

```asm
    lsl.l   #2,d0            ; d0 <<= 2 (multiply by 4)
    asr.w   #1,d1            ; d1 >>= 1 signed (divide by 2)
    rol.l   d2,d0            ; rotate d0 left by d2 bits
```

---

## Bit Manipulation

Bit number: immediate `#n` (0-31 for Dn, 0-7 for memory).

| Mnemonic | Effect |
|----------|--------|
| `BTST #n,<ea>` | Z ← NOT bit_n; flags only |
| `BSET #n,<ea>` | Z ← NOT bit_n; set bit |
| `BCLR #n,<ea>` | Z ← NOT bit_n; clear bit |
| `BCHG #n,<ea>` | Z ← NOT bit_n; flip bit |
| `BFCHG` | 020+ bit field change |
| `BFCLR` | 020+ bit field clear |
| `BFEXTS` | 020+ bit field extract signed |
| `BFEXTU` | 020+ bit field extract unsigned |
| `BFFFO` | 020+ bit field find first one |
| `BFINS` | 020+ bit field insert |
| `BFSET` | 020+ bit field set |
| `BFTST` | 020+ bit field test |

Bit field syntax: `{offset:width}` — both can be Dn or immediate.

```asm
    bfextu  d0{8:4},d1       ; extract 4-bit field at bit 8 (unsigned)
    bfins   d2,d0{4:8}       ; insert d2 into bits 4-11 of d0
```

---

## Program Control

### Unconditional

```asm
    bra[.s/.w]  label        ; branch (short: ±127B, word: ±32K)
    jmp         <ea>         ; jump (control modes only)
    bsr[.s/.w]  label        ; branch to subroutine
    jsr         <ea>         ; jump to subroutine
    rts                      ; return from subroutine
    rtd         #<disp>      ; return and deallocate (010+)
    rtr                      ; restore CCR from stack, then RTS
```

### Conditional branches (all: `.s` = 8-bit, `.w` = 16-bit, 020+: `.l` = 32-bit)

| Mnemonic | Condition | CCR test |
|----------|-----------|----------|
| `BEQ` | Equal / zero | Z=1 |
| `BNE` | Not equal | Z=0 |
| `BMI` | Minus | N=1 |
| `BPL` | Plus | N=0 |
| `BCS` / `BLO` | Carry set / unsigned lower | C=1 |
| `BCC` / `BHS` | Carry clear / unsigned higher-same | C=0 |
| `BVS` | Overflow set | V=1 |
| `BVC` | Overflow clear | V=0 |
| `BHI` | Unsigned higher | C=0 & Z=0 |
| `BLS` | Unsigned lower-same | C=1 \| Z=1 |
| `BGT` | Signed greater | N=V & Z=0 |
| `BGE` | Signed greater-equal | N=V |
| `BLT` | Signed less | N≠V |
| `BLE` | Signed less-equal | Z=1 \| N≠V |

### DBcc — Decrement and Branch

Format: `DB<cc> Dn,label`  
Logic: if NOT cc then { Dn−=1; if Dn≠−1 then branch }

| Mnemonic | Extra condition |
|----------|----------------|
| `DBRA` / `DBF` | never (always decrement/branch) |
| `DBT` | always true (loop body executes once) |
| + all Bcc variants | same condition codes |

```asm
    ; Loop exactly 256 times
    move.w  #255,d0
.lp: ; body
    dbra    d0,.lp
```

### Scc — Set Byte on Condition

Format: `S<cc> <ea>` — sets byte to $FF if true, $00 if false.

```asm
    cmp.w   d1,d0
    seq     d2           ; d2.b = $FF if d0==d1, else $00
```

---

## System Control

```asm
    nop                      ; no operation (also pipeline sync on some CPUs)
    stop    #<data>          ; load SR, halt until interrupt
    reset                    ; assert RESET pin (supervisor)
    rte                      ; return from exception
    illegal                  ; trigger illegal instruction exception ($10)
    trap    #<0-15>          ; software trap
    trapv                    ; trap on overflow
    chk     <ea>,Dn          ; check register against bounds
    chk2    <ea>,Rn          ; 020+ — check against lower+upper bound pair
    cas     Dc,Du,<ea>       ; 020+ compare and swap (atomic)
    cas2    Dc1:Dc2,Du1:Du2,(Rn1):(Rn2) ; 020+ double CAS
    moves   <ea>,Rn          ; 010+ move to/from alternate space
    movec   Rc,Rn            ; 010+ move control register
```

### MOVEC control registers (010+)

| Register | Symbol | Description |
|----------|--------|-------------|
| SFC | `sfc` | Source function code |
| DFC | `dfc` | Destination function code |
| USP | `usp` | User stack pointer |
| VBR | `vbr` | Vector base register |
| CACR | `cacr` | Cache control (020+) |
| CAAR | `caar` | Cache address (020/030) |
| MSP | `msp` | Master stack pointer (020+) |
| ISP | `isp` | Interrupt stack pointer (020+) |
| TC | `tc` | MMU translation control (030/040) |
| ITT0/1 | `itt0` | Instruction transparent translation (040) |
| DTT0/1 | `dtt0` | Data transparent translation (040) |
| MMUSR | `mmusr` | MMU status register (040) |
| URP/SRP | `urp` | MMU pointer registers (040) |
| PCR | `pcr` | Processor control (060) |

---

## 68020+ Extensions

### Scaled index addressing

```asm
    move.l  (a0,d0.l*4),d1  ; a0 + d0×4
    move.b  (a0,d1.w*2),d0  ; a0 + sign_ext(d1.w) × 2
```

Scale factors: `*1` (default), `*2`, `*4`, `*8`

### Memory indirect (020+)

```asm
    move.l  ([a0]),d0              ; indirect through memory longword at a0
    move.l  ([4,a0]),d1            ; indirect with base disp
    move.l  ([a0,d0.l]),d2         ; indirect with index
    move.l  ([a0],d1.w*2,8),d3     ; full form: [base_disp,An,Xn*scale]+od
```

### `CALLM` / `RTM` — module calls (68020 only, removed in later CPUs)

### `cpXxx` — coprocessor instructions
Used for MMU (PMMU) and FPU as prefixed instructions.

---

## FPU

Requires: 68881/68882 coprocessor, or 68040/68060 internal FPU.  
Enable in vasm with: `-m68881` or `-m68040` etc.

### Data types

| Suffix | Type | Size |
|--------|------|------|
| `.s` | Single precision | 32-bit |
| `.d` | Double precision | 64-bit |
| `.x` | Extended precision | 80-bit |
| `.p` | Packed BCD | 96-bit |
| `.w` | Word integer | 16-bit |
| `.l` | Longword integer | 32-bit |
| `.b` | Byte integer | 8-bit |

FPU registers: `fp0`–`fp7`

### Common FPU instructions

```asm
    fmove.d #3.14159,fp0     ; load constant
    fmove.l d0,fp1           ; int→FPU
    fmove.x fp0,(a0)         ; store extended
    fmovem.x fp0-fp3,-(sp)   ; save FPU registers

    fadd.x  fp1,fp0          ; fp0 += fp1
    fsub.d  (a0),fp0         ; fp0 -= memory double
    fmul.x  fp1,fp0
    fdiv.x  fp1,fp0
    fneg.x  fp0
    fabs.x  fp0
    fsqrt.x fp0

    fcmp.x  fp1,fp0          ; compare, set FPU CCR
    ftst.x  fp0              ; test fp0

    fsin.x  fp0
    fcos.x  fp0
    ftan.x  fp0
    fexp.x  fp0              ; e^x
    flog2.x fp0
    flogn.x fp0              ; ln(x)
    flog10.x fp0

    ; FPU moves to/from FPCR/FPSR/FPIAR
    fmove.l fpsr,d0
    fmove.l fpcr,d1

    ; Conditional branches
    fbeq    label
    fbne    label
    fblt    label
    fble    label
    fbgt    label
    fbge    label
```

---

## Addressing Mode Constraints

Not every instruction accepts every addressing mode. Key rules:

| Mode | Code | Can read | Can write | "Control" | "Alterable" |
|------|------|----------|-----------|-----------|-------------|
| Dn | 000 | ✓ | ✓ | | ✓ |
| An | 001 | ✓ | ✓ | | ✓ (for MOVEA etc.) |
| (An) | 010 | ✓ | ✓ | ✓ | ✓ |
| (An)+ | 011 | ✓ | ✓ | | ✓ |
| -(An) | 100 | ✓ | ✓ | | ✓ |
| d16(An) | 101 | ✓ | ✓ | ✓ | ✓ |
| d8(An,Xn) | 110 | ✓ | ✓ | ✓ | ✓ |
| abs.w | 111/000 | ✓ | ✓ | ✓ | ✓ |
| abs.l | 111/001 | ✓ | ✓ | ✓ | ✓ |
| d16(PC) | 111/010 | ✓ | | ✓ | |
| d8(PC,Xn) | 111/011 | ✓ | | ✓ | |
| #imm | 111/100 | ✓ | | | |

- **MOVE**: src = all modes; dst = all except An (for `.b`), PC-rel, and #imm
- **EOR**: source must be Dn
- **CMP src,Dn**: dst is always Dn
- **Scc, CLR, TST, NOT, NEG**: alterable only
- **JMP/JSR, PEA, LEA**: control modes only (no Dn/An/postinc/predec/#imm)
- **MOVEM dst**: cannot use (An)+ form for destination

### Instruction-specific notes

- `MOVEQ` always sign-extends an 8-bit immediate to 32 bits. Range: -128..127 / $00..$FF
- `ADDQ`/`SUBQ` immediate must be 1..8 (encoded as 0=8, 1=1 ... 7=7)
- `BTST Dn,<mem>` tests bit (Dn mod 8); `BTST Dn,Dn` tests bit (Dn mod 32)
- `EXG` only works between pairs: Dn↔Dn, An↔An, Dn↔An
- `LINK` displacement is signed: negative to allocate local vars, positive to adjust
- `CMPM` always uses (Ax)+ and (Ay)+ modes (memory-to-memory compare)