//
//  CleanViewModel.swift
//  NotYourMom
//
//  Created by Gokul P on 1/28/25.
//

import Foundation
import Observation
import RiveRuntime

@MainActor
@Observable
class CleanViewModel {

    // MARK: - Properties

    @ObservationIgnored var pomoState: PomoState
    var isBreakTime = false

    /// This doesn't work as the pomoState property is no longer observed
    /// To make it work then again another property is needed
    var buttonText = "Start"
    let rivAnimModel = RiveViewModel(fileName: "pomoNoBG", stateMachineName: "State Machine")

    private var timerStartDate: Date?
    private var timerDuration: Int? = 10

    // MARK: - initializer

    init() {
        self.pomoState = PomoState(animationModel: rivAnimModel)
    }

    func changeState() {
        switch pomoState {
        case .chilling:
            print("Starting sleep")
            Task { @MainActor in
                pomoState.switchToSleeping()
                buttonText = "Stop"
            }
        case .sleeping:
            print("Stopping")
            // Is completed the timer
            if isTimerCompletedRunning() {
                Task { @MainActor in
                    pomoState.switchToAmazed()
                    buttonText = "finish"
                }
            } else {
                Task { @MainActor in
                    pomoState.switchToAngry()
                    buttonText = "finish"
                }
            }
        case .angry:
            Task { @MainActor in
                pomoState.switchToChilling()
                buttonText = "Start"
            }
        case .amazed:
            Task { @MainActor in
                pomoState.switchToChilling()
                buttonText = "Start"
            }
        }
    }

    private func isTimerCompletedRunning() -> Bool {
        guard let startDate = timerStartDate, let timerDuration else {
            return false
        }
        return true
    }
}
