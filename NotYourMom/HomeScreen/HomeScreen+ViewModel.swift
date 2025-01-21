//
//  HomeScreen+ViewModel.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import ActivityKit
import Combine
import Foundation
import Observation
import UserNotifications

extension HomeScreen {

    @MainActor
    @Observable
    class ViewModel {
        private let motionManager: PhoneMotionManager
        private let musicManager: MusicServiceProtocol
        private var countdownTimer: Timer?

        // MARK: - Properties

        var activity: Activity<RudePomoWidgetAttributes>?
        var isMute = true
        var timerTime: Int? = 10
        var isTimerEditing = false
        var currentState: AnimationActions = .idle
        var selectedDuration: TimeInterval = 25 * 60 // Default 10 minutes
        var remainingTime: TimeInterval = 25 * 60
        var currentSymbol: String {
            switch currentState {
            case .idle:
                "play.fill"
            case .running:
                "stop.fill"
            case .stopped, .finished:
                "arrow.trianglehead.counterclockwise"
            }
        }

        init(
            musicManager: MusicServiceProtocol = MusicManager(),
            motionManager: PhoneMotionManager = PhoneMotionManager()
        ) {
            self.musicManager = musicManager
            self.motionManager = motionManager
            setInitialValues()
            setObservers()
        }

        // MARK: - Monitoring Control

        /// Needs refactoring
        func setObservers() {
            motionManager.onDetectingMotion = { currentState in
                print("The state now is \(currentState)")
            }
        }

        func setSelectedDuration() {
            selectedDuration = Double(timerTime ?? 10) * 60
            setInitialValues()
        }

        func setInitialValues() {
            Task { @MainActor in
                currentState = .idle
                remainingTime = selectedDuration
            }
        }

        func toggleAudioMute() {
            isMute.toggle()
            Task {
                await musicManager.toggleMute(isMute: isMute)
            }
        }

        func startMonitoring() async -> Bool {
            guard currentState == .idle else {
                return false
            }

            print("📱 Starting monitoring session")
            currentState = .running
            remainingTime = selectedDuration

            await musicManager.startPlayback()
            startLiveActivity()

            // Then start motion detection
            motionManager.startMonitoring()

            // Start countdown timer
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else {
                    return
                }

                Task { @MainActor [weak self] in
                    guard let self else {
                        return
                    }
                    if remainingTime > 0 {
                        remainingTime -= 1
                    } else {
                        await stopMonitoring()
                    }
                }
            }

            print("✅ Monitoring session started successfully")
            return true
        }

        func stopMonitoring() async {
            print("🛑 Stopping monitoring session")
            currentState = remainingTime == 0 ? .finished : .stopped

            // Stop motion detection
            motionManager.stopMonitoring()

            // Stop background task
            await musicManager.stopPlayback()
            stopLiveActivity()

            // Clean up timer
            countdownTimer?.invalidate()
            countdownTimer = nil
//            print("✅ Monitoring session stopped")
//
//            let content = UNMutableNotificationContent()
//            content.title = "Monitoring Stopped"
//            content.body = "The background monitoring duration has ended."
//            content.sound = .default
//
//            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
//            try? await UNUserNotificationCenter.current().add(request)
        }

        // MARK: - Live activity controls

        func startLiveActivity() {
            let adventure = RudePomoWidgetAttributes(name: "hero")
            let initialState = RudePomoWidgetAttributes.ContentState(emoji: "Started 😎")
            let content = ActivityContent(state: initialState, staleDate: nil, relevanceScore: 0.0)
            do {
                activity = try Activity.request(
                    attributes: adventure,
                    content: content,
                    pushType: nil
                )
            } catch {
                print("Couldn't start the activity!!! \(error.localizedDescription)")
            }
        }

        func stopLiveActivity() {
            Task {
                let finalContent = RudePomoWidgetAttributes.ContentState(emoji: "Ended 🥶")
                let dismissalPolicy: ActivityUIDismissalPolicy = .default
                await activity?.end(
                    ActivityContent(state: finalContent, staleDate: nil),
                    dismissalPolicy: dismissalPolicy
                )
            }
        }

        // MARK: - Time Formatting

        var formattedRemainingTime: String {
            let minutes = Int(remainingTime) / 60
            let seconds = Int(remainingTime) % 60
            return String(format: "%02d:%02d", minutes, seconds)
        }
    }
}
