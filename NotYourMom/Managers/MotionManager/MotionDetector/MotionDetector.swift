//
//  MotionDetector.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import CoreMotion
import Foundation

actor MotionDetector: MotionDetectorProtocol {

    private var isMotionDetecting = false
    private var motionDetectionService: MotionServiceProtocol

    init(motionDetectionService: MotionServiceProtocol = MotionService()) {
        self.motionDetectionService = motionDetectionService
    }

    func startMonitoring() async {
        guard !isMotionDetecting else {
            return
        }
        isMotionDetecting = true
        for await motion in motionDetectionService.getMotionUpdateStream() {
            processMotion(motion)
        }
    }

    func stopMonitoring() {
        guard isMotionDetecting else {
            return
        }
        motionDetectionService.stopStream()
        isMotionDetecting = false
    }

    // MARK: - Motion processing

    func processMotion(_ motion: CMDeviceMotion) {
//        print(motion)
    }

}
