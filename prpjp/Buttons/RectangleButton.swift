//
//  SpeakLanguage.swift
//  prpjp
//
//  Created by 이민기 on 2022/05/31.
//
import SwiftUI


struct RectangleButton: View {

    

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
                    .foregroundColor(self.selectedID == self.id ? Color(hex: "#008577") : .white)
                    
            }
            
        }
        .foregroundColor(self.color)
    }
}

struct RectangleButtonGroup: View {

    let items : [String]
    
    let title : String

    @State var selectedId: String = ""

    let callback: (String) -> ()

    var body: some View {
        ScrollView(.horizontal){
            VStack(alignment: .leading){
                Text(title)
                    .foregroundColor(.white)
                HStack {
                    ForEach(0..<items.count) { index in
                        RectangleButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
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
            
            RectangleButtonGroup(items: ["ENGLISH", "FRENCH", "SPANISH", "日本語", "한국어"], title:"Speak Language", selectedId: "London") { selected in
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
