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

struct Instruction : Identifiable {
    let mnemonic : MNEMONIC
    let rA : REGISTER
    let rB : REGISTER
    let D: String
    let V: String
    let id = UUID()
    var isExecuted: Bool = false
    
    init() {
        self.mnemonic = .undefine
        self.rA = .F
        self.rB = .F
        self.D = ""
        self.V = ""
    }
    
    init(mnemonic: MNEMONIC, rA: REGISTER = REGISTER.F, rB: REGISTER = REGISTER.F, D: String = "", V: String = ""){
        self.mnemonic = mnemonic
        self.rA = rA
        self.rB = rB
        self.D = D
        self.V = V
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
        let partition = string.components(separatedBy: "\n").filter {
            $0.count > 0
        }
        let instruction_list = partition.map {instr in
            {
                try Instruction.parseString(instr)
            }
        }
        do {
            let result = try instruction_list.map {try $0()}
            return result
        } catch {
            print("Contain invalid instruction!")
            return []
        }
    }
    
    static func getTextFromList(_ instruction_list: [Instruction]) -> String {
        var output_string = ""
        for instruction in instruction_list {
            output_string += instruction.getText() + "\n"
        }
        return output_string
    }
    
    func getText() -> String {
        switch(self.mnemonic){
        case .halt:
            return "halt"
        case .nop:
            return "nop"
        case .irmovq:
            return "irmovq \t \(self.V), \(self.rB.rawValue)"
        case .rmmovq:
            if self.rB != .F {
                return "rmmovq \t \(self.rA.rawValue), \(self.D)(\(self.rB.rawValue))"
            }
            return "rmmovq \t \(self.rA.rawValue), \(self.D)"
        case .mrmovq:
            if self.rB != .F {
                return "mrmovq \t \(self.rA.rawValue), \(self.D)(\(self.rB.rawValue))"
            }
            return "mrmovq \t \(self.D), \(self.rA.rawValue)"
        case .addq:
            return "addq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .subq:
            return "subq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .andq:
            return "andq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .xorq:
            return "xorq \t \(self.rA.rawValue), \(self.rB.rawValue)"
        case .undefine:
            return ""
        case .jmp:
            return "jmp \t \(self.D)"
        case .jle:
            return "jmp \t \(self.D)"
        case .jl:
            return "jmp \t \(self.D)"
        case .je:
            return "jmp \t \(self.D)"
        case .jne:
            return "jmp \t \(self.D)"
        case .jge:
            return "jmp \t \(self.D)"
        case .jg:
            return "jmp \t \(self.D)"
        }
    }
}
