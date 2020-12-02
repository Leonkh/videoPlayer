//
//  VideoPresenter.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 02.12.2020.
//

import Foundation

class VideoPresenter {
    
    var currentVideo: LastVideo?
    var playerView: PlayerView? = nil
    var mainView: ViewController? = nil
    
    
    var isVideoPlaying = false
    var isVideoLoaded = false
    
    func loadData() {
        currentVideo = LastVideo.loadLast()
    }
    
    @objc func saveData() {
        guard let videoURL = currentVideo?.videoURL else {return}
        guard let currentTime = currentVideo?.currentTime else {return}
        LastVideo.saveLast(videoURL: videoURL, currentTime: currentTime)
    }
    
    func videoWasPicked(videoURL: URL) {
        guard let playerView = playerView else {return}
        playerView.createController(videoURL: videoURL)
        guard let seconds = playerView.seconds else {return}
        guard let current = playerView.currentSeconds else {return}
        guard let maxSeconds = playerView.seconds else {return}
        guard let mainView = mainView else {return}
        currentVideo = LastVideo(videoURL: videoURL, currentTime: 0)
        isVideoLoaded = true
        let duration = stringFromTimeInterval(interval: seconds)
        let currentTime = stringFromTimeInterval(interval: current)
        let maxValue = Float(maxSeconds)
        mainView.setupSliderAndLabels(duration: duration, current: currentTime, maxValue: maxValue)
    }
    
    
    func stringFromTimeInterval(interval: TimeInterval) -> String {
        let interval = Int(interval)
        let seconds = interval % 60
        let minutes = (interval / 60) % 60
        let hours = (interval / 3600)
        return String(format: "%02d:%02d:%02d", hours, minutes, seconds)
    }
    func playButtonTapped() {
        guard let mainView = mainView else {return}
        guard let playerView = playerView else {return}
        if isVideoLoaded == false {
            mainView.alertNoVideo()
            return
        }
        isVideoPlaying = !isVideoPlaying
        mainView.changeImagePlayButton(status: isVideoPlaying)
        if isVideoPlaying {
            playerView.play()
        } else {
            playerView.pause()
        }
    }
    func stopButtonTapped() {
        guard let mainView = mainView else {return}
        guard let playerView = playerView else {return}
        if isVideoLoaded == false {
            mainView.alertNoVideo()
            return
        }
        isVideoPlaying = false
        mainView.changeImagePlayButton(status: isVideoPlaying)
        playerView.stop()
    }
    
    func forwardViewTapped() {
        guard let playerView = playerView else {return}
        playerView.forwardByDoubleTouch()
    }
    func backwardViewTapped() {
        guard let playerView = playerView else {return}
        playerView.backwardByDoubleTouch()
    }
    
    func sliderValueChanged(sliderValue: Float) {
        guard let playerView = playerView else {return}
        let seconds: Int64 = Int64(sliderValue)
        playerView.changeCurrentTime(seconds: seconds)
    }
}
