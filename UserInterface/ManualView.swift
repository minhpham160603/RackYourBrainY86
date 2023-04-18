//
//  ManualView.swift
//  
//
//  Created by Minh Pham on 18/04/2023.
//

import SwiftUI


struct ManualView: View {
    @State var pageIndex : Int = 1
    var body: some View {
        VStack {
            Text("User manual").font(.title).foregroundColor(highlightTextColor)
            HStack {
                Button(action: {if pageIndex > 1 {pageIndex -= 1}}, label: {
                    Image(systemName: "arrow.left.square.fill").foregroundColor(.blue)
                })
                Image("Guide\(pageIndex)").resizable().aspectRatio(contentMode: .fit).cornerRadius(10)
                Button(action: {if pageIndex < 8 {pageIndex += 1}}, label: {
                    Image(systemName: "arrow.right.square.fill")
                }).foregroundColor(.blue)
            }.padding(10)
            
        }
    }
}

struct ManualSheetPopUp : View {
    @State var showSheet = false
    var body : some View {
        Button(action: {showSheet = true}, label: {
            Text("Need some help?").foregroundColor(highlightTextColor)
        }).sheet(isPresented: $showSheet, content: {VStack{ManualView()
            Button("Dismiss") {showSheet.toggle()}
        }})
    }
}

struct ManualViewPreview: PreviewProvider {
    static var previews: some View {
        ManualView()
    }
}
