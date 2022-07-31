//
//  PressButton.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/06.
//

import SwiftUI

struct PressButton: View {
    
    
    let id: String
    let callback: (Bool)->()
    let size: CGFloat
    let color: Color
    let textSize: CGFloat
    let isPressed: Bool
    let disabled : Bool

    init(
        _ id: String,
        callback: @escaping (Bool)->(),
        size: CGFloat = 12,
        color: Color = .white,
        textSize: CGFloat = 12,
        isPressed: Bool,
        disabled: Bool
        
        ) {
        self.id = id
        self.size = size
        self.color = color
        self.textSize = textSize
        self.callback = callback
        self.isPressed = isPressed
            self.disabled = disabled
    }
    
    var body: some View {
        ZStack{
            Button(action: {
                self.callback(false)
            }, label: {Text(id)})
                .frame(width: 150, height: 80)
                .background(.gray)
                .foregroundColor(.white)
//                .simultaneousGesture(
//                    LongPressGesture(minimumDuration: 0).onEnded({ _ in
//                        self.callback(true)
//                    })
//                )
            
                .disabled(disabled)
        }
    }
}

struct PressButton_Previews: PreviewProvider {
    static var previews: some View {
        PressButton("SPEAK", callback: { bool in
            print(bool)
        }, isPressed: true, disabled: true)
    }
}
