//
//  SessionHistoryView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/24/25.
//

import Foundation
import SwiftData
import SwiftUI

struct SessionHistoryView: View {
    @Query(sort: \PomodoroSession.startDate, order: .reverse) var sessionsList: [PomodoroSession]
    @Binding var isShowing: Bool

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                Text("Session History")
                    .font(.sourGummy(.bold, size: 24))
                    .foregroundStyle(.white)
                    .padding(.vertical)
                HStack {
                    Button(action: {
                        withAnimation {
                            isShowing = false
                        }
                    }, label: {
                        Image(systemName: "arrow.backward")
                            .font(.system(size: 20))
                            .foregroundStyle(.white)
                    })
                    Spacer()
                }
                .padding()
            }

            if sessionsList.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "clock.badge.xmark",
                    description: Text("Complete your first session to see it here")
                )
                .foregroundStyle(.white)
            } else {
                WeeklyStatsView(sessions: sessionsList)
                    .padding(.horizontal)
                List {
                    ForEach(sessionsList) { session in
                        SessionRowView(session: session)
                    }
                }
                .scrollContentBackground(.hidden)
                .listStyle(.plain)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradientView()
                .ignoresSafeArea()
        )
    }
}

#Preview {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: PomodoroSession.self, configurations: config)

    // Add sample data to container
    let context = container.mainContext
    PreviewData.generateSessions().forEach { session in
        context.insert(session)
    }

    return SessionHistoryView(isShowing: .constant(true))
        .modelContainer(container)
}
