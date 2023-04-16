//
//  PlaygroundView.swift
//  WWDC2023_Draft1
//
//  Created by Minh Pham on 14/04/2023.
//

import SwiftUI

var instruction = try! Instruction.parseString(string_instr)

struct PlaygroundView: View {
    @StateObject var game = Game(instructionList: instruction_list, memoryItemList: MemoryBoard.parseMemoryInputString(string: string1))
    @State var inputCode = ""
    var body: some View {
        HStack{
            TableView(game: game)
            InstructionBoardView(game: game)
        }
    }
}

struct InstructionBoardView : View {
    @StateObject var game : Game
    @State var showAlert = false
    @State var alertMessage = ""
    @State var memoryText = string1
    var body : some View {
        VStack {
            Text("Text editor side").font(.largeTitle)
            List {
                ForEach(game.virtualMachine.instructionBoard.sorted {$0.key < $1.key}, id: \.key) {
                        address, instruction in
                        HStack{
                            if address == game.userCurrentCounter {
                                Image(systemName:   "arrow.right.square.fill")
                            } else {
                                Text("\t")
                            }
                            Text("0x00" + String(format: "%02X", address))
                                Text(instruction.getText())
                        }
                }
            }
            Text(memoryText)
                .frame(width: 300, height: 300)
                .multilineTextAlignment(.leading)
                .lineLimit(nil)
                .border(Color.blue, width: 1)
            
            
            Button("Print register Board") {
                print(game.virtualMachine.registerFile.files)
            }.padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            
            Button("Validate this step") {
                if game.validateStep() {
                    print("Step checked successfully")
                } else {
                    print("Check unsuccessful")
                }
            }
            
            Spacer()
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Instruction Error"), message: Text("Instruction Counter out of bound!"))
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
            Button("Print register Board") {
                print(registerFile.files)
            }.padding()
                .foregroundColor(.white)
                .background(Color.blue)
                .cornerRadius(10)
            
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
                Button("Convert") {
                    hexOutput = DecToHex(decimalString: decimalInput)
                    if hexOutput == "\0" {
                        convertAlert = true
                    }
                }
            }
        }.alert(isPresented: $convertAlert) {
            Alert(title: Text("Convert Failed"), message: Text("Invalid input"))
        }
    }
}

struct MemoryTableView : View {
    @StateObject var game : Game
    @State var showAlert = false
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
                if game.userCurrentCounter == -1 {
                    if game.firstStep() {
                        print("First step successful")
                    } else {
                        print("First step unccessful, try again.")
                    }
                } else {
                    if game.validateMemoryBoard() {
                        print("Valid memory board")
                    } else {
                        print("Invalid memory board")
                    }
                }
            }
            .padding()
            .foregroundColor(.white)
            .background(Color.blue)
            .cornerRadius(10)
            Spacer()
        }.alert(isPresented: $showAlert) {
            Alert(title: Text("Memory add failed"), message: Text("Invalid memory item"))
    }
}
}

struct TableView : View {
    @StateObject var game : Game
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Register").font(.largeTitle).padding()
            RegisterBoardView(registerFile: game.userRegisterFile)
            HStack{
                Text("PC")
                Text("Condition Code")
            }
            MemoryTableView(game: game)
            Button("Print table") {
                game.userMemoryBoard.memoryButtonOnlick()
            }
        }
    }
}


struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView()
    }
}

func DecToHex(decimalString: String) -> String{
    if let number = Int(decimalString){
        return String(format: "%02X", number)
    } else {
        return "\0"
    }
}
