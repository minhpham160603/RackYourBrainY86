//
//  PlaygroundView.swift
//  WWDC2023_Draft1
//
//  Created by Minh Pham on 14/04/2023.
//

import SwiftUI

struct PlaygroundView: View {
    @StateObject var game = Game(instructionList: instruction_list, memoryItemList: MemoryBoard.parseMemoryInputString(string: string1))
    @State var inputCode = ""
    var body: some View {
        HStack{
            UserTablesView(game: game)
            InstructionBoardView(game: game)
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
