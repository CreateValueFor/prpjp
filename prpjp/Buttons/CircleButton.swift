//
//  CircleButton.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/03.
//
import SwiftUI


struct CircleButton: View {

    

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
            VStack(spacing: 30){
                Circle()
                    .strokeBorder(self.selectedID == self.id ?  Color(hex: "#008577") : Color.white,lineWidth: 1)
                    .background(Circle().foregroundColor(color))
                    .frame(width: 30, height: 30)
                    
                    
                
                    
            }
            
        }
        .foregroundColor(self.color)
    }
}

struct CircleButtonGroup: View {

    let items : [PRP_COLOR]
    
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
                        CircleButton(self.items[index].rawValue, callback: self.radioGroupCallback, selectedID: self.selectedId, color: items[index].color)
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

struct LanguageTestGroup: View {
    
    let colors : [PRP_COLOR] = PRP_COLOR.allCases.map{
        $0
    }
    let color : String = PRP_COLOR.BLACK.rawValue
    
    var body: some View {
        HStack {
            CircleButtonGroup(items: colors, title: "Text color", selectedId: color) { color in
                print(color)
            }
        }.padding()
    }
}

struct LanguageTestGroup_Previews: PreviewProvider {
    static var previews: some View {
        Color(.darkGray)
            .overlay(
                LanguageTestGroup()
            )
        
        
    }
}
