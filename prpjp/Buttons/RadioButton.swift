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

    let item: DISPLAY_RESOLUTION
    let callback: (DISPLAY_RESOLUTION)->()
    var selectedID : DISPLAY_RESOLUTION
    let size: CGFloat
    let color: Color
    let textSize: CGFloat
    

    init(
        _ item: DISPLAY_RESOLUTION,
        callback: @escaping (DISPLAY_RESOLUTION)->(),
        selectedID: DISPLAY_RESOLUTION,
        size: CGFloat = 12,
        color: Color = .white,
        textSize: CGFloat = 12
        ) {
        self.item = item
        self.size = size
        self.color = color
        self.textSize = textSize
        self.selectedID = selectedID
        self.callback = callback
    }

    var body: some View {
        Button(action:{
            self.callback(self.item)
        }) {
            HStack(alignment: .center, spacing: 10) {
                Image(systemName: self.selectedID.text == self.item.text ? "largecircle.fill.circle" : "circle")
                    .renderingMode(.original)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: self.size, height: self.size)
                    .foregroundColor(self.selectedID == self.item ? Color(hex: "#008577") : .white)
                Text(item.text.replacingOccurrences(of: "D", with: "").replacingOccurrences(of: "X", with: " X "))
                    .font(Font.system(size: textSize))
                
            }.foregroundColor(self.color)
        }
        .foregroundColor(self.color)
    }
}

struct RadioButtonGroup: View {

    let items : [DISPLAY_RESOLUTION]

    @Binding var selectedId: DISPLAY_RESOLUTION {
        didSet {
            print("selectedId = \(selectedId)")
        }
    }

    let callback: (DISPLAY_RESOLUTION) -> ()

    var body: some View {
        ScrollView(.horizontal){
            HStack {
                ForEach(0..<items.count, id: \.self) { index in
                    RadioButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId)
                }
            }
        }
    }

    func radioGroupCallback(id: DISPLAY_RESOLUTION) {
        selectedId = id
        callback(id)
    }
}

struct RadioGroup: View {
    
    @State private var selectedId: DISPLAY_RESOLUTION = DISPLAY_RESOLUTION.XS
    
    var body: some View {
        HStack {
            
            RadioButtonGroup(items: [DISPLAY_RESOLUTION.XS, DISPLAY_RESOLUTION.LG, DISPLAY_RESOLUTION.MD, DISPLAY_RESOLUTION.SM, DISPLAY_RESOLUTION.XL], selectedId: $selectedId) { selected in
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
