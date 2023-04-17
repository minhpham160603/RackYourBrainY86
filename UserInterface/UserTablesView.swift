//
//  UserTablesView.swift
//  
//
//  Created by Minh Pham on 17/04/2023.
//

import Foundation
import SwiftUI

struct UserTablesView : View {
    @StateObject var game : Game
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Register").font(.largeTitle).padding()
            RegisterBoardView(registerFile: game.userRegisterFile)
            HStack{
                VStack {
                    Text("PC")
                    Text(String(format: "%02X", game.userCurrentCounter)).multilineTextAlignment(.center)
                }.border(.blue, width: 1)
                }
                VStack{
                    Text("Condition Code")
                    HStack {
                        VStack{
                            Text("OF")
                            TextField("Value", text: Binding(get: {String(game.userConditionCode["OF"]!)}, set: {game.userConditionCode["OF"] = Int($0) ?? 0} )).multilineTextAlignment(.center)
                        }.border(.blue, width: 1)
                        VStack{
                            Text("ZF")
                            TextField("Value", text: Binding(get: {String(game.userConditionCode["ZF"]!)}, set: {game.userConditionCode["ZF"] = Int($0) ?? 0} )).multilineTextAlignment(.center)
                        }.border(.blue, width: 1)
                        VStack{
                            Text("SF")
                            TextField("Value", text: Binding(get: {String(game.userConditionCode["SF"]!)}, set: {game.userConditionCode["SF"] = Int($0) ?? 0} )).multilineTextAlignment(.center)
                        }.border(.blue, width: 1)
                    }
                }
            MemoryTableView(game: game)
        }
    }
}

struct RegisterItemsView : View {
    @StateObject var registerFile : RegisterFile
    @State var registerInput : [REGISTER : String]
    @State var isPrefix : Bool
    
    func getArraySlice() -> ArraySlice<REGISTER> {
        if isPrefix {
            return registerFile.getAllRegisters().prefix(7)
        } else {
            return registerFile.getAllRegisters().suffix(7)
        }
    }
    
    var body : some View {
        HStack{
            ForEach(self.getArraySlice(), id:\.rawValue) { register in
                VStack {
                    Text(register.rawValue).foregroundColor(Color.blue)
                    TextField("Register Value", text: Binding( get: {
                        registerInput[register]!
                    }, set: { newValue in
                        if let parsedValue = Int(newValue) {
                            registerFile.files[register]! = parsedValue
                            registerInput[register]! = newValue
                        } else if newValue.contains("0x") && newValue.count > 2 {
                            let parsedValue = Int(newValue.dropFirst(2), radix: 16)
                            registerFile.files[register]! =  parsedValue ?? 0
                        }
                        else {}
                        registerInput[register]! = newValue
                    })).frame(maxWidth: .infinity).multilineTextAlignment( .center)
                }.frame(minWidth: 50)
            }
        }
    }
}
                                                       

struct RegisterBoardView : View {
    var registerFile : RegisterFile
    @State var decimalInput : String = ""
    @State var hexOutput : String = ""
    @State var convertAlert : Bool = false
    @State var registerInput : [REGISTER:String] = Dictionary(uniqueKeysWithValues: REGISTER.allCases.lazy.map {($0, "0")})
    var body: some View {
        VStack{
            RegisterItemsView(registerFile: registerFile, registerInput: registerInput, isPrefix: true)
            RegisterItemsView(registerFile: registerFile, registerInput: registerInput, isPrefix: false)
            
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
                    }))
                }
                HStack{
                    Text("Hexadecimal Number")
                    if hexOutput == "" || hexOutput == "\0"{
                        Text("")
                    } else {
                        Text("0x" + hexOutput)
                    }
                }
            }
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
            Alert(title: Text("Convert Failed"), message: Text("Invalid input"))
        }
    }
}


struct MemoryTableView : View {
    @StateObject var game : Game
    @State var showAlert = false
    @State var alertMessage = ""
    @State var checkSuccessed = false
    
    var body: some View{
        VStack{
            List(game.userMemoryBoard.getSortedItemsByAddress(), id: \.id) { item in
                HStack{
                    Text("0x" + String(format:"%02X", item.address))
                    TextField("Label", text: Binding(get: {item.label }, set: { item.label = $0
                    }))
                    TextField("Value", text: Binding(get: {
                        if item.value != -1 {
                            return String( item.value)
                        }
                        return ""
                    }, set: { newValue in
                        if let intValue = Int(newValue) {
                            item.value = intValue
                        } else {
                            item.value = -1
                        } })).autocorrectionDisabled(true).textInputAutocapitalization(.none)
                }
            }.border(Color.blue, width: 1)
            
            Button("Validate Memory") {
                showAlert = true
                if game.userCurrentCounter == -1 {
                    if game.firstStep() {
                        alertMessage = "First step successful. You are good to go!"
                        checkSuccessed = true
                    } else {
                        alertMessage = "First step unccessful, try again."
                        checkSuccessed = false
                    }
                } else {
                    if game.validateMemoryBoard() {
                        checkSuccessed = true
                        alertMessage = "Nice job. Now try to validate the step."
                    } else {
                        alertMessage = "Don't worry, everyone makes mistake. Just try again."
                        checkSuccessed = false
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            Spacer()
        }.alert(isPresented: $showAlert) {
            if checkSuccessed {
                return Alert(title: Text("Memory check successful! 🥳"), message: Text(alertMessage))
            } else {
                return Alert(title: Text("Memory check failed 😢"), message: Text(alertMessage))
            }
            
    }
}
}
