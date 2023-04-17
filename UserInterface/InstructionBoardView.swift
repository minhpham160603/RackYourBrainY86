//
//  InstructionBoardView.swift
//  
//
//  Created by Minh Pham on 17/04/2023.
//

import Foundation
import SwiftUI


struct InstructionView : View {
    @StateObject var instruction : Instruction
    @State var isCurrentCounter : Bool
    var body : some View {
        VStack(alignment: .leading){
            if !instruction.label.isEmpty {
                Text(instruction.label + ":")
            }
            HStack{
                if isCurrentCounter {
                    Image(systemName:   "arrow.right.square.fill")
                } else {
                    Text("\t")
                }
                Button(action: {
                    instruction.showPopOver = true
//                                print(instruction.showPopOver)
                }, label: {
                    Text(instruction.getText()).multilineTextAlignment(.leading)
                }).popover(isPresented: Binding(get: {instruction.showPopOver
                }, set: {
                    instruction.showPopOver = $0}), content: {
                        Text("Manual Start").frame(width: 300, height: 300)
                    }).foregroundColor(.blue)
            }
        }
    }
}

struct InstructionBoardView : View {
    @StateObject var game : Game
    @State var showAlert = false
    @State var validateSucceed = false
    @State var gameEnd = false
    @State var alertMessage = ""
    @State var memoryText = string1
    @State var showPopOver = false
    var body : some View {
        VStack {
            Text("Text editor side").font(.largeTitle)
            Spacer()
            VStack(alignment: .leading, spacing: 5) {
                ForEach(game.virtualMachine.instructionBoard.sorted {$0.key < $1.key}, id: \.key) {
                    address, instruction in
                    InstructionView(instruction: instruction, isCurrentCounter: address == game.userCurrentCounter)
                }
            }
            Spacer()
            Text(memoryText)
                .multilineTextAlignment(.leading)
                .frame(width: 200, height: 300)
                .lineLimit(nil)
                .border(Color.blue, width: 1)
            
            
            //            Button("Execute game") {
            //                try? game.virtualMachine.executeCurrentInstruction()
            //            }.padding()
            //                .foregroundColor(.white)
            //                .background(Color.blue)
            //                .cornerRadius(10)
            
            Button("Validate this step") {
                showAlert = true
                if game.gameEnd() {
                    gameEnd = true
                    alertMessage = "Hey assembly master! Take the next challenge?"
                    return
                }
                if game.validateStep() {
                    validateSucceed = true
                    alertMessage = "Woohoo! Let's ace the next one!"
                } else {
                    validateSucceed = false
                    alertMessage = "Oops, looks like something's wrong..."
                }
            }.padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            
            Spacer()
        }.alert(isPresented: $showAlert) {
            if gameEnd {
                return Alert(title: Text("You cracked the challenge 😍"), message: Text(alertMessage), dismissButton: .default(Text("Back to home")) {
                    // go back to home page
                })
            }
            else if validateSucceed {
                return Alert(title: Text("Step check succeeded 😍"), message: Text(alertMessage))
            } else {
                return Alert(title: Text("Step check failed 😭"), message: Text(alertMessage))
            }
        }.frame(width: 400)
    }
}

