//
//  File.swift
//  
//
//  Created by Minh Pham on 16/04/2023.
//

import Foundation


// Memory
var items = [Item(address: 0x0010, label: "src", value: 0x00a),
            Item(address: 0x0018, label: "", value: 0x0b0),
            Item(address: 0x0024, label: "", value: 0xc00)]

var memoryBoard = MemoryBoard()

var string1 = """
.pos 256
t:
    .quad 1
x:
    .quad 4
y:
    .quad 3
"""

var itemList = MemoryBoard.parseMemoryInputString(string: string1)

// Register
var register_file = RegisterFile()


// Instructions
var string_instr = "mrmovq src(%rcx), %rdx"
var instruction_string_code =
"""
irmovq $8, %rcx
subq %rdx, %r9
jmp Lend
Lhat:
    irmovq $123, %rdx
Lend:
    mrmovq t, %r8
halt
"""
var instruction_list = Instruction.parseMultipleString(string: instruction_string_code)
