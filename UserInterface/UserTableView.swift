//
//  UserTablesView.swift
//  
//
//  Created by Minh Pham on 17/04/2023.
//

import Foundation
import SwiftUI



struct UserTableView : View {
    @StateObject var game : Game
    var body: some View {
        ZStack{
            RoundedRectangle(cornerRadius: 10)
                .fill(Color(red: 240/255, green: 243/255, blue: 255/255).opacity(0.77))
                    
            VStack(spacing: 20) {
                SheetPopUpButton(label: "Register File", manual: registerManual)
                RegisterBoardView(registerFile: game.userRegisterFile)
                MidTableView(game: game)
                MemoryTableView(game: game)
            }.padding(20)
        }
        
    }
}

struct SheetPopUpButton : View {
    @State var label : String
    @State var manual : String
    @State var showSheet = false
    @State var font : Font = .custom("SF Pro", size: 18).bold()
    var body : some View {
        Button(action: {showSheet = true}, label: {
            Text(label).font(font).padding().foregroundColor(highlightTextColor)
        }).sheet(isPresented: $showSheet, content: {
            VStack(spacing: 20) {
                Text(label).font(.title)
                Text(manual)
            }.padding(20)
        })
    }
}

struct MidTableView : View {
    @StateObject var game: Game
    var body : some View {
        HStack(alignment: .top){
            VStack {
                SheetPopUpButton(label: "Program Counter", manual: CCManual)
                NormalText("0x" + String(format: "%02X", game.userCurrentCounter)).padding(10).multilineTextAlignment(.center).background(.white).cornerRadius(12)           }
            VStack{
                SheetPopUpButton(label: "Condition Code", manual: "How to set this")
                HStack {
                    VStack{
                        NormalText("OF")
                        TextField("Value", text: Binding(get: {String(game.userConditionCode["OF"]!)}, set: {game.userConditionCode["OF"] = Int($0) ?? 0} )).whiteBackground().multilineTextAlignment(.center)
                    }.frame(width: 60, height: 80)
                    VStack{
                        NormalText("ZF")
                        TextField("Value", text: Binding(get: {String(game.userConditionCode["ZF"]!)}, set: {game.userConditionCode["ZF"] = Int($0) ?? 0} )).whiteBackground().multilineTextAlignment(.center)
                    }.frame(width: 60, height: 80)
                    VStack{
                        NormalText("SF")
                        TextField("Value", text: Binding(get: {String(game.userConditionCode["SF"]!)}, set: {game.userConditionCode["SF"] = Int($0) ?? 0} )).whiteBackground().multilineTextAlignment(.center)
                    }.frame(width: 60, height: 80)
                }
                }
            }
    }
}

struct RegisterItemsView : View {
    @StateObject var registerFile : RegisterFile
    @State var registerInput : [REGISTER : String]
    @State var isPrefix : Bool
    
    func getArraySlice() -> ArraySlice<REGISTER> {
        if isPrefix {
            return registerFile.getAllRegisters().prefix(5)
        } else {
            return registerFile.getAllRegisters().suffix(5)
        }
    }
    
    var body : some View {
        HStack{
            ForEach(self.getArraySlice(), id:\.rawValue) { register in
                VStack {
                    Text(register.rawValue).foregroundColor(highlightTextColor)
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
                    })).whiteBackground().frame(maxWidth: .infinity).multilineTextAlignment( .center)
                }.frame(minWidth: 50)
            }
        }
    }
}
                                                       

struct RegisterBoardView : View {
    var registerFile : RegisterFile
    @State var registerInput : [REGISTER:String] = Dictionary(uniqueKeysWithValues: REGISTER.allCases.lazy.map {($0, "0")})
    var body: some View {
        VStack{
            RegisterItemsView(registerFile: registerFile, registerInput: registerInput, isPrefix: true)
            RegisterItemsView(registerFile: registerFile, registerInput: registerInput, isPrefix: false)
        }
    }
}


struct MemoryTableView : View {
    @StateObject var game : Game
    @State var showAlert = false
    @State var alertMessage = ""
    @State var checkSuccessed = false
    @State var addressToStringValue = MemoryBoard.defaultMemoryString()
    
    var body: some View{
        SheetPopUpButton(label: "Memory Board", manual: memoryManual)
        VStack{
            List(game.userMemoryBoard.getSortedItemsByAddress(), id: \.id) { item in
                HStack{
                    Text("0x" + String(format:"%02X", item.address))
                    TextField("Label", text: Binding(get: {item.label }, set: { item.label = $0
                    }))
                    TextField("Value", text: Binding(get: {
                        addressToStringValue[item.address]!
                    }, set: { newValue in
                        if let intValue = Int(newValue) {
                            item.value = intValue
                        } else if newValue.contains("0x") && newValue.count > 2 {
                            item.value = Int(newValue.dropFirst(2), radix: 16) ?? 0
                        }
                        else {}
                        addressToStringValue[item.address] = newValue
                    })).autocorrectionDisabled(true).textInputAutocapitalization(.none)
                }
            }.listStyle(PlainListStyle()).listRowBackground(Color.white.opacity(0)).cornerRadius(12)
            
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
