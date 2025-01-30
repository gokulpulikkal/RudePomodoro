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
import RiveRuntime
import SwiftData
import UserNotifications

extension HomeScreen {

    @MainActor
    @Observable
    class ViewModel {
        // MARK: - Properties

        let rivAnimModel = RiveViewModel(fileName: "pomoNoBG", stateMachineName: "State Machine")

        /// Motion manager for detecting the motion.
        /// By default the motion detection starts when the session starts
        private let motionManager: MotionDetectorProtocol

        /// background music playback manager
        /// The music by default starts playing when the focus session starts but in muted state
        /// The user will has the option to unmute the audio with icon in the home screen
        private let musicManager: MusicServiceProtocol

        /// Notification manager instance to handle all the notification related tasks
        private let notificationManager: NotificationManager

        /// Session history manager which handles saving of the sessions
        private let sessionHistoryManager: SessionHistoryManager

        /// Timer instance
        private var countdownTimer: Timer?

        /// Live activity instance
        var liveActivity: Activity<RudePomoWidgetAttributes>?

        /// Pomo current state
        var currentState: SessionState = .idle

        /// Time picker binding variable for the main session
        var timerTime: Int? = 1 {
            didSet {
                remainingTime = Double(timerTime ?? 25) * 60
            }
        }

        /// Time picker binding variable for the break session
        var breakTime: Int? = 1

        /// Timer value to show in the count down timer
        var remainingTime: TimeInterval = 25 * 60

        /// Session start Date
        var sessionStartDate: Date?

        /// Flag that shows the motion detection icon
        var isMotionDetectionOn = true

        /// Flag for checking the session is break session or not
        var isBreakSession = false

        /// Flag to toggle timer view visibility
        var isTimerEditing = false

        /// Flag to toggle audio mute
        var isMute = true

        /// button text to show in main action button w.r.t to the currentState
        var actionButtonText: String {
            switch currentState {
            case .idle:
                "Start"
            case .running:
                "Stop"
            case .stopped:
                "Reset"
            case .finished:
                if isBreakSession {
                    "Let's Go"
                } else {
                    "Start break"
                }
            }
        }

        /// message to show on top of the pomo animation
        var pomoMessage: String {
            switch currentState {
            case .idle:
                if isBreakSession {
                    "Time for a break! Set your break duration or skip it."
                } else {
                    "Pomo's chilling right now, but you should get to work before it judges you."
                }
            case .running:
                if isBreakSession {
                    "Enjoy your break! Pomo's making sure you relax properly."
                } else {
                    "Shhh... Pomo's in a deep nap. Don't make it mad! Put your phone down and do some work"
                }
            case .stopped:
                "Rude! You woke Pomo up! It's giving you side-eye right now."
            case .finished:
                if isBreakSession {
                    "Break time's over! Ready for another focused session?"
                } else {
                    "Boom! Pomo's feeling fresh and fabulous after that nap. Time for a break!"
                }
            }
        }

        // MARK: - Init

        init(
            musicManager: MusicServiceProtocol = MusicManager(),
            motionManager: MotionDetectorProtocol = MotionDetector(),
            notificationManager: NotificationManager = NotificationManager(),
            sessionHistoryManager: SessionHistoryManager = SessionHistoryManager()
        ) {
            self.musicManager = musicManager
            self.motionManager = motionManager
            self.notificationManager = notificationManager
            self.sessionHistoryManager = sessionHistoryManager
            setInitialValues()
        }

        // MARK: - Context Methods

        /// Setting the model context to save the session history
        func setModelContext(_ context: ModelContext) {
            sessionHistoryManager.setModelContext(context)
        }

        // MARK: - Button actions

        func onMainActionButtonPress() {
            switch currentState {
            case .idle:
                startSession()
            case .running:
                endSession()
            case .stopped:
                resetPomo()
            case .finished:
                if !isBreakSession {
                    startBreakSession()
                } else {
                    setInitialValues()
                }
            }
        }

        private func resetPomo() {
            setInitialValues()
        }

        // MARK: - Monitoring Control

