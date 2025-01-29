//
//  WeeklyStatsView+ViewModel.swift
//  NotYourMom
//
//  Created by Gokul P on 1/28/25.
//

import Foundation

extension WeeklyStatsView {

    class ViewModel {
        let sessions: [PomodoroSession]

        init(sessions: [PomodoroSession]) {
            self.sessions = sessions
        }

        var currentWeekStats: [DayStats] {
            let calendar = Calendar.current
            let today = Date()
            guard let startOfWeek = calendar.date(from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: today
            )) else {
                return []
            }

            let weekStatList = (0..<7).map { dayOffset in
                let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek) ?? Date()
                let dayStart = calendar.startOfDay(for: date)
                let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

                let dayMinutes = sessions
                    .filter { $0.startDate >= dayStart && $0.startDate < dayEnd && $0.wasCompleted }
                    .reduce(0.0) { $0 + $1.duration / 60 }

                return DayStats(weekday: date, totalMinutes: dayMinutes)
            }
            return weekStatList
        }

        var weeklyAverage: Double {
            let totalMinutes = currentWeekStats.reduce(0.0) { $0 + $1.totalMinutes }
            let daysWithSessions = currentWeekStats.filter { $0.totalMinutes > 0 }.count
            return daysWithSessions > 0 ? totalMinutes / Double(daysWithSessions) : 0
        }

        var lastWeekComparison: Double? {
            let calendar = Calendar.current
            let today = Date()
            let startOfCurrentWeek = calendar.date(from: calendar.dateComponents(
                [.yearForWeekOfYear, .weekOfYear],
                from: today
            ))!
            let startOfLastWeek = calendar.date(byAdding: .weekOfYear, value: -1, to: startOfCurrentWeek)!

            let lastWeekSessions = sessions.filter { session in
                session.startDate >= startOfLastWeek &&
                    session.startDate < startOfCurrentWeek &&
                    session.wasCompleted
            }

            guard !lastWeekSessions.isEmpty else {
                return nil
            }

            let lastWeekMinutes = lastWeekSessions.reduce(0.0) { $0 + $1.duration / 60 }
            let lastWeekDays = Set(lastWeekSessions.map { calendar.startOfDay(for: $0.startDate) }).count
            let lastWeekAverage = lastWeekMinutes / Double(lastWeekDays)

            return ((weeklyAverage - lastWeekAverage) / lastWeekAverage) * 100
        }

        var formattedAverage: String {
            let hours = Int(weeklyAverage / 60)
            let minutes = Int(weeklyAverage.truncatingRemainder(dividingBy: 60))
            return "\(hours)h \(minutes)m"
        }

        func maxYValue() -> Double {
            currentWeekStats.map(\.totalMinutes).max() ?? 0
        }

        func formatDuration(minutes: Double) -> String {
            if minutes < 60 {
                return "\(Int(minutes))m"
            } else {
                let hours = Int(minutes / 60)
                let remainingMinutes = Int(minutes.truncatingRemainder(dividingBy: 60))
                if remainingMinutes == 0 {
                    return "\(hours)h"
                } else {
                    return "\(hours)h \(remainingMinutes)m"
                }
            }
        }
    }
}
