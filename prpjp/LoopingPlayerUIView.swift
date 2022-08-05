//
//  LoopingPlayerUIView.swift
//  prpjp
//
//  Created by 이민기 on 2022/08/05.
//

import Foundation
import AVKit
import SwiftUI


class LoopingPlayerUIView: UIView {
    
//    @Binding var videoURL: URL
    
    private let playerLayer = AVPlayerLayer()
    private var playerLooper: AVPlayerLooper?
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        // Load the resource -> h
        
        let asset = AVAsset(url: URL(fileReferenceLiteralResourceName: "place"))
        let item = AVPlayerItem(asset: asset)
        // Setup the player
        let player = AVQueuePlayer()
        playerLayer.player = player
        playerLayer.videoGravity = .resizeAspectFill
        layer.addSublayer(playerLayer)
        // Create a new player looper with the queue player and template item
        playerLooper = AVPlayerLooper(player: player, templateItem: item)
        // Start the movie
        player.play()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        playerLayer.frame = bounds
    }
}
