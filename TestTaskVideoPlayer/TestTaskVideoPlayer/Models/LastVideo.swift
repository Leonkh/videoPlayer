//
//  LastVideo.swift
//  TestTaskVideoPlayer
//
//  Created by Леонид Хабибуллин on 02.12.2020.
//

import Foundation

struct LastVideo: Codable {
    let videoURL: URL?
    let currentTime: Float
    
    static func loadLast() -> LastVideo? {
        let defaults = UserDefaults()
        if let dataToLoad = defaults.object(forKey: "lastVideo") as? Data {
            let jsonDecoder = JSONDecoder()
            do {
                let video = try jsonDecoder.decode(LastVideo.self, from: dataToLoad)
                print("data was loaded")
                return video
            } catch {
                print("Failed to load")
            }
        }
        return nil
    }
    
    static func saveLast(videoURL: URL, currentTime: Float) {
        let video = LastVideo(videoURL: videoURL, currentTime: currentTime)
        let jsonEncoder = JSONEncoder()
        if let dataToSave = try? jsonEncoder.encode(video) {
            let defaults = UserDefaults()
            defaults.setValue(dataToSave, forKey: "lastVideo")
            print("data was saved")
        } else {
            print("Failed to save data")
        }
    }
}
