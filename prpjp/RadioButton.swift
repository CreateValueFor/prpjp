//
//  RadioButton.swift
//  prpjp
//
//  Created by 이민기 on 2022/05/31.
//

import SwiftUI

struct ColorInvert: ViewModifier {

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

struct RadioButton: View {

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
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.selectedID == self.id ? "largecircle.fill.circle" : "circle")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.size, height: self.size)
                    .modifier(ColorInvert())
                Text(id)
                    .font(Font.system(size: textSize))
                
            }.foregroundColor(self.color)
        }
        .foregroundColor(self.color)
    }
}

struct RadioButtonGroup: View {

    let items : [String]

    @State var selectedId: String = ""

    let callback: (String) -> ()

    var body: some View {
        ScrollView(.horizontal){
            HStack {
                ForEach(0..<items.count) { index in
                    RadioButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
                }
            }
            
            
        }
        
    }

    func radioGroupCallback(id: String) {
        selectedId = id
        callback(id)
    }
}

struct RadioGroup: View {
    var body: some View {
        HStack {
            
            RadioButtonGroup(items: ["192 X 32", "192 X 64", "192 X 128", "384 X 64", "384 X 128"], selectedId: "London") { selected in
                print("Selected is: \(selected)")
            }
        }
    }
}

struct RadioGroup_Previews: PreviewProvider {
    static var previews: some View {
        Color(.darkGray)
            .overlay(
                RadioGroup()
            )
        
        
    }
}

struct ContentViewDark_Previews: PreviewProvider {
    static var previews: some View {
        RadioGroup()
        .environment(\.colorScheme, .dark)
        
        
    }
}
