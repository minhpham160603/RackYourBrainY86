//
//  PlaygroundView.swift
//  WWDC2023_Draft1
//
//  Created by Minh Pham on 14/04/2023.
//

import SwiftUI

struct PlaygroundView: View {
    @StateObject var game : Game
    @State var memoryText : String
    @State var leftSideWidth : CGFloat = 0
    
    var body: some View {
            GeometryReader { geometry in
                ZStack{
                    Image("Background").resizable().edgesIgnoringSafeArea(.all)
                    HStack(alignment: .top, spacing: 20){
                        Spacer()
                        UserTableView(game: game).frame(width: {geometry.size.width > geometry.size.height ? 600 : 400}())
                        InstructionBoardView(game: game, memoryText: memoryText)
                        Spacer()
                    }.padding(20)
                }
            }
    }
}


struct PlaygroundView_Previews: PreviewProvider {
    static var previews: some View {
        PlaygroundView(game: game_2, memoryText: memoryStringGame2)
    }
}

func DecToHex(decimalString: String) -> String{
    if let number = Int(decimalString){
        return String(format: "%02X", number)
    } else {
        return "\0"
    }
}
