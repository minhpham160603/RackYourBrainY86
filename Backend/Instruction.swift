//
//  File.swift
//  
//
//  Created by Minh Pham on 13/04/2023.
//

import Foundation

enum MNEMONIC : String, CaseIterable {
    case irmovq = "irmovq"
    case rmmovq = "rmmovq"
    case mrmovq = "mrmovq"
    case jmp = "jmp"
    case jle = "jle"
    case jl = "jl"
    case je = "je"
    case jne = "jne"
    case jge = "jge"
    case jg = "jg"
    case nop = "nop"
    case halt = "halt"
    case addq = "addq"
    case subq = "subq"
    case andq = "andq"
    case xorq = "xorq"
    case undefine
}

func getByteInstruction(by mnemonic: MNEMONIC) -> Int{
    switch(mnemonic){
    case .irmovq:
        return 10
    case .rmmovq:
        return 10
    case .mrmovq:
        return 10
    case .jmp:
        return 8
    case .jle:
        return 8
    case .jl:
        return 8
    case .je:
        return 8
    case .jne:
        return 8
    case .jge:
        return 8
    case .jg:
        return 8
    case .addq:
        return 2
    case .subq:
        return 2
    case .andq:
        return 2
    case .xorq:
        return 2
    case .nop:
        return 1
    case .halt:
        return 1
    case .undefine:
        return 0
    }
}

enum InstructionDecodeError : Error {
    case undefineMnemonic
    case invalidInstruction
}

class Instruction : Identifiable, ObservableObject {
    let mnemonic : MNEMONIC
    let rA : REGISTER
    let rB : REGISTER
    let D: String
    let V: String
    let id = UUID()
    var label : String
    var isExecuted: Bool = false
    @Published var showPopOver = false 
    
    init() {
        self.mnemonic = .undefine
        self.rA = .F
        self.rB = .F
        self.D = ""
        self.V = ""
        self.label = ""
    }
    
    init(mnemonic: MNEMONIC, rA: REGISTER = REGISTER.F, rB: REGISTER = REGISTER.F, D: String = "", V: String = "", label: String = ""){
        self.mnemonic = mnemonic
        self.rA = rA
        self.rB = rB
        self.D = D
        self.V = V
        self.label = label
    }
    
    static func parseString(_ string: String) throws ->  Instruction {
        let separators = CharacterSet(charactersIn: " ,()")
        let partition = string.components(separatedBy: separators).filter {!$0.isEmpty}
        let numbers: Set<Int> = [1, 2, 3, 4]
        
        if !numbers.contains(partition.count){
            throw InstructionDecodeError.invalidInstruction
        }
        
        var mnemonic = MNEMONIC.undefine
        for mne in MNEMONIC.allCases {
            if mne.rawValue == partition[0] {
                mnemonic = mne
            }
        }
        if (mnemonic == MNEMONIC.undefine){
            throw InstructionDecodeError.undefineMnemonic
        }
        var rA : REGISTER = .F, rB: REGISTER = .F, D : String = "", V: String = ""
        switch(mnemonic){
        case .irmovq:
            V = partition[1]
            rB = name_to_register[partition[2]] ?? .F
        case .rmmovq:
            if partition.count == 4 {
                rA = name_to_register[partition[1]] ?? .F
                rB = name_to_register[partition[3]] ?? .F
                D = partition[2]
            } else if partition.count == 3 {
                rA = name_to_register[partition[1]] ?? .F
                D = partition[2]
            } else {
                throw InstructionDecodeError.invalidInstruction
            }
        case .mrmovq:
            if partition.count == 4 {
                rA = name_to_register[partition[3]] ?? .F
                rB = name_to_register[partition[2]] ?? .F
                D = partition[1]
            } else if partition.count == 3 {
                rA = name_to_register[partition[2]] ?? .F
                D = partition[1]
            } else {
                throw InstructionDecodeError.invalidInstruction
            }
        case .nop:
            return Instruction(mnemonic: .nop)
        case .halt:
            return Instruction(mnemonic: .halt)
        case .addq:
            if partition.count != 3 {
                throw InstructionDecodeError.invalidInstruction
            }
            rA = name_to_register[partition[1]] ?? .F
            rB = name_to_register[partition[2]] ?? .F
        case .subq:
            if partition.count != 3 {
                throw InstructionDecodeError.invalidInstruction
            }
            rA = name_to_register[partition[1]] ?? .F
            rB = name_to_register[partition[2]] ?? .F
        case .andq:
            if partition.count != 3 {
                throw InstructionDecodeError.invalidInstruction
            }
            rA = name_to_register[partition[1]] ?? .F
            rB = name_to_register[partition[2]] ?? .F
        case .xorq:
            if partition.count != 3 {
                throw InstructionDecodeError.invalidInstruction
            }
            rA = name_to_register[partition[1]] ?? .F
            rB = name_to_register[partition[2]] ?? .F
        case .undefine:
            break
        case .jmp:
            D = partition[1]
        case .jle:
            D = partition[1]
        case .jl:
            D = partition[1]
        case .je:
            D = partition[1]
        case .jne:
            D = partition[1]
        case .jge:
            D = partition[1]
        case .jg:
            D = partition[1]
        }
        return Instruction(mnemonic: mnemonic, rA: rA, rB: rB, D: D, V: V)
    }
    
    static func parseMultipleString(string: String) -> [Instruction] {
        var index = 0
        var instructionList : [Instruction] = []
        let partition = string.components(separatedBy: "\n").filter {
            $0.count > 0
        }
        while index < partition.count {
            var instruction : Instruction
            var label = ""
            if partition[index].contains(":") {
                label = String(partition[index].prefix(while: {$0 != ":"}))
                index += 1
            }
            do {
                instruction = try parseString(partition[index])
                instruction.label = label
            } catch {
                print("Contain unvalid instruction")
                return []
            }
            instructionList.append(instruction)
            index += 1
        }
        return instructionList
    }
    
    static func getTextFromList(_ instruction_list: [Instruction]) -> String {
        var output_string = ""
        for instruction in instruction_list {
            output_string += instruction.getText() + "\n"
        }
        return output_string
    }
    
    func getText() -> String {
        var outputString = ""
        switch(self.mnemonic){
        case .halt:
            outputString = "halt"
        case .nop:
            outputString = "nop"
        case .irmovq:
            outputString = "irmovq \t \(self.V), \(self.rB.rawValue)"
        case .rmmovq:
            if self.rB != .F {
                outputString = "rmmovq \t \(self.rA.rawValue), \(self.D)(\(self.rB.rawValue))"
            } else {
                outputString = "rmmovq \t \(self.rA.rawValue), \(self.D)"
            }
        case .mrmovq:
            if self.rB != .F {
                outputString = "mrmovq \t \(self.D)(\(self.rB.rawValue)), \(self.rA.rawValue)"
            } else {
                outputString = "mrmovq \t \(self.D), \(self.rA.rawValue)"
            }
        case .addq:
            outputString = "addq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .subq:
            outputString = "subq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .andq:
            outputString = "andq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .xorq:
            outputString = "xorq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .undefine:
            outputString = ""
        case .jmp:
            outputString = "jmp \t \(self.D)"
        case .jle:
            outputString = "jle \t \(self.D)"
        case .jl:
            outputString = "jl \t \(self.D)"
        case .je:
            outputString = "je \t \(self.D)"
        case .jne:
            outputString = "jne \t \(self.D)"
        case .jge:
            outputString = "jge \t \(self.D)"
        case .jg:
            outputString = "jg \t \(self.D)"
        }
        return outputString
    }
}
