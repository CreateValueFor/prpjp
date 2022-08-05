//
//  VideoPlayer3.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/06.
//

import SwiftUI
import AVKit
import UIKit

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
struct VideoPlayer3_Previews: PreviewProvider {
    static var previews: some View {
        VideoPlayer3()
    }
}
