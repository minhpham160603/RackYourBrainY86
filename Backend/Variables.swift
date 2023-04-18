//
//  File.swift
//  
//
//  Created by Minh Pham on 16/04/2023.
//

import Foundation
import SwiftUI


// Memory
var items = [Item(address: 0x0010, label: "src", value: 0x00a),
            Item(address: 0x0018, label: "", value: 0x0b0),
            Item(address: 0x0024, label: "", value: 0xc00)]

//var memoryBoard = MemoryBoard()

var memoryStringGame1 = """
.pos 256
x:
    .quad 0x1
y:
    .quad 0x2
"""

// Register
//var register_file = RegisterFile()


// Instructions
var codeStringGame1 =
"""
 mrmovq y, %rax
 mrmovq x, %rbx
 irmovq $4, %rcx
 addq %rax, %rcx
 addq %rbx, %rcx
 rmmovq %rcx, x
 halt
"""

var game_1 = Game(instructionList: Instruction.parseMultipleString(string: codeStringGame1), memoryItemList: MemoryBoard.parseMemoryInputString(string: memoryStringGame1))



// Game 1
var codeStringGame2 = """
mrmovq sum, %rax
mrmovq len, %rsi
irmovq $0, %rdi

Lloop:
    mrmovq src(%rdi), %rcx
    rmmovq %rcx, dest(%rdi)
    addq %rcx, %rax
    irmovq $1, %rbp
    subq %rbp, %rsi
    je Lend
    irmovq $8, %rbx
    addq %rbx, %rdi
    jmp Lloop

Lend:
    rmmovq %rax, sum
    halt
"""

var instructionListGame2 = Instruction.parseMultipleString(string: codeStringGame2)

var memoryStringGame2 = """
.pos 256
src:
        .quad 0x00a
        .quad 0x0b0
        .quad 0xc00
dest:
        .quad 0x111
        .quad 0x222
        .quad 0x333
len:
        .quad 3
sum:
        .quad 0
"""

var game_2 = Game(instructionList: instructionListGame2, memoryItemList: MemoryBoard.parseMemoryInputString(string: memoryStringGame2))

// Game 3
var codeStringGame3 = """
    mrmovq x, %rax
    mrmovq y, %rbx
    irmovq $5, %rbp
    subq %rax, %rbp
    jl Iftrue
    jmp Lend
Iftrue:
    irmovq $3, %rcx
    addq %rax, %rcx
    rmmovq %rcx, y
Lend:
    rmmovq %rax, y
    halt
"""

var memoryStringGame3 = """
.pos 256
x:
    .quad 14
y:
    .quad 0
"""

var game_3 = Game(instructionList: Instruction.parseMultipleString(string: codeStringGame3), memoryItemList: MemoryBoard.parseMemoryInputString(string: memoryStringGame3))

extension Color {
    init(hex: UInt, alpha: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: alpha
        )
    }
}

var highlightTextColor = Color.blue

extension TextField {
    func whiteBackground() -> some View {
        self.background(Color.white).cornerRadius(6)
    }
}

var normalTextColor = Color(hex: 0x6A6779)

struct NormalText: View {
    var text: String
    
    init(_ text: String) {
        self.text = text
    }
    
    var body: some View {
        Text(text)
            .font(.custom("SF Pro", size: 16)).foregroundColor(normalTextColor)
    }
}
