We will make a software CPU using Intel 8086/8088 instruction set

basically we have a chain from instruction to output, the instruction may call out to memory
or the cache's on the core to do some operation

instructions ->  | CPU | -> output

## MOV

Move is our first instruction. Technically, its a copy, seeing as the data still exists the original dest

```nasm
; command destination(D), source(S)
mov       ax,          bx
```

The way this gets encoded in machine code is 2 bytes

           8 bit block       8 bit block
| 100010       DW          |  MOD    REG    R/M |
6-bit = mov <> 2-bit params   2-bit, 3-bit, 3-bit params

- 100010 => mov instruction
- D => if 0 then REG is not dest, meaning destination can be memory or register but not source
    - REG = S
- W => is Wide?
    - if 0 then narrow (8 bits), else wide (16 bits)

- MOD => expresses type of destination and source
    - MOD = 11, represents a copy from one register to another
- REG => encodes register (look at the name)
- R/M => encodes register or memory
- MOD, REG, R/M are decoded using a table

```nasm
; asm lets you choose what parts of n bit register get copied
mov ax, bx ; moves total contents of bx into ax
mov al, bl ; moves low (least significant half) bit contents of bx into ax
mov ah, bh ; moves high bit contents of bx into ax
```

