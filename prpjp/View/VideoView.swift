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


// MARK: - VIDEO CONTROLLER

struct VideoPlayer : UIViewControllerRepresentable {

    var playerObserver: Any?
    var player: AVPlayer?
    var url: URL
    var show : Bool

    init(url: URL, player: AVPlayer, show : Bool) {
        self.url = url
        self.player = player
        self.show = show
        if !self.show {
            return
        }
        
        player.replaceCurrentItem(with: AVPlayerItem(url: url))
        player.play()
        
        self.playerObserver = NotificationCenter.default.addObserver(forName: NSNotification.Name.AVPlayerItemDidPlayToEndTime,
                                                                     object: nil,
                                                                     queue: nil) { _ in
            player.seek(to: CMTime.zero)
            player.play()
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

class PlayerManager : ObservableObject {
    let player = AVPlayer()
    @Published private var playing = false

    func play() {
        player.play()
        playing = true
    }
    
    func pause() {
        player.pause()
        playing = false
    }
    
    func playPause() {
        if playing {
            player.pause()
        } else {
            player.play()
        }
        playing.toggle()
    }
}
