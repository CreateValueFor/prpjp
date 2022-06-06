//
//  TextField.swift
//  prpjp
//
//  Created by 이민기 on 2022/06/06.
//

import SwiftUI

struct TextField: View {
    
    
    let callback: (Bool)->()
    let size: CGFloat
    let color: Color
    let textSize: CGFloat
    let isPressed: Bool

    init(
        _ id: String,
        callback: @escaping (Bool)->(),
        size: CGFloat = 12,
        color: Color = .white,
        textSize: CGFloat = 12,
        isPressed: Bool
        
        ) {
        self.id = id
        self.size = size
        self.color = color
        self.textSize = textSize
        self.callback = callback
        self.isPressed = isPressed
    }
    
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

struct TextField_Previews: PreviewProvider {
    static var previews: some View {
        TextField()
    }
}
