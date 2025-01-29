//
//  MotionDetectorProtocol.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import Foundation

protocol MotionDetectorProtocol {
    func startMonitoring() async

    func stopMonitoring() async
}
