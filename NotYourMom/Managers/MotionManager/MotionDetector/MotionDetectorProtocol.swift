//
//  MotionDetectorProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import Foundation

protocol MotionDetectorProtocol: Sendable {    
    func hasDetectedMotion() async -> AsyncStream<Bool>

    func stopMonitoring() async
}
