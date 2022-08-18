//
//  CircleButton.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/03.
//
import SwiftUI


struct CircleButton: View {

    

    let item: PRP_COLOR
    let callback: (PRP_COLOR)->()
    @State var selectedID : PRP_COLOR
    let size: CGFloat
    let textSize: CGFloat

    init(
        _ item: PRP_COLOR,
        callback: @escaping (PRP_COLOR)->(),
        selectedID: PRP_COLOR,
        size: CGFloat = 12,
//        color: Color = .white,
        textSize: CGFloat = 12
        ) {
        self.item = item
        self.size = size
//        self.color = color
        self.textSize = textSize
        self.selectedID = selectedID
        self.callback = callback
    }

    var body: some View {
        Button(action:{
            self.callback(self.item)
        }) {
            VStack(spacing: 30){
                Circle()
                    .strokeBorder(self.selectedID == self.item ?  Color(hex: "#008577") : Color.white,lineWidth: 1)
                    .background(Circle().foregroundColor(item.color))
                    .frame(width: 30, height: 30)
            }
            
        }
        .foregroundColor(item.color)
    }
}

struct CircleButtonGroup: View {

    let items : [PRP_COLOR]
    
    let title : String

    @State var selectedId: PRP_COLOR = PRP_COLOR.BLACK

    let callback: (PRP_COLOR) -> ()

    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(title)
                    .foregroundColor(.white)
                HStack {
                    ForEach(0..<items.count) { index in
                        CircleButton(self.items[index], callback: self.radioGroupCallback, selectedID: self.selectedId )
                    }
                }
            }
        }
    }
    func radioGroupCallback(id: PRP_COLOR) {
        selectedId = id
        callback(id)
    }
}

//struct LanguageTestGroup: View {
//    
//    let colors : [PRP_COLOR] = PRP_COLOR.allCases.map{
//        $0
//    }
//    let color : String = PRP_COLOR.BLACK.rawValue
//    
//    var body: some View {
//        HStack {
//            CircleButtonGroup(items: colors, title: "Text color", selectedId: color) { color in
//                print(color)
//            }
//        }.padding()
//    }
//}

//struct LanguageTestGroup_Previews: PreviewProvider {
//    static var previews: some View {
//        Color(.darkGray)
//            .overlay(
//                LanguageTestGroup()
//            )
//
//
//    }
//}
