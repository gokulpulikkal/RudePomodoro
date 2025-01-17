//
//  PhoneMotionManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import CoreMotion
import Observation

class PhoneMotionManager {
    enum PhoneState {
        case flat
        case lifted
    }

    private let motionManager = CMMotionManager()
    private let gravityThreshold = 0.8 // How vertical the phone needs to be
    private let pitchThreshold = 0.3 // Minimum tilt angle
    private let accelerationThreshold = 0.3
    private let motionQueue = OperationQueue()

    var currentState: PhoneState = .flat
    var isMonitoring = false
    private var lastNotificationTime = Date()
    private let minimumTimeBetweenNotifications: TimeInterval = 6 // 5 seconds cooldown

    /// Add singleton instance
    static let shared = PhoneMotionManager()

    private init() {
        setupMotionDetection()
    }

    private func setupMotionDetection() {
        guard motionManager.isDeviceMotionAvailable else {
            print("❌ Device motion is not available")
            return
        }

        motionManager.deviceMotionUpdateInterval = 0.1
    }

    func startMonitoring() {
        guard !isMonitoring else {
            return
        }
        // Start motion updates first
        motionManager.startDeviceMotionUpdates(to: motionQueue) { [weak self] motion, _ in
            guard let self, let motion else {
                print("Error: Unknown error")
                return
            }
            processMotionData(motion)
        }

        isMonitoring = true
    }

    private func processMotionData(_ motion: CMDeviceMotion) {
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
            handleStateChange(currentState)
        }
    }

    private func handleStateChange(_ state: PhoneState) {
        // Check if enough time has passed since last notification
        let now = Date()
        guard now.timeIntervalSince(lastNotificationTime) >= minimumTimeBetweenNotifications else {
            return
        }

        // Only send notification when phone is lifted
        if state == .lifted {
            print("The notification is about to send! for state \(state)")
            NotificationManager.shared.sendNotification(for: state)
            lastNotificationTime = now
        }
    }

    func stopMonitoring() {
        guard isMonitoring else {
            return
        }
        motionManager.stopDeviceMotionUpdates()
        isMonitoring = false
    }
}
