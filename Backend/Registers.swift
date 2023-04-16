//
//  Registers.swift
//  WWDC2023_Draft1
//
//  Created by Minh Pham on 13/04/2023.
//

import Foundation

enum REGISTER : String, CaseIterable {
    case rcx = "%rcx"
    case rdx = "%rdx"
    case rbx = "%rbx"
    case rsp = "%rsp"
    case rbp = "%rbp"
    case rsi = "%rsi"
    case rdi = "%rdi"
    case r8 = "%r8"
    case r9 = "%r9"
    case r10 = "%r10"
    case r11 = "%r11"
    case r12 = "%r12"
    case r13 = "%r13"
    case r14 = "%r14"
    case F = ""
}

var name_to_register : [String : REGISTER] = Dictionary(uniqueKeysWithValues: REGISTER.allCases.lazy.map {($0.rawValue, $0)})

class RegisterFile : ObservableObject {
    @Published var files :  [REGISTER: Int] = [:]
    
    init(){
        for register in REGISTER.allCases{
            if register != .F {
            files[register] = 0
            }
        }
    }
    
    static func validateFile(userRegisterFile: RegisterFile, machineRegisterFile: RegisterFile) -> Bool {
        for key in userRegisterFile.files.keys {
            if userRegisterFile.files[key] != machineRegisterFile.files[key] {
                return false
            }
        }
        return true
    }
    
    func getRegisterValue(_ register: REGISTER) -> Int {
        if let value = self.files[register] {
            return value
        }
        else{
            print("Invalid register name")
            return 0
        }
    }
    
    func getAllRegisters() -> [REGISTER] {
        return files.keys.map{key in key}.sorted(by: {$0.rawValue > $1.rawValue})
    }
    
    func registerBoardOnClick(){
        print(files)
    }
}



