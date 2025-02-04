//
//  PreviewData.swift
//  NotYourMom
//
//  Created by Gokul P on 2/4/25.
//

import Foundation

/// Helper struct for preview data
enum PreviewData {
    static func generateSessions() -> [PomodoroSession] {
        let calendar = Calendar.current
        let today = Date()

        // Generate sessions for the last 2 weeks with varying durations
        return (-13...0).flatMap { dayOffset -> [PomodoroSession] in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: today)!

            // Generate 0-3 sessions per day
            return (0..<Int.random(in: 0...3)).map { _ -> PomodoroSession in
                let startHour = Int.random(in: 9...17) // Between 9 AM and 5 PM
                let startDate = calendar.date(
                    bySettingHour: startHour,
                    minute: Int.random(in: 0...20),
                    second: 0,
                    of: date
                )!

                // Generate random durations between 5-25 minutes
                let duration = TimeInterval(Int.random(in: 5...25) * 60)

                return PomodoroSession(
                    startDate: startDate,
                    duration: duration,
                    wasCompleted: Bool.random()
                )
            }
        }
    }
}
