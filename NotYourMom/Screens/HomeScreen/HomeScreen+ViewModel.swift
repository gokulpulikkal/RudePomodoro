//
//  HomeScreen+ViewModel.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import Foundation
import Observation
import RiveRuntime
import SwiftData

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

        private let liveActivityManager: LiveActivityManagerProtocol

        /// Timer instance
        private var countdownTimer: Timer?

        /// Pomo current state
        var currentState: SessionState = .idle {
            didSet {
                handleAnimationForCurrentState()
            }
        }

        /// Time picker binding variable for the main session
        var timerTime: Int? = 25 {
            didSet {
                remainingTime = Double(timerTime ?? 25) * 60
            }
        }

        /// Time picker binding variable for the break session
        var breakTime: Int? = 5

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
            getActionButtonText()
        }

        /// message to show on top of the pomo animation
        var pomoMessage: String {
            getPomoMessage()
        }

        // MARK: - Init

        init(
            musicManager: MusicServiceProtocol = MusicManager(),
            motionManager: MotionDetectorProtocol = MotionDetector(),
            notificationManager: NotificationManager = NotificationManager(),
            liveActivityManager: LiveActivityManagerProtocol = LiveActivityManager(),
            sessionHistoryManager: SessionHistoryManager = SessionHistoryManager()
        ) {
            self.musicManager = musicManager
            self.motionManager = motionManager
            self.notificationManager = notificationManager
            self.liveActivityManager = liveActivityManager
            self.sessionHistoryManager = sessionHistoryManager
            setInitialValues()
        }

        // MARK: - Context Methods

        /// Setting the model context to save the session history
        func setModelContext(_ context: ModelContext) {
            sessionHistoryManager.setModelContext(context)
        }

        // MARK: - Ui values

        /// Function that returns the text for the action button w.r.t currentState
        private func getActionButtonText() -> String {
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

        /// Function that will return message to be shown in the header text field
        private func getPomoMessage() -> String {
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
                if isBreakSession {
                    "Hmm seems like you are ready for the next focus session!!"
                } else {
                    "Rude! You woke Pomo up! It's giving you side-eye right now."
                }

            case .finished:
                if isBreakSession {
                    "Break time's over! Ready for another focused session?"
                } else {
                    "Boom! Pomo's feeling fresh and fabulous after that nap. Time for a break!"
                }
            }
        }

        // MARK: - Animation trigger

        /// Function that will handle the triggering of animation of pomo model w.r.t currenState
        private func handleAnimationForCurrentState() {
            switch currentState {
            case .idle:
                triggerAnimation(trigger: .reset)
            case .running:
                guard !isBreakSession else {
                    return
                }
                triggerAnimation(trigger: .start)
            case .stopped:
                guard !isBreakSession else {
                    return
                }
                triggerAnimation(trigger: .stop)
            case .finished:
                guard !isBreakSession else {
                    return
                }
                triggerAnimation(trigger: .finish)
            }
        }

        /// The pomo animation get's triggered here
        private func triggerAnimation(trigger: AnimationTriggers) {
            Task { @MainActor in
                switch trigger {
                case .start:
                    rivAnimModel.triggerInput("start")
                case .stop:
                    rivAnimModel.triggerInput("stop")
                case .finish:
                    rivAnimModel.triggerInput("finish")
                case .reset:
                    rivAnimModel.triggerInput("reset")
                }
            }
        }

        // MARK: - Button actions

        /// Main button action handling
        func onMainActionButtonPress() {
            switch currentState {
            case .idle:
                startSession()
            case .running:
                endSession()
            case .stopped:
                setInitialValues()
            case .finished:
                if !isBreakSession {
                    startBreakSession()
                } else {
                    setInitialValues()
                }
            }
        }

        // MARK: - Feature toggles

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

        /// logic to show hide skip button
        func showSkipButton() -> Bool {
            currentState == .finished && !isBreakSession
        }

        func showFeatureToggleButtons() -> Bool {
            currentState == .running && !isBreakSession
        }

        // TODO: Function to toggle motion detection
        func toggleMotionMonitoring() {
            guard currentState == .running, !isBreakSession else {
                return
            }
            if isMotionDetectionOn {
                motionManager.stopMonitoring()
            } else {
                Task {
                    await motionManager.startMonitoring()
                }
            }
            isMotionDetectionOn.toggle()
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

        /// Stops the music and motion manager sessions
        private func stopMonitoringMangers() {
            isMute = true
            motionManager.stopMonitoring()
            musicManager.stopPlayback()
        }

        /// Function to start the session countdown timer
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

        /// clear the session countdown timer
        private func clearSessionTimer() {
            countdownTimer?.invalidate()
            countdownTimer = nil
        }

        /// stats the break session
        /// this function will call actual session start function after setting proper values
        private func startBreakSession() {
            currentState = .idle
            isBreakSession = true
            startSession()
        }

        /// Add method to skip break
        func skipBreak() {
            guard currentState == .finished else {
                return
            }
            setInitialValues()
        }

        /// returns whether session is complete or not
        private func isSessionComplete() -> Bool {
            remainingTime == 0
        }

        /// Starts the session. This function is responsible for starting the timer for the session, motion monitoring
        /// and audio playback starting
        func startSession() {
            guard currentState == .idle else {
                return
            }
            musicManager.startPlayback()
            if !isBreakSession {
                isMute = true
                isMotionDetectionOn = true
                Task.detached { [weak self] in

                    await self?.motionManager.startMonitoring()
                }
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
            if !isBreakSession {
                saveSession()
                stopMonitoringMangers()
            }
            sendMonitoringStoppedNotification()
            stopLiveActivity()
            clearSessionTimer()
            resetTimerValues(!isBreakSession)
        }

        /// resets timer values. Called after the session has ended
        private func resetTimerValues(_ isForBreakSession: Bool) {
            guard currentState == .finished else {
                return
            }
            if isForBreakSession {
                remainingTime = Double(breakTime ?? 5) * 60
            } else {
                remainingTime = Double(timerTime ?? 25) * 60
            }
        }

        /// saves session to the swift Data
        /// Used later for session history
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

        // MARK: - Notification related handlings

        /// sends monitoring stopped notification with user local notification
        func sendMonitoringStoppedNotification() {
            switch (currentState, isBreakSession) {
            case (.finished, true):
                let title = "Break Time Complete!"
                let body = "Time to get back to work! Start your next focused session."
                notificationManager.sendNotification(title, body: body)
            case (.finished, false):
                notificationManager.sendSuccessNotification()
                return
            case (.stopped, true):
                let title = "Break Interrupted"
                let body = "Your break session was stopped before completion."
                notificationManager.sendNotification(title, body: body)
            case (.stopped, false):
                let title = "Work Session Interrupted"
                let body = "Your Pomodoro session was stopped before completion."
                notificationManager.sendNotification(title, body: body)
            default:
                return
            }
        }

        // MARK: - Live activity controls

        /// Starts live activity
        func startLiveActivity() {
            Task { [isBreakSession, timerTime, breakTime, sessionStartDate] in
                let message: LiveActivityMessage = isBreakSession
                    ? .init(title: "Break Time", body: "Taking a well-deserved break")
                    : .init(title: "Pomo is sleeping", body: "Focus time!")

                let initialState = RudePomoWidgetAttributes.ContentState(
                    startDate: sessionStartDate,
                    timerDuration: isBreakSession ? Double(breakTime ?? 10) * 60 : Double(timerTime ?? 10) * 60,
                    liveActivityMessage: message
                )
                await liveActivityManager.startLiveActivity(initialState)
            }
        }

        /// stops live activity
        func stopLiveActivity() {
            Task { [currentState, isBreakSession] in
                await liveActivityManager.stopLiveActivity(currentState, isBreakSession)
            }
        }
    }
}
