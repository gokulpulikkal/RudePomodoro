//
//  MotionDetectorProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import Foundation

protocol MotionDetectorProtocol {    
    func hasDetectedMotion() -> AsyncStream<Bool>

    func stopMonitoring()
}
