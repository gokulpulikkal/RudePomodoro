//
//  MusicServiceProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import Foundation

protocol MusicServiceProtocol {
    func startPlayback() async
    func stopPlayback() async
    func toggleMute() async
}
