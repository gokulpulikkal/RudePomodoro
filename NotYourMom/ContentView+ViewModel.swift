//
//  ContentView+ViewModel.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

// Your imports remain the same
import Combine
import Foundation
import Observation
import UserNotifications

extension ContentView {
    @Observable
    class ViewModel {
        private let motionManager = PhoneMotionManager.shared
        private let backgroundManager = BackgroundTaskManager.shared
        private var countdownTimer: Timer?

        // MARK: - Properties

        var isMonitoring = false
        var selectedDuration: TimeInterval = 600 // Default 10 minutes
        var remainingTime: TimeInterval = 0

        // MARK: - Monitoring Control

        func startMonitoring() {
            guard !isMonitoring else {
                return
            }

            print("📱 Starting monitoring session")
            isMonitoring = true
            remainingTime = selectedDuration

            // First start background task to ensure background runtime
            backgroundManager.startBackgroundLocationTask()

            // Then start motion detection
            motionManager.startMonitoring()

            // Start countdown timer
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else {
                    return
                }

                if remainingTime > 0 {
                    remainingTime -= 1
                } else {
                    stopMonitoring()
                }
            }

            print("✅ Monitoring session started successfully")
        }

        func stopMonitoring() {
            print("🛑 Stopping monitoring session")

            // Stop motion detection
            motionManager.stopMonitoring()

            // Stop background task
            backgroundManager.stopBackgroundTask()

            // Clean up timer
            countdownTimer?.invalidate()
            countdownTimer = nil

            // Reset state
            isMonitoring = false
            remainingTime = 0

            print("✅ Monitoring session stopped")
            
            let content = UNMutableNotificationContent()
            content.title = "Monitoring Stopped"
            content.body = "The background monitoring duration has ended."
            content.sound = .default

            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }

        deinit {
            stopMonitoring()
        }

        // MARK: - Time Formatting

        var formattedRemainingTime: String {
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
