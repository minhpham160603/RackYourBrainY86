//
//  VirtualMachine.swift
//  
//
//  Created by Minh Pham on 14/04/2023.
//

import Foundation
import Combine

enum ExecutionError : Error {
    case instructionCounterOutOfBound
}

class VirtualMachine : ObservableObject {
    @Published var registerFile : RegisterFile
    @Published var memoryBoard : MemoryBoard
    @Published var instructionBoard : [Int: Instruction]
    @Published var programCounter: Int
    @Published var ConditionCode : [String : Int] = ["OF":0, "ZF":0, "SF":0]
    
    init(instructionList: [Instruction], memoryItemList : [Item] = []) {
        registerFile = RegisterFile()
        if !memoryItemList.isEmpty {
            memoryBoard = MemoryBoard(items: memoryItemList)
        }  else {
            memoryBoard = MemoryBoard()
        }
        programCounter = 0
        instructionBoard = [:]
        var previousCounter = 0
        for instruction in instructionList {
            instructionBoard[previousCounter] = instruction
            previousCounter += getByteInstruction(by: instruction.mnemonic)
        }
    }
    
    func updateConditionCode(valRA: Int, valRB: Int) {
        let newVal = valRA.addingReportingOverflow(valRB)
        if newVal.partialValue == 0 {
            ConditionCode["ZF"] = 1
            ConditionCode["OF"] = 0
            ConditionCode["SF"] = 0
        } else if newVal.partialValue < 1 {
            ConditionCode["SF"] = 1
            ConditionCode["OF"] = 0
            ConditionCode["ZF"] = 0
        } else {
            if newVal.overflow {
                ConditionCode["OF"] = 1
                ConditionCode["ZF"] = 0
                ConditionCode["SF"] = 0
            }
            else {
                ConditionCode["OF"] = 0
                ConditionCode["ZF"] = 0
                ConditionCode["SF"] = 0
            }
        }
    }
    
    func jump(instruction: Instruction){
            for (address, item) in instructionBoard {
                if item.label == instruction.D {
                    programCounter = address - getByteInstruction(by: instruction.mnemonic)
                }
            }
    }
    
    func executeInstruction(instruction: Instruction) {
        let valRA = registerFile.files[instruction.rA] ?? 0
        let valRB = registerFile.files[instruction.rB] ?? 0
        
        switch(instruction.mnemonic){
        case .halt:
            print("halt")
             break
        case .nop:
            print("nop")
             break
        case .irmovq:
            registerFile.files[instruction.rB] = Int(String(instruction.V.dropFirst(1)))
        case .rmmovq:
            var memoryItemAddress : Int
            
            do {
                try memoryItemAddress = memoryBoard.getLabelAddress(label: instruction.D)
            } catch let error{
                print(error.localizedDescription)
                break
            }
            
            if instruction.rB != .F {
                memoryItemAddress += valRB
            }
            
            if let item = self.memoryBoard.items[memoryItemAddress] {
                item.value = valRA
            } else {
                print("Invalid Memory Address")
                break
            }
            
        case .mrmovq:
            var memoryItemAddress : Int
            
            do {
                try memoryItemAddress = memoryBoard.getLabelAddress(label: instruction.D)
            } catch let error{
                print(error.localizedDescription)
                break
            }
            if instruction.rB != .F {
                memoryItemAddress += valRB
            }
            
            if let item = self.memoryBoard.items[memoryItemAddress] {
                registerFile.files[instruction.rA]! = item.value
            } else {
                print("Invalid Memory Address")
                break
            }
            
        case .addq:
            registerFile.files[instruction.rB]! += valRA
            updateConditionCode(valRA: valRA, valRB: valRB)
            
        case .subq:
            registerFile.files[instruction.rB]! -= valRA
            updateConditionCode(valRA: valRA, valRB: valRB)
            
        case .andq:
            registerFile.files[instruction.rB]! &= valRA
            updateConditionCode(valRA: valRA, valRB: valRB)
            
        case .xorq:
            registerFile.files[instruction.rB]! ^= valRA
            updateConditionCode(valRA: valRA, valRB: valRB)
            
        case .jmp:
            jump(instruction: instruction)
            
        case .jle:
            if ConditionCode["SF"] == 1 {
                jump(instruction: instruction)
            } else {
                self.programCounter += getByteInstruction(by: instruction.mnemonic)
            }
            
        case .jl:
            if ConditionCode["SF"] == 1 {
                jump(instruction: instruction)
            } else {
                self.programCounter += getByteInstruction(by: instruction.mnemonic)
            }
            
        case .je:
            if ConditionCode["ZF"] == 1 {
                jump(instruction: instruction)
            } else {
                self.programCounter += getByteInstruction(by: instruction.mnemonic)
            }
            
        case .jne:
            if ConditionCode["ZF"] == 0 {
                jump(instruction: instruction)
            } else {
                self.programCounter += getByteInstruction(by: instruction.mnemonic)
            }
            
        case .jge:
            if ConditionCode["SF"] == 0 || ConditionCode["ZF"] == 1 {
                jump(instruction: instruction)
            } else {
                self.programCounter += getByteInstruction(by: instruction.mnemonic)
            }
            
        case .jg:
            if ConditionCode["SF"] == 0 {
                jump(instruction: instruction)
            } else {
                self.programCounter += getByteInstruction(by: instruction.mnemonic)
            }
            
        case .undefine:
             print("Undefine instruciton")
        }
        
        self.programCounter += getByteInstruction(by: instruction.mnemonic)
    }
    
    func executeCurrentInstruction() throws {
        if let instruction = instructionBoard[programCounter] {
            executeInstruction(instruction: instruction)
        } else {
            throw ExecutionError.instructionCounterOutOfBound
        }
    }
    
}
