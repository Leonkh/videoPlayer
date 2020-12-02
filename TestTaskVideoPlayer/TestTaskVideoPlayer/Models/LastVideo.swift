//
//  LastVideo.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 02.12.2020.
//

import Foundation

struct LastVideo {
    let videoURL: URL?
    let currentTime: Float
    
    static func loadLast() -> LastVideo? {
        let defaults = UserDefaults.standard
        guard let video = defaults.object(forKey: "lastVideo") as? LastVideo else { return nil }
        return video
    }
    
    static func saveLast(videoURL: URL, currentTime: Float) {
        let video = LastVideo(videoURL: videoURL, currentTime: currentTime)
        let defaults = UserDefaults.standard
        defaults.setValue(video, forKey: "lastVideo")
    }
}
