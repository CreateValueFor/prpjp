//
//  VideoView.swift
//  prpjp
//
//  Created by mykim on 2022/08/17.
//

import SwiftUI
import Foundation
import AVKit
import AVFoundation

struct VideoView: View {
    
    // MARK: - STATE
    
    @State var player = AVPlayer()
    @State var isplaying = true
    @State var showcontrols = true
    
    // MARK: - PROPERTIES
    
    var allowsPictureInPicturePlayback : Bool = true
    var url: URL
    var show : Bool
    
    // MARK: - BODY
    
    var body: some View {
        VideoPlayer(url: url, player: player, keepLoop: show)
            .edgesIgnoringSafeArea(.all)
            .onAppear {
                if show {
                    player.replaceCurrentItem(with: AVPlayerItem(url: url))
                    player.play()
                }
                
            }
    }
}

// MARK: - VIDEO CONTROLLER

struct VideoPlayer : UIViewControllerRepresentable {
    
    var playerObserver: Any?
    var url: URL
    var player : AVPlayer
    var keepLoop : Bool
    
    init(url: URL, player: AVPlayer, keepLoop : Bool) {
        self.url = url
        self.player = player
        self.keepLoop = keepLoop
        if !self.keepLoop {
            return
        }
        self.playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                                     object: nil,
                                                                     queue: nil) { [self] _ in
            self.player.seek(to: CMTime.zero)
            self.player.play()
        }
    }
    
    func makeUIViewController(context: Context) ->  UIViewController {

        let controller = AVPlayerViewController()
        controller.player = player
        controller.showsPlaybackControls = true
        controller.exitsFullScreenWhenPlaybackEnds = true
        controller.allowsPictureInPicturePlayback = true
        
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewController, context: Context) {
        
        
    }
}
