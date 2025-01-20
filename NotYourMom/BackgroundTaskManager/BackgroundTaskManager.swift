//
//  BackgroundTaskManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import AVFoundation
import Foundation
import UserNotifications

class BackgroundTaskManager: NSObject {

    var avPlayer: AVAudioPlayer?
    let path = Bundle.main.path(forResource: "rain.wav", ofType: nil)

    static let shared = BackgroundTaskManager()

    override private init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }

    func startBackgroundLocationTask() {
        guard let path else {
            return
        }
        let url = URL(fileURLWithPath: path)
        do {
            avPlayer = try AVAudioPlayer(contentsOf: url)
            avPlayer?.numberOfLoops = -1
            avPlayer?.play()
        } catch {
            print("couldn't load file :(")
        }
    }

    func stopBackgroundTask() {
        avPlayer?.stop()
    }
}
