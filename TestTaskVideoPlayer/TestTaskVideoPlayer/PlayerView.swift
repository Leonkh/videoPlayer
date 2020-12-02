//
//  PlayerView.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 01.12.2020.
//
import AVFoundation
import AVKit
import UIKit

class PlayerView: UIView {
    
    var duration: CMTime?
    var seconds: Float64?
    var currentDuration: CMTime?
    var currentSeconds: Float64?
    var time: Float64?
    
    // блок от Apple
    var player: AVPlayer! {
        get {
            return playerLayer.player
        }
        set {
            playerLayer.player = newValue
        }
    }
    
    var playerLayer: AVPlayerLayer {
        return layer as! AVPlayerLayer
    }
    
    // Override UIView property
    override static var layerClass: AnyClass {
        return AVPlayerLayer.self
    }
    // конец блока от Apple
    
    func createController(videoURL: URL) {
        player = AVPlayer(url: videoURL)
        setupTimings()
    }
    
    func play() {
        player?.play()
    }
    
    func pause() {
        player?.pause()
    }
    
    func stop() {
        player?.seek(to: CMTime(value: 0, timescale: 1))
        pause()
    }
    
    func forwardByDoubleTouch() {
        player?.seek(to: (player?.currentTime())! + CMTime(seconds: 10, preferredTimescale: 1))
    }
    
    func forwardByTripleTouch() {
        player?.seek(to: (player?.currentTime())! + CMTime(seconds: 20, preferredTimescale: 1))
    }
    
    func backwardByDoubleTouch() {
        player?.seek(to: (player?.currentTime())! - CMTime(seconds: 10, preferredTimescale: 1))
    }
    
    func backwardByTripleTouch() {
        player?.seek(to: (player?.currentTime())! - CMTime(seconds: 20, preferredTimescale: 1))
    }
    
    func setupTimings() {
        guard let playerItem = player.currentItem else {return}
        duration = playerItem.asset.duration
        seconds = CMTimeGetSeconds(duration!)
        
        currentDuration = playerItem.currentTime()
        currentSeconds = CMTimeGetSeconds(currentDuration!)
    }
}
