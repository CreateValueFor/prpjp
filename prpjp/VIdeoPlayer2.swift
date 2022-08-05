//
//  VIdeoPlayer2.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/05.
//

import SwiftUI
import UIKit
import AVKit


struct ContentsadfView: View {
    let player = AVPlayer(url: URL(fileURLWithPath: Bundle.main.path(forResource: "IMG_0226", ofType: "mp4")!))
    var body: some View {
        AVPlayerControllerRepresented(player: player)
            .onAppear {
                player.play()
                
            }
            .frame(width: 400, height: 400)
    }
}

struct AVPlayerControllerRepresented : NSViewRepresentable {
    var player : AVPlayer
    
    func makeNSView(context: Context) -> AVPlayerView {
        let view = AVPlayerView()
        view.controlsStyle = .none
        view.player = player
        return view
    }
    
    func updateNSView(_ nsView: AVPlayerView, context: Context) {
        
    }
}
