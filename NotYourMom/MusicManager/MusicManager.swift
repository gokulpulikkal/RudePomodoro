//
//  MusicManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import Foundation
import AVFoundation

actor MusicManager: MusicServiceProtocol {
    
    private var avPlayer: AVAudioPlayer?
    private let path = Bundle.main.path(forResource: "rain.wav", ofType: nil)
    
    init() {
        let audioSession = AVAudioSession.sharedInstance()
        do {
            try audioSession.setCategory(.playback)
        } catch {
            print("Setting category to AVAudioSessionCategoryPlayback failed.")
        }
    }
    
    func startPlayback() {
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
    
    func stopPlayback() {
        avPlayer?.stop()
    }
    
    func toggleMute(isMute: Bool) {
        avPlayer?.setVolume(isMute ? 0: 5, fadeDuration: 0)
    }
    
    
}
