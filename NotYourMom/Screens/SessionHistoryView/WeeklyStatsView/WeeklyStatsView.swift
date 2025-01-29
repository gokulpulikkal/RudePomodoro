//
//  WeeklyStatsView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/24/25.
//

import Charts
import SwiftUI

struct WeeklyStatsView: View {

    let viewModel: ViewModel

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Text("Daily Average")
                    .font(.sourGummy(.regular, size: 24))
                    .foregroundStyle(.gray)

                HStack(alignment: .firstTextBaseline, spacing: 16) {
                    Text(viewModel.formattedAverage)
                        .font(.sourGummy(.bold, size: 24))
                        .foregroundStyle(.white)

                    if let comparison = viewModel.lastWeekComparison {
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
                ForEach(viewModel.currentWeekStats, id: \.weekday) { stat in
                    BarMark(
                        x: .value("Day", stat.weekday, unit: .weekday),
                        y: .value("Duration", stat.totalMinutes)
                    )
                    .foregroundStyle(Color(hex: "#CB5042"))
                    .annotation(position: .top) {
                        if stat.totalMinutes > 0 {
                            Text(viewModel.formatDuration(minutes: stat.totalMinutes))
                                .font(.sourGummy(.regular, size: 10))
                                .foregroundStyle(.white)
                        }
                    }
                }

                RuleMark(
                    y: .value("Average", viewModel.weeklyAverage)
                )
                .lineStyle(StrokeStyle(lineWidth: 1, dash: [5, 5]))
                .foregroundStyle(Color(hex: "#3B6B2B"))
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
                                .foregroundStyle(.white)
                        }
                    }
                }
            }
            .chartYAxis {
                AxisMarks { _ in
                    AxisGridLine()
                        .foregroundStyle(.gray.opacity(0.3))
                }
            }
            .chartYScale(domain: 0...viewModel.maxYValue())
            .frame(height: 200)
        }
        .padding()
        .background(Color(hex: "5E2929"))
        .clipShape(RoundedRectangle(cornerRadius: 15))
        .shadow(color: .black.opacity(0.4), radius: 10, x: 0, y: 5)
    }
}

#Preview {
    WeeklyStatsView(viewModel: WeeklyStatsView.ViewModel(sessions: PreviewData.generateSessions()))
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
}
