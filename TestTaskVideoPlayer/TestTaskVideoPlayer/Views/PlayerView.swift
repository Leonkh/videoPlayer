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
    
    //    var duration: CMTime?
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
    
    func createController(videoURL: URL, currentTime: Float = 0) {
        let video = AVPlayerItem(url: videoURL)
        player = AVPlayer(playerItem: video)
        player.seek(to: CMTime(seconds: Double(currentTime), preferredTimescale: 1))
        setupTimings()
    }
    
    func CMTimeForObserver() -> CMTime {
        return CMTimeMakeWithSeconds(1, preferredTimescale: 1)
    }
    func CMTimeGetSeconds() -> Float64 {
        return CoreMedia.CMTimeGetSeconds(player.currentTime())
    }
    
    func play() {
        player.play()
    }
    
    func pause() {
        player.pause()
    }
    
    func stop() {
        player.seek(to: CMTime(value: 0, timescale: 1))
        pause()
    }
    
    func forwardByDoubleTouch() {
        player.seek(to: (player.currentTime()) + CMTime(seconds: Seconds.rewindSeconds, preferredTimescale: 1))
    }
    
    func forwardByTripleTouch() {
        player.seek(to: (player.currentTime()) + CMTime(seconds: Seconds.rewindSeconds * 2, preferredTimescale: 1))
    }
    
    func backwardByDoubleTouch() {
        player.seek(to: (player.currentTime()) - CMTime(seconds: Seconds.rewindSeconds, preferredTimescale: 1))
    }
    
    func backwardByTripleTouch() {
        player.seek(to: (player.currentTime()) - CMTime(seconds: Seconds.rewindSeconds * 2, preferredTimescale: 1))
    }
    
    func changeCurrentTime(seconds: Int64) {
        let targetTime: CMTime = CMTimeMake(value: seconds, timescale: 1)
        player.seek(to: targetTime)
    }
    
    func setupTimings() {
        guard let playerItem = player.currentItem else {return}
        let duration = playerItem.asset.duration
        seconds = CoreMedia.CMTimeGetSeconds(duration)
        
        let currentDuration = playerItem.currentTime()
        currentSeconds = CoreMedia.CMTimeGetSeconds(currentDuration)
    }
}
