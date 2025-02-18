//
//  LiveActivityManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/29/25.
//

@preconcurrency import ActivityKit
import Foundation

class LiveActivityManager: LiveActivityManagerProtocol {

    /// Live activity instance
    private var liveActivity: Activity<RudePomoWidgetAttributes>?

    func startLiveActivity(_ contentState: RudePomoWidgetAttributes.ContentState) {
        let content = ActivityContent(state: contentState, staleDate: nil, relevanceScore: 0.0)
        let adventure = RudePomoWidgetAttributes(name: "hero")
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

    func stopLiveActivity(_ currentState: SessionState, _ isBreakSession: Bool) {
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

        let finalContent = RudePomoWidgetAttributes.ContentState(
            timerDuration: 60,
            isDone: true,
            liveActivityMessage: liveActivityMessage
        )
        let dismissalPolicy: ActivityUIDismissalPolicy = .default
        if let liveActivity = liveActivity {
            Task { @Sendable in
                await liveActivity.end(
                    ActivityContent(state: finalContent, staleDate: nil),
                    dismissalPolicy: dismissalPolicy
                )
            }
        }
        
    }

}
