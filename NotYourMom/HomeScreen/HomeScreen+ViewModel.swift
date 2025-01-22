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
        private let notificationManager: NotificationManager
        private var countdownTimer: Timer?

        // MARK: - Properties

        var activity: Activity<RudePomoWidgetAttributes>?
        var isMute = true
        var timerTime: Int? = 10
        var isTimerEditing = false
        var currentState: AnimationActions = .idle
        var selectedDuration: TimeInterval = 25 * 60 // Default 10 minutes
        var remainingTime: TimeInterval = 25 * 60
        var startDate: Date?
        var lastUpdate: Date?

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
            motionManager: PhoneMotionManager = PhoneMotionManager(),
            notificationManager: NotificationManager = NotificationManager()
        ) {
            self.musicManager = musicManager
            self.motionManager = motionManager
            self.notificationManager = notificationManager
            setInitialValues()
            setObservers()
        }

        // MARK: - Monitoring Control

        /// Needs refactoring
        func setObservers() {
            motionManager.onDetectingMotion = { [weak self] currentState in
                guard let self, let lastUpdate else {
                    return
                }
                if Date().timeIntervalSince(lastUpdate) > 3 { // 3  seconds gap
                    if currentState == .lifted {
                        self.lastUpdate = Date()
                        notificationManager.sendRudeNotification()
                    }
                }
            }
        }

        func setSelectedDuration() {
            selectedDuration = Double(timerTime ?? 10) * 60
            setInitialValues()
        }

        func setInitialValues() {
            Task { @MainActor in
                currentState = .idle
                selectedDuration = Double(timerTime ?? 10) * 60
                remainingTime = selectedDuration
                startDate = nil
                lastUpdate = nil
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
            startDate = Date()
            lastUpdate = Date()

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
            startDate = nil
            lastUpdate = nil
            print("✅ Monitoring session stopped")
            sendMonitoringStoppedNotification()
        }

        func sendPhoneMotionDetectedRudeNotification() {}

        func sendMonitoringStoppedNotification() {
            Task {
                let content = UNMutableNotificationContent()
                content.title = "Monitoring Stopped"
                content.body = "The background monitoring duration has ended."
                content.sound = .default

                let request = UNNotificationRequest(
                    identifier: UUID().uuidString,
                    content: content,
                    trigger: nil
                )
                do {
                    try await UNUserNotificationCenter.current().add(request)
                } catch {
                    print("did not send  monitoring stopped notification! \(error.localizedDescription)")
                }
            }
        }

        // MARK: - Live activity controls

        func startLiveActivity() {
            let adventure = RudePomoWidgetAttributes(name: "hero")
            let initialState = RudePomoWidgetAttributes.ContentState(
                startDate: startDate,
                timerDuration: selectedDuration,
                liveActivityMessage: .init(title: "Pomo is sleeping", body: "")
            )
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
            let liveActivityMessage: LiveActivityMessage = currentState == .stopped
                ? .init(
                    title: "Pomo is Angry",
                    body: "You interrupted his sleep"
                )
                : .init(title: "Pomo is Happy", body: "You did a great job!")
            Task {
                let finalContent = RudePomoWidgetAttributes.ContentState(
                    timerDuration: selectedDuration,
                    isDone: true,
                    liveActivityMessage: liveActivityMessage
                )
                let dismissalPolicy: ActivityUIDismissalPolicy = .default
                await activity?.end(
                    ActivityContent(state: finalContent, staleDate: nil),
                    dismissalPolicy: dismissalPolicy
                )
            }
        }
    }
}
