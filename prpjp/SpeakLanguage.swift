//
//  SpeakLanguage.swift
//  prpjp
//
//  Created by 이민기 on 2022/05/31.
//
import SwiftUI

struct ColorInvertLanguage: ViewModifier {

    @Environment(\.colorScheme) var colorScheme

    func body(content: Content) -> some View {
        Group {
            if colorScheme == .dark {
                content.colorInvert()
            } else {
                content
            }
        }
    }
}

struct LanguageButton: View {

    @Environment(\.colorScheme) var colorScheme

    let id: String
    let callback: (String)->()
    let selectedID : String
    let size: CGFloat
    let color: Color
    let textSize: CGFloat

    init(
        _ id: String,
        callback: @escaping (String)->(),
        selectedID: String,
        size: CGFloat = 12,
        color: Color = .white,
        textSize: CGFloat = 12
        ) {
        self.id = id
        self.size = size
        self.color = color
        self.textSize = textSize
        self.selectedID = selectedID
        self.callback = callback
    }

    var body: some View {
        Button(action:{
            self.callback(self.id)
        }) {
            VStack( spacing: 0){
                ZStack{
                    Rectangle()
                        .frame(width: 60, height: 30)
                        .foregroundColor(.gray)
                    Text(id)
                        .font(Font.system(size: 12))
                        .foregroundColor(.white)
                }
                Rectangle()
                    .frame(width:60, height: 2)
                    .foregroundColor(self.selectedID == self.id ? .black : .white)
                    .modifier(ColorInvertLanguage())
            }
            
        }
        .foregroundColor(self.color)
    }
}

struct LanguageButtonGroup: View {

    let items : [String]

    @State var selectedId: String = ""

    let callback: (String) -> ()

    var body: some View {
        ScrollView(.horizontal){
            VStack(alignment: .leading){
                Text("Speak langauge")
                    .foregroundColor(.white)
                HStack {
                    ForEach(0..<items.count) { index in
                        LanguageButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
                    }
                }
            }
        }
    }
    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}

struct LanguageGroup: View {
    var body: some View {
        HStack {
            
            LanguageButtonGroup(items: ["ENGLISH", "FRENCH", "SPANISH", "日本語", "한국어"], selectedId: "London") { selected in
                print("Selected is: \(selected)")
            }
        }.padding()
    }
}

struct LanguageGroup_Previews: PreviewProvider {
    static var previews: some View {
        Color(.darkGray)
            .overlay(
                LanguageGroup()
            )
        
        
    }
}
