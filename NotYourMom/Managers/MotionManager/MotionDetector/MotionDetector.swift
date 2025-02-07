//
//  MotionDetector.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

import CoreMotion
import Foundation

class MotionDetector: MotionDetectorProtocol {

    enum PhoneState {
        case flat
        case lifted
    }

    private let motionManager = CMMotionManager()
    private let gravityThreshold = 0.8 // How vertical the phone needs to be
    private let pitchThreshold = 0.3 // Minimum tilt angle
    private let accelerationThreshold = 0.3
    private let motionQueue = OperationQueue()
    private var currentState: PhoneState = .flat
    private var isMotionDetecting = false
    private let minimumTimeBetweenNotifications: TimeInterval = 6 // cooldown
    private var lastUpdate: Date?
    private var motionDetectionContinuation: AsyncStream<Bool>.Continuation?

    private var motionDetectionService: MotionServiceProtocol

    init(
        motionDetectionService: MotionServiceProtocol = MotionService()
    ) {
        self.motionDetectionService = motionDetectionService
    }

    func hasDetectedMotion() -> AsyncStream<Bool> {
        AsyncStream { continuation in
            guard !isMotionDetecting else {
                continuation.finish()
                return
            }
            motionDetectionContinuation = continuation
            isMotionDetecting = true
            Task {
                for await motion in motionDetectionService.getMotionUpdateStream() {
                    continuation.yield(hasDetectedMotion(motion))
                }
            }
        }
    }

    func stopMonitoring() {
        guard isMotionDetecting else {
            return
        }
        motionDetectionContinuation?.finish()
        motionDetectionService.stopStream()
        isMotionDetecting = false
    }

    // MARK: - Motion processing

    private func hasDetectedMotion(_ motion: CMDeviceMotion) -> Bool {
        print("getting the motion data")
        let gravity = motion.gravity
        let userAcceleration = motion.userAcceleration
        let attitude = motion.attitude

        let accelerationMagnitude = sqrt(
            pow(userAcceleration.x, 2) +
                pow(userAcceleration.y, 2) +
                pow(userAcceleration.z, 2)
        )

        let isLifted = (abs(gravity.z) < gravityThreshold && attitude.pitch > pitchThreshold)
        let isQuickLift = (
            accelerationMagnitude > accelerationThreshold &&
                abs(gravity.z) < gravityThreshold &&
                attitude.pitch > pitchThreshold
        )

//        let oldState = currentState
        if currentState == .flat, isLifted || isQuickLift {
            currentState = .lifted
        } else if currentState == .lifted, abs(gravity.z) > 0.8 {
            currentState = .flat
        }

        if currentState == .lifted {
            if let lastUpdateDate = lastUpdate,
               Date().timeIntervalSince(lastUpdateDate) < minimumTimeBetweenNotifications
            {
                return false
            }
            lastUpdate = Date()
            return true
        }
        return false
    }
}
