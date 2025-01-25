import Charts
import SwiftUI

struct WeeklyStatsView: View {
    let sessions: [PomodoroSession]

    private struct DayStats {
        let weekday: Date
        let totalMinutes: Double
    }

    private var currentWeekStats: [DayStats] {
        let calendar = Calendar.current
        let today = Date()
        let startOfWeek = calendar.date(from: calendar.dateComponents([.yearForWeekOfYear, .weekOfYear], from: today))!

        return (0..<7).map { dayOffset in
            let date = calendar.date(byAdding: .day, value: dayOffset, to: startOfWeek)!
            let dayStart = calendar.startOfDay(for: date)
            let dayEnd = calendar.date(byAdding: .day, value: 1, to: dayStart)!

            let dayMinutes = sessions
                .filter { $0.startDate >= dayStart && $0.startDate < dayEnd && $0.wasCompleted }
                .reduce(0.0) { $0 + $1.duration / 60 }

            return DayStats(weekday: date, totalMinutes: dayMinutes)
        }
    }

    private var weeklyAverage: Double {
        let totalMinutes = currentWeekStats.reduce(0.0) { $0 + $1.totalMinutes }
        let daysWithSessions = currentWeekStats.filter { $0.totalMinutes > 0 }.count
        return daysWithSessions > 0 ? totalMinutes / Double(daysWithSessions) : 0
    }

    private var lastWeekComparison: Double? {
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

    private var formattedAverage: String {
        let hours = Int(weeklyAverage / 60)
        let minutes = Int(weeklyAverage.truncatingRemainder(dividingBy: 60))
        return "\(hours)h \(minutes)m"
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Average")
                    .font(.sourGummy(.regular, size: 24))
                    .foregroundStyle(.gray)

                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(formattedAverage)
                        .font(.sourGummy(.bold, size: 24))
                        .foregroundStyle(.white)

                    if let comparison = lastWeekComparison {
                        HStack(spacing: 4) {
                            Image(systemName: comparison >= 0 ? "arrow.up" : "arrow.down")
                            Text("\(abs(Int(comparison)))% from last week")
                        }
                        .font(.sourGummy(.regular, size: 14))
                        .foregroundStyle(.gray)
                    }
                }
            }

            Chart {
                ForEach(currentWeekStats, id: \.weekday) { stat in
                    BarMark(
                        x: .value("Day", stat.weekday, unit: .weekday),
                        y: .value("Duration", stat.totalMinutes)
                    )
                    .foregroundStyle(Color.cyan)
                    .annotation(position: .top) {
                        if stat.totalMinutes > 0 {
                            Text(formatDuration(minutes: stat.totalMinutes))
                                .font(.sourGummy(.regular, size: 10))
                                .foregroundStyle(.gray)
                        }
                    }
                }

                RuleMark(
                    y: .value("Average", weeklyAverage)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(.green)
                .annotation(position: .top, alignment: .trailing) {
                    Text("avg")
                        .font(.sourGummy(.regular, size: 12))
                        .foregroundStyle(.green)
                }
            }
            .chartXAxis {
                AxisMarks(values: .stride(by: .day)) { value in
                    if let date = value.as(Date.self) {
                        AxisValueLabel {
                            Text(date.formatted(.dateTime.weekday(.narrow)))
                                .font(.sourGummy(.regular, size: 12))
                                .foregroundStyle(.gray)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            .chartYScale(domain: 0...maxYValue())
            .frame(height: 200)
        }
        .padding()
        .background(Color(hex: "5E2929"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
        
    }

    private func maxYValue() -> Double {
        return currentWeekStats.map(\.totalMinutes).max() ?? 0
    }

    private func formatDuration(minutes: Double) -> String {
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

#Preview {
    WeeklyStatsView(sessions: PreviewData.generateSessions())
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
        .padding()
}

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
                    minute: Int.random(in: 0...59),
                    second: 0,
                    of: date
                )!

                // Generate random durations between 25-120 minutes
                let duration = TimeInterval(Int.random(in: 25...120) * 60)

                return PomodoroSession(
                    startDate: startDate,
                    duration: duration,
                    wasCompleted: Bool.random()
                )
            }
        }
    }

    static func generateHighUsageData() -> [PomodoroSession] {
        // Many long sessions
        // ... similar logic with higher durations and more sessions
        []
    }

    static func generateLowUsageData() -> [PomodoroSession] {
        // Few short sessions
        // ... similar logic with lower durations and fewer sessions
        []
    }

    static func generateIncompleteData() -> [PomodoroSession] {
        // Mostly incomplete sessions
        // ... similar logic with wasCompleted mostly false
        []
    }
}
