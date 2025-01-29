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
import SwiftData
import UserNotifications

extension HomeScreen {

    @MainActor
    @Observable
    class ViewModel {
        // MARK: - Properties

        private let motionManager: PhoneMotionManager
        private let musicManager: MusicServiceProtocol
        private let notificationManager: NotificationManager
        private let sessionHistoryManager: SessionHistoryManager

        private var countdownTimer: Timer?
        var liveActivity: Activity<RudePomoWidgetAttributes>?
        var isMute = true

        var isTimerEditing = false
        var currentState: AnimationActions = .idle

        var timerTime: Int? = 1
        var selectedDuration: TimeInterval = 10 * 60
        var remainingTime: TimeInterval = 10 * 60

        var startDate: Date?
        var lastUpdate: Date?

        var isBreakTime = false
        var breakTime: Int? = 1
        var isMotionDetectionOn = true

        var currentSymbol: String {
            switch currentState {
            case .idle:
                if isBreakTime {
                    "Start Break"
                } else {
                    "Start"
                }
            case .running:
                "Stop"
            case .stopped, .finished:
                "Reset"
            }
        }

        var pomoMessage: String {
            switch currentState {
            case .idle:
                if isBreakTime {
                    "Time for a break! Set your break duration or skip it."
                } else {
                    "Pomo's chilling right now, but you should get to work before it judges you."
                }
            case .running:
                if isBreakTime {
                    "Enjoy your break! Pomo's making sure you relax properly."
                } else {
                    "Shhh... Pomo's in a deep nap. Don't make it mad! Put your phone down and do some work"
                }
            case .stopped:
                "Rude! You woke Pomo up! It's giving you side-eye right now."
            case .finished:
                if isBreakTime {
                    "Break time's over! Ready for another focused session?"
                } else {
                    "Boom! Pomo's feeling fresh and fabulous after that nap. Time for a break!"
                }
            }
        }

        init(
            musicManager: MusicServiceProtocol = MusicManager(),
            motionManager: PhoneMotionManager = PhoneMotionManager(),
            notificationManager: NotificationManager = NotificationManager(),
            sessionHistoryManager: SessionHistoryManager = SessionHistoryManager()
        ) {
            self.musicManager = musicManager
            self.motionManager = motionManager
            self.notificationManager = notificationManager
            self.sessionHistoryManager = sessionHistoryManager
            setInitialValues()
            setObservers()
        }

        func setModelContext(_ context: ModelContext) {
            sessionHistoryManager.setModelContext(context)
        }

        // MARK: - Monitoring Control

        /// Needs refactoring
        func setObservers() {
            motionManager.onDetectingMotion = { [weak self] currentState in
                guard let self, let lastUpdate, isMotionDetectionOn else {
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
                if isBreakTime {
                    selectedDuration = Double(breakTime ?? 5) * 60
                } else {
                    selectedDuration = Double(timerTime ?? 10) * 60
                }
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
            currentState = .running
            remainingTime = selectedDuration
            startDate = Date()
            lastUpdate = Date()
            isMute = true

            if !isBreakTime {
                await musicManager.startPlayback()
                // Then start motion detection
                motionManager.startMonitoring()
            }
            startLiveActivity()
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
            return true
        }

        func stopMonitoring() async {
            let wasFinished = remainingTime == 0
            currentState = wasFinished ? .finished : .stopped

            if !isBreakTime {
                // Save session only for work sessions, not breaks
                if let startDate {
                    let session = PomodoroSession(
                        startDate: startDate,
                        duration: selectedDuration,
                        wasCompleted: wasFinished
                    )
                    await sessionHistoryManager.addSession(session)
                }

                // Stop motion detection
                motionManager.stopMonitoring()
                isMute = true
                await musicManager.stopPlayback()
            }

            // Clean up timer
            countdownTimer?.invalidate()
            countdownTimer = nil
            startDate = nil
            lastUpdate = nil

            // Send notification before changing state
            sendMonitoringStoppedNotification()
            stopLiveActivity()

            if wasFinished {
                handleSessionComplete()
            }
        }

        func sendMonitoringStoppedNotification() {
            let content = UNMutableNotificationContent()

            switch (currentState, isBreakTime) {
            case (.finished, true):
                // Break completed successfully
                content.title = "Break Time Complete!"
                content.body = "Time to get back to work! Start your next focused session."
            case (.finished, false):
                // Work session completed successfully
                notificationManager.sendSuccessNotification()
                return
            case (.stopped, true):
                // Break interrupted
                content.title = "Break Interrupted"
                content.body = "Your break session was stopped before completion."
            case (.stopped, false):
                // Work session interrupted
                content.title = "Work Session Interrupted"
                content.body = "Your Pomodoro session was stopped before completion."
            default:
                return // Don't send notification for other states
            }

            content.sound = .default

            let request = UNNotificationRequest(
                identifier: UUID().uuidString,
                content: content,
                trigger: nil
            )

            Task { [request] in
                do {
                    try await UNUserNotificationCenter.current().add(request)
                } catch {
                    print("Failed to send notification: \(error.localizedDescription)")
                }
            }
        }

        // MARK: - Live activity controls

        func startLiveActivity() {
            let adventure = RudePomoWidgetAttributes(name: "hero")
            let message: LiveActivityMessage = isBreakTime
                ? .init(title: "Break Time", body: "Taking a well-deserved break")
                : .init(title: "Pomo is sleeping", body: "Focus time!")

            let initialState = RudePomoWidgetAttributes.ContentState(
                startDate: startDate,
                timerDuration: selectedDuration,
                liveActivityMessage: message
            )
            let content = ActivityContent(state: initialState, staleDate: nil, relevanceScore: 0.0)
            do {
                liveActivity = try Activity.request(
                    attributes: adventure,
                    content: content,
                    pushType: nil
                )
            } catch {
                print("Couldn't start the activity!!! \(error.localizedDescription)")
            }
        }

        func stopLiveActivity() {
            let liveActivityMessage: LiveActivityMessage = switch (currentState, isBreakTime) {
            case (.stopped, true):
                .init(title: "Break Interrupted", body: "Break ended early")
            case (.stopped, false):
                .init(title: "Pomo is Angry", body: "You interrupted the session")
            case (.finished, true):
                .init(title: "Break Complete!", body: "Ready to focus?")
            case (.finished, false):
                .init(title: "Session Complete!", body: "Time for a break!")
            default:
                .init(title: "Session Ended", body: "")
            }

            Task {
                let finalContent = RudePomoWidgetAttributes.ContentState(
                    timerDuration: selectedDuration,
                    isDone: true,
                    liveActivityMessage: liveActivityMessage
                )
                let dismissalPolicy: ActivityUIDismissalPolicy = .default
                await liveActivity?.end(
                    ActivityContent(state: finalContent, staleDate: nil),
                    dismissalPolicy: dismissalPolicy
                )
            }
        }

        /// Add method to handle session completion
        func handleSessionComplete() {
            if !isBreakTime {
                isBreakTime = true
                setInitialValues()
            } else {
                isBreakTime = false
                setInitialValues()
            }
        }

        /// Add method to skip break
        func skipBreak() {
            if isBreakTime {
                isBreakTime = false
                setInitialValues()
            }
        }
    }
}
