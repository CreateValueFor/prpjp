//
//  PlayerView.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/05.
//

import SwiftUI

struct PlayerView: UIViewRepresentable {
    
    @Binding var videoURL : URL?
    
    func updateUIView(_ uiView: UIView, context: UIViewRepresentableContext<PlayerView>) {
    }

    func makeUIView(context: Context) -> UIView {
        return LoopingPlayerUIView(frame: .zero)
    }
}
