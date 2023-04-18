import SwiftUI

struct ContentView: View {
    
    @State var gotoGame = 0
    
    var body: some View {
        return Group {
            if gotoGame == 0 {
                ZStack{
                    Image("Background").resizable().edgesIgnoringSafeArea(.all)
                    VStack(spacing: 30){
                        Text("Welcome to the Y86Rackyourbrain Paradise").font(.largeTitle).bold()
                        Text("Now close your eyes and imagine you are a computer, and your brain is the CPU.")
                        HStack(spacing: 20) {
                            VStack {
                                Button(action: {
                                    gotoGame = 1
                                }, label: {
                                    Image("Dog").resizable().frame(width: 200, height: 200).clipShape(RoundedRectangle(cornerRadius: 12))
                                })
                                NormalText("Game 1: The Basic")
                            }
                            VStack {
                                Button(action: {
                                    gotoGame = 2
                                }, label: {
                                    Image("Mac").resizable().frame(width: 200, height: 200).clipShape(RoundedRectangle(cornerRadius: 12))
                                })
                                NormalText("Game 2: Un peu interessant")
                            }
                            VStack {
                                Button(action: {
                                    gotoGame = 3
                                }, label: {
                                    Image("Bomb").resizable().frame(width: 200, height: 200).clipShape(RoundedRectangle(cornerRadius: 12))
                                })
                                NormalText("Game 3: Boomb!")
                            }
                        }
                    }
                }
            } else if gotoGame == 1 {
                PlaygroundView(game: game_1, memoryText: memoryStringGame1)
                HStack{
                    Spacer()
                    Button(action: {
                        gotoGame = 0
                    }, label: {Text("Go Home").foregroundColor(.blue)})
                    Spacer()
                    ManualSheetPopUp()
                    Spacer()
                }
                
            } else if gotoGame == 2 {
                PlaygroundView(game: game_2, memoryText: memoryStringGame2)
                HStack{
                    Spacer()
                    Button(action: {
                        gotoGame = 0
                    }, label: {Text("Go Home").foregroundColor(.blue)})
                    Spacer()
                    ManualSheetPopUp()
                    Spacer()
                }
            } else if gotoGame == 3 {
                PlaygroundView(game: game_3, memoryText: memoryStringGame3)
                HStack{
                    Spacer()
                    Button(action: {
                        gotoGame = 0
                    }, label: {Text("Go Home").foregroundColor(.blue)})
                    Spacer()
                    ManualSheetPopUp()
                    Spacer()
                }
            }
        }
    }
}

struct Contentview_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
