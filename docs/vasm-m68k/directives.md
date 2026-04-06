# vasm Motorola Syntax — Full Directives Reference

## Table of Contents
1. [Section & Origin](#section--origin)
2. [Data Definition](#data-definition)
3. [Symbol Definition](#symbol-definition)
4. [Macros](#macros)
5. [Conditional Assembly](#conditional-assembly)
6. [Repeat & Loop](#repeat--loop)
7. [Alignment](#alignment)
8. [File Inclusion](#file-inclusion)
9. [Listing Control](#listing-control)
10. [Miscellaneous](#miscellaneous)

---

## Section & Origin

### `org <expr>`
Sets the program counter to an absolute value. In flat binary output, this determines where subsequent code/data is placed.

```asm
    org     $C00000          ; VDP data port address (Genesis)
```

### `section <name>[,<type>[,<flags>]]`
Declares a named section. Used with relocatable output formats (ELF, hunk, vobj).

| Type keyword | Meaning |
|--------------|---------|
| `code` | Executable code |
| `data` | Initialized data |
| `bss` | Uninitialized data (no space in file) |
| `text` | Alias for `code` |

```asm
    section .text,code
    section .rodata,data
    section .bss,bss
```

### `popsection`
Restore the previous section context (some targets).

---

## Data Definition

### `dc.<size> <expr>[,<expr>...]`
Define Constant — emits bytes/words/longs into the object.

```asm
    dc.b    $0D,$0A,0        ; CR LF NUL
    dc.w    256,-1           ; signed/unsigned word values
    dc.l    MyLabel          ; 32-bit address
    dc.b    "Hello, World!",0  ; ASCII string + terminator
```

String encoding notes:
- Single quotes `'x'` → byte value of character
- Double quotes `"abc"` → sequence of bytes, one per character
- `dc.w "AB"` → packs two ASCII chars into one word (big-endian)

### `dc.<size> <count>,<fill>` — **dcb form**
```asm
    dcb.b   256,$FF          ; 256 bytes of $FF
    dcb.w   8,0              ; 8 zero words
    dcb.l   4,$FFFFFFFF      ; 4 longwords of $FFFFFFFF
```

### `ds.<size> <count>`
Define Storage — reserves space without initializing (except in BSS sections where it's zeroed by the OS/runtime).

```asm
    ds.b    64               ; 64 uninitialized bytes
    ds.w    10               ; 10 uninitialized words
    ds.l    4                ; 4 uninitialized longwords
```

### `dr.<size> <from>,<to>`
Define Range — `dr.b 'a','z'` emits bytes from 'a' to 'z' inclusive.

---

## Symbol Definition

### `<sym> equ <expr>`
Assign a permanent constant value. Cannot be redefined.

```asm
VDP_DATA    equ     $C00000
VDP_CTRL    equ     $C00004
SCREEN_W    equ     320
```

### `<sym> = <expr>`
Alias — like `equ` but some backends allow redefinition.

### `<sym> set <expr>` / `set <sym>,<expr>`
Assignable symbol — can be changed later with another `set`.

```asm
Counter     set     0
Counter     set     Counter+1    ; reassign
```

### `<sym> equr <reg>`
Assign a register alias.

```asm
PtrA        equr    a0
ScratchD    equr    d7
```

### `<sym> reg <reglist>`
Assign a register list name (useful with MOVEM).

```asm
SaveRegs    reg     d0-d3/a0-a1
            movem.l SaveRegs,-(sp)
```

### `rsreset` / `rs.<size> <count>` / `rsset <value>`
Record Structure offset system — simulates C structs.

```asm
    rsreset                  ; reset offset counter to 0
ObjectX     rs.w    1        ; offset 0, size 2
ObjectY     rs.w    1        ; offset 2, size 2
ObjectVX    rs.w    1        ; offset 4, size 2
ObjectVY    rs.w    1        ; offset 6, size 2
OBJECT_SIZE rs.b    0        ; capture current offset = 8

; Usage:
    lea     MyObject,a0
    move.w  ObjectX(a0),d0   ; read X coordinate
```

`rsset <value>` sets the RS counter to an arbitrary value before continuing.

### `xdef <sym>[,<sym>...]` / `xref <sym>[,<sym>...]`
Export / import symbols for linking (relocatable formats only).

```asm
    xdef    Main,InitHW      ; export these symbols
    xref    OSPrint          ; symbol defined in another object
```

### `global <sym>` / `weak <sym>` / `local <sym>`
ELF symbol visibility:
- `global` — exported (same as `xdef`)
- `weak` — exported but overridable by strong definition
- `local` — not exported (default)

---

## Macros

### Basic macro

```asm
MacroName   macro   [param1[,param2[,...]]]
            ; body — use \param1 or \1 for first arg
            endm
```

Argument access:
- `\1` `\2` … `\9` — positional by number
- `\name` — positional by name (if declared in header)
- `\0` — the size suffix passed with the macro invocation
- `\@` — unique label suffix (auto-incrementing, prevents label clashes in loops)
- `\#` — number of arguments passed
- `\!` — remainder of line after last parsed argument

```asm
push_reg    macro   reg
            move.l  \reg,-(sp)
            endm

; Unique label example:
loop_n      macro   count,body
.\@start:   \body
            dbra    \count,.\@start
            endm
```

### `exitm`
Exit macro early (conditional return from macro body).

```asm
safe_div    macro   divisor
            ifeq    \divisor
            exitm
            endif
            divu.w  #\divisor,d0
            endm
```

### `mexit`
Alternative spelling of `exitm`.

### `purgem <name>`
Undefine a macro so it can be redefined.

---

## Conditional Assembly

### `if<cond> <expr>` … `[elseif<cond> <expr>]` … `[else]` … `endif`

| Directive | Condition |
|-----------|-----------|
| `ifeq` | expr == 0 |
| `ifne` | expr != 0 |
| `ifgt` | expr > 0 |
| `iflt` | expr < 0 |
| `ifge` | expr >= 0 |
| `ifle` | expr <= 0 |
| `ifd` / `ifdef` | symbol is defined |
| `ifnd` / `ifndef` | symbol is not defined |
| `ifmacrod` | macro is defined |
| `ifmacrond` | macro is not defined |
| `ifc <str1>,<str2>` | strings are equal |
| `ifnc <str1>,<str2>` | strings are not equal |

```asm
    ifdef   DEBUG
    bsr     DebugDump
    endif

    ifeq    (PLATFORM-GENESIS)
    bsr     InitVDP
    elseif  ifeq (PLATFORM-SATURN)
    bsr     InitSCU
    else
    fail    "Unknown platform"
    endif
```

---

## Repeat & Loop

### `rept <count>` … `endr`
Repeat a block `count` times. `\@` inside gives a unique suffix each iteration.

```asm
    rept    4
    nop
    endr                     ; emits 4 NOPs

    rept    8
Zero\@: dc.l   0             ; Zero0, Zero1, … Zero7
    endr
```

### `irp <sym>,<val1>[,<val2>...]` … `endr`
Iterate, substituting each value for `\sym`.

```asm
    irp     reg,d0,d1,d2,d3
    clr.l   \reg
    endr
```

### `irpc <sym>,<string>` … `endr`
Iterate character by character through a string.

---

## Alignment

### `even`
Align to the next even (2-byte) boundary. Pads with `$00` (or NOP on some configurations).

```asm
    dc.b    "Hello"
    even                     ; ensure next instruction is word-aligned
SomeFunc:
    rts
```

### `odd`
Align to the next odd address (rarely used).

### `align <n>[,<fill>]`
Align to a power-of-2 boundary, optionally specifying fill byte.

```asm
    align   4                ; longword align
    align   2,$4E71          ; word-align, fill with NOP ($4E71)
    align   16               ; cache-line align
```

### `cnop <offset>,<alignment>`
Align so that `(current_address mod alignment) == offset`.

```asm
    cnop    2,4              ; ensure addr mod 4 == 2
```

---

## File Inclusion

### `include "<file>"`
Textually includes another source file. Searched in `-I` paths.

```asm
    include "hardware/vdp.inc"
    include "macros.inc"
```

### `incbin "<file>"[,<offset>[,<length>]]`
Include raw binary data from a file.

```asm
    incbin  "sprites.bin"
    incbin  "font.raw",0,4096       ; first 4096 bytes only
    incbin  "sound.pcm",$1000       ; from offset $1000 to end
```

---

## Listing Control

```asm
    list                     ; enable listing output
    nolist                   ; suppress listing for following lines
    llen    <n>              ; set listing line length
    plen    <n>              ; set listing page length
    ttl     "Title"          ; set listing title
    page                     ; force page break in listing
```

---

## Miscellaneous

### `end [<expr>]`
End of assembly. Optional start address for formats that support it.

### `fail "<message>"`
Unconditionally emit an assembly error with message.

### `warning "<message>"` / `inform <level>,"<message>"`
Emit a warning or informational message.
- Level 0 = always printed
- Level 1 = standard warning
- Level 2 = verbose

### `output "<filename>"`
Override the default output filename from within the source.

### `cpu <name>`
Switch CPU target mid-assembly (use sparingly).

```asm
    cpu     68020
    ; 68020+ instructions here
    cpu     68000
```

### `opt <options>`
Set assembler options inline (not all options supported this way).

### `printt "<str>"` / `printv <expr>`
Print text or expression value during assembly (debug aid).

```asm
    printv  ROMSIZE          ; shows numeric value
    printt  "Assembling header..."
```