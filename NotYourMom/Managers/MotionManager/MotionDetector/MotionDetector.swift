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

    private var motionDetectionService: MotionServiceProtocol
    /// Notification manager instance to handle all the notification related tasks
    private let notificationManager: NotificationManager

    init(
        motionDetectionService: MotionServiceProtocol = MotionService(),
        notificationManager: NotificationManager = NotificationManager()
    ) {
        self.motionDetectionService = motionDetectionService
        self.notificationManager = notificationManager
    }

    func startMonitoring() async {
        guard !isMotionDetecting else {
            return
        }
        isMotionDetecting = true
        print("Starting the motion detection!")
        for await motion in motionDetectionService.getMotionUpdateStream() {
            processMotionData(motion)
        }
    }

    func stopMonitoring() {
        guard isMotionDetecting else {
            return
        }
        motionDetectionService.stopStream()
        isMotionDetecting = false
        print("Stopped the motion detection!")
    }

    // MARK: - Motion processing

    private func processMotionData(_ motion: CMDeviceMotion) {
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

        let oldState = currentState
        if currentState == .flat, isLifted || isQuickLift {
            currentState = .lifted
        } else if currentState == .lifted, abs(gravity.z) > 0.8 {
            currentState = .flat
        }

        if oldState != currentState {
            notificationManager.sendRudeNotification()
        }
    }
}
