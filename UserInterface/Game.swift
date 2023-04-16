//
//  Game.swift
//  
//
//  Created by Minh Pham on 16/04/2023.
//

import Foundation

class Game : ObservableObject {
    @Published var virtualMachine : VirtualMachine
    @Published var userRegisterFile : RegisterFile
    @Published var userMemoryBoard : MemoryBoard
    @Published var userCurrentCounter : Int
    
    init(instructionList: [Instruction], memoryItemList : [Item]) {
        virtualMachine = VirtualMachine(instructionList: instructionList, memoryItemList: memoryItemList)
        userRegisterFile = RegisterFile()
        userMemoryBoard = MemoryBoard()
        userCurrentCounter = -1
    }
    
    func firstStep() -> Bool {
        if validateMemoryBoard() {
            do {
                try virtualMachine.executeCurrentInstruction()
                userCurrentCounter = 0
                return true
            } catch {
                print("First step error")
                return false
            }
        } else {
            return false
        }
    }
    
    func validateMemoryBoard() -> Bool {
        return MemoryBoard.validateBoard(userBoard: userMemoryBoard, machineBoard: virtualMachine.memoryBoard)
    }
    
    func validateRegisterBoard() -> Bool {
        return RegisterFile.validateFile(userRegisterFile: userRegisterFile, machineRegisterFile: virtualMachine.registerFile)
    }
    
    func validateStep() -> Bool {
        var newCounter = userCurrentCounter
        if validateMemoryBoard() && validateRegisterBoard() {
            do {
                newCounter = virtualMachine.programCounter
                try virtualMachine.executeCurrentInstruction()
                userCurrentCounter = newCounter
                return true
            } catch let error {
                print(error.localizedDescription)
                return false
            }
        } else {
            return false
        }
    }
}
