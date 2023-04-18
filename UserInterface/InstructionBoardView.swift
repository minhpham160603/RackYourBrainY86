//
//  InstructionBoardView.swift
//  
//
//  Created by Minh Pham on 17/04/2023.
//

import Foundation
import SwiftUI

struct InstructionBoardView : View {
    @StateObject var game : Game
    @State var showAlert = false
    @State var validateSucceed = false
    @State var gameEnd = false
    @State var alertMessage = ""
    @State var memoryText : String
    
    var body : some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 240/255, green: 243/255, blue: 255/255).opacity(0.77))
        VStack {
                SheetPopUpButton(label: "Y86 Code", manual: introY86, font: .title3)
                Spacer()
            ZStack {
                ScrollView{
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(game.virtualMachine.instructionBoard.sorted {$0.key < $1.key}, id: \.key) {
                            address, instruction in
                            InstructionView(instruction: instruction, address: address, userCurrentCounter: $game.userCurrentCounter)
                        }
                    }
                }
            }
            Spacer()
            Divider().foregroundColor(.white)
            ScrollView{
                HStack{
                    Spacer()
                    NormalText(memoryText).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                        .multilineTextAlignment(.leading)
                        .lineLimit(nil)
                
                }
            }
            HStack{
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
                    .cornerRadius(12)
                SheetConverter()
            }
            Spacer()
        }.padding(10).alert(isPresented: $showAlert) {
            if gameEnd {
                return Alert(title: Text("You cracked the challenge 😍"), message: Text(alertMessage))
            }
            else if validateSucceed {
                return Alert(title: Text("Step check succeeded 😍"), message: Text(alertMessage))
            } else {
                return Alert(title: Text("Step check failed 😭"), message: Text(alertMessage))
            }
            }
        }
    }
}


struct InstructionView : View {
    @StateObject var instruction : Instruction
    @State var address : Int
    @Binding var userCurrentCounter : Int
    var body : some View {
        
            VStack(alignment: .leading){
                if !instruction.label.isEmpty {
                    NormalText(instruction.label + ":")
                }
                HStack{
                    if address == userCurrentCounter {
                        Image(systemName:   "arrow.right.square.fill")
                    } else {
                        Text("\t")
                    }
                    Button(action: {
                        instruction.showPopOver = true
                    }, label: {
                        Text(instruction.getText()).frame(minWidth: 0, maxWidth: .infinity, alignment: .leading).multilineTextAlignment(.leading).foregroundColor(highlightTextColor)
                    }).popover(isPresented: Binding(get: {instruction.showPopOver
                    }, set: {
                        instruction.showPopOver = $0}), content: {
                            Text(mnemonicDescriptions[instruction.mnemonic]!).frame(width: 300, height: 300).padding(10)
                        })
                }
            }.frame(maxWidth: 500)
    }
}

struct SheetConverter : View {
    @State var showSheet = false
    var body : some View {
        Button(action: {showSheet = true}, label: {
            Text("Converter")
        }).padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10).sheet(isPresented: $showSheet, content: {
            DecToHexConverterView()
        })
    }
}

struct DecToHexConverterView : View {
    @State var hexOutput : String = ""
    @State var decimalInput : String = ""
    @State var convertAlert : Bool = false
    
    var body : some View {
        VStack{
            Text("Decimal to Hex Converter")
            VStack(alignment: .leading) {
                HStack{
                    Text("Decimal Number")
                    TextField("Input", text: Binding(get: {
                        decimalInput
                    }, set: {
                        if decimalInput != $0 {
                            hexOutput = ""
                        }
                        decimalInput = $0
                    })).whiteBackground()
                }
                HStack{
                    Text("Hexadecimal Number")
                    if hexOutput == "" || hexOutput == "\0"{
                        Text("")
                    } else {
                        Text("0x" + hexOutput)
                    }
                }
            }.frame(width: 300)
            Button("Convert") {
                hexOutput = DecToHex(decimalString: decimalInput)
                if hexOutput == "\0" {
                    convertAlert = true
                }
            }.padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
        }.alert(isPresented: $convertAlert) {
            Alert(title: Text("Convert Failed"), message: Text("Invalid input")) }
    }
}
