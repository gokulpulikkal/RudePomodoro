//
//  MusicServiceProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import Foundation

protocol MusicServiceProtocol {
    func startPlayback()
    func stopPlayback()
    func toggleMute(isMute: Bool)
}
