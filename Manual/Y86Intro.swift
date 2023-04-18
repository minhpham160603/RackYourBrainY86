//
//  File.swift
//  
//
//  Created by Minh Pham on 18/04/2023.
//

import Foundation

var introY86 = """
Y86 is a toy RISC CPU instruction set for education purpose. It was invented before 1996 as a companion for the book The Art of Assembly Language to illustrate the basic principles of how a CPU works and how you can write programs for it.

In older editions of the book, Y86 was called x86. Apparently the architecture we now know as x86 wasn't called that back then, the book instead calls that architecture 80x86. Later editions of the book mostly call this language Y86, but there are a few places in the text where they forgot to replace the name.

The language is supposedly implemented by four hypothetical CPUs with different performance characteristics, called 886, 8286, 8486, 8686. The book defines execution times of the instructions (measured in clock cycles) for the 886, and some information for how much pipelining the other CPUs do.

II. Architecture
Y86 accesses a single memory of bytes with a 16-bit address space. The CPU is little-endian.

The Y86 registers include

an instruction pointer,
a comparison indicator (arithmetic status flags, condition code) whose state can be one of above, equal, below
and four 16-bit general purpose registers called AX, BX, CX, DX,
and possibly some save registers for supporting interrupt handling routines of whose workings I do not know.
The instructions for Y86 are one, two, or three bytes long. The instructions are ran sequentially from lower to higher address, except when a jump instruction, interrupt, or return from interrupt is ran.

Source: https://esolangs.org/wiki/Y86#:~:text=Y86%20is%20a%20toy%20RISC,book%2C%20Y86%20was%20called%20x86.
"""

var registerManual = """
A processor register is a quickly accessible location available to a computer's processor. Registers usually consist of a small amount of fast storage, although some registers have specific hardware functions, and may be read-only or write-only. In computer architecture, registers are typically addressed by mechanisms other than main memory, but may in some cases be assigned a memory address.

Almost all computers, whether load/store architecture or not, load items of data from a larger memory into registers where they are used for arithmetic operations, bitwise operations, and other operations, and are manipulated or tested by machine instructions. Manipulated items are then often stored back to main memory, either by the same instruction or by a subsequent one. Modern processors use either static or dynamic RAM as main memory, with the latter usually accessed via one or more cache levels.

Note that in this game, we only use 10 over 15 registers of Y86-64 architecture.

Source: Wikipedia
"""


var memoryManual = """
In computing, virtual memory, or virtual storage[b] is a memory management technique that provides an "idealized abstraction of the storage resources that are actually available on a given machine"[3] which "creates the illusion to users of a very large (main) memory".[4]

The computer's operating system, using a combination of hardware and software, maps memory addresses used by a program, called virtual addresses, into physical addresses in computer memory. Main storage, as seen by a process or task, appears as a contiguous address space or collection of contiguous segments. The operating system manages virtual address spaces and the assignment of real memory to virtual memory

In this game, we are only using a small part of memory (80 bytes), starting from 256 (0x100).

Source: Wikipedia
"""


var CCManual = """
Z (Zero flag): Indicates that the result of an arithmetic or logical operation (or, sometimes, a load) was zero.

C (Carry flag): Enables numbers larger than a single word to be added/subtracted by carrying a binary digit from a less significant word to the least significant bit of a more significant word as needed. It is also used to extend bit shifts and rotates in a similar manner on many processors (sometimes done via a dedicated X flag).

S / N (Sign flag / Negative flag: Indicates that the result of a mathematical operation is negative. In some) processors,[2] the N and S flags are distinct with different meanings and usage: One indicates whether the last result was negative whereas the other indicates whether a subtraction or addition has taken place.
"""

let mnemonicDescriptions: [MNEMONIC: String] = [
    .irmovq: "Immediate Move Quadword - Move immediate data to a register",
    .rmmovq: "Register to Memory Move Quadword - Move data from a register to a memory location",
    .mrmovq: "Memory to Register Move Quadword - Move data from a memory location to a register",
    .jmp: "Unconditional Jump - Jump to a new address unconditionally",
    .jle: "Jump Less or Equal - Jump to a new address if the last comparison result was less than or equal",
    .jl: "Jump Less - Jump to a new address if the last comparison result was less",
    .je: "Jump Equal - Jump to a new address if the last comparison result was equal",
    .jne: "Jump Not Equal - Jump to a new address if the last comparison result was not equal",
    .jge: "Jump Greater or Equal - Jump to a new address if the last comparison result was greater than or equal",
    .jg: "Jump Greater - Jump to a new address if the last comparison result was greater",
    .nop: "No Operation - Do nothing",
    .halt: "Halt - Stop execution",
    .addq: "Add Quadword - Add a value to a register",
    .subq: "Subtract Quadword - Subtract a value from a register",
    .andq: "Bitwise AND Quadword - Bitwise AND a value with a register",
    .xorq: "Bitwise XOR Quadword - Bitwise XOR a value with a register",
    .undefine: "Undefined - An undefined mnemonic"
]