        /// Sets initial values for the properties
        /// Sets the session environment to the initial state
        func setInitialValues() {
            currentState = .idle
            remainingTime = Double(timerTime ?? 10) * 60
            isBreakSession = false
            sessionStartDate = nil
            countdownTimer = nil
        }

        /// Toggle the audio state
        func toggleAudioMute() {
            isMute.toggle()
            Task.detached { [weak self] in
                guard let self else {
                    return
                }
                await musicManager.toggleMute(isMute: isMute)
            }
        }

        private func startMonitoringManagers() {
            isMute = true
            Task.detached { [weak self] in
                await self?.musicManager.startPlayback()
                await self?.motionManager.startMonitoring()
            }
        }

        private func stopMonitoringMangers() {
            isMute = true
            Task { [weak self] in
                await self?.motionManager.stopMonitoring()
                await self?.musicManager.stopPlayback()
            }
        }

        private func startSessionTimer() {
            sessionStartDate = Date()
            countdownTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
                guard let self else {
                    return
                }
                Task { @MainActor in
                    if self.remainingTime > 0 {
                        self.remainingTime -= 1
                    } else {
                        self.endSession()
                    }
                }
            }
        }

        private func clearSessionTimer() {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }

        private func startBreakSession() {
            currentState = .idle
            isBreakSession = true
            startSession()
        }

        /// Starts the session. This function is responsible for starting the timer for the session, motion monitoring
        /// and audio playback starting
        func startSession() {
            guard currentState == .idle else {
                return
            }
            if !isBreakSession {
                startMonitoringManagers()
            }
            currentState = .running
            startSessionTimer()
            startLiveActivity()
        }

        /// Stops the current session
        /// stops all the monitoring session in managers.
        func endSession() {
            guard currentState == .running else {
                return
            }
            currentState = isSessionComplete() ? .finished : .stopped
            countdownTimer?.invalidate()
            if !isBreakSession {
                saveSession()
                stopMonitoringMangers()
                sendMonitoringStoppedNotification()
            }
            stopLiveActivity()
            clearSessionTimer()
            setPomoTimerValues(!isBreakSession)
        }

        private func setPomoTimerValues(_ isForBreakSession: Bool) {
            guard currentState == .finished else {
                return
            }
            if isForBreakSession {
                remainingTime = Double(breakTime ?? 5) * 60
            } else {
                remainingTime = Double(timerTime ?? 25) * 60
            }
        }

        private func isSessionComplete() -> Bool {
            remainingTime == 0
        }

        private func saveSession() {
            if let sessionStartDate {
                let session = PomodoroSession(
                    startDate: sessionStartDate,
                    duration: Double(timerTime ?? 10) * 60,
                    wasCompleted: isSessionComplete()
                )
                Task {
                    await sessionHistoryManager.addSession(session)
                }
            }
        }

        func sendMonitoringStoppedNotification() {
            let content = UNMutableNotificationContent()

            switch (currentState, isBreakSession) {
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
            let message: LiveActivityMessage = isBreakSession
                ? .init(title: "Break Time", body: "Taking a well-deserved break")
                : .init(title: "Pomo is sleeping", body: "Focus time!")

            let initialState = RudePomoWidgetAttributes.ContentState(
                startDate: sessionStartDate,
                timerDuration: Double(timerTime ?? 10) * 60,
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
            let liveActivityMessage: LiveActivityMessage = switch (currentState, isBreakSession) {
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
                    timerDuration: Double(timerTime ?? 10) * 60,
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

        /// Add method to skip break
        func skipBreak() {
            if isBreakSession {
                isBreakSession = false
                setInitialValues()
            }
        }
    }
}

// func triggerAnimation(trigger: AnimationTriggers) {
//    switch trigger {
//    case .start:
//        viewModel.rivAnimModel.triggerInput("start")
//    case .stop:
//        viewModel.rivAnimModel.triggerInput("stop")
//    case .finish:
//        viewModel.rivAnimModel.triggerInput("finish")
//    case .reset:
//        viewModel.rivAnimModel.triggerInput("reset")
//    }
// }
