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
    private let columns = [
        GridItem(.adaptive(minimum: 360, maximum: 360), spacing: 50)
    ]

    var body: some View {
        VStack(spacing: 0) {
            navBar
            if sessionsList.isEmpty {
                noHistoryView
            } else {
                WeeklyStatsView(viewModel: WeeklyStatsView.ViewModel(sessions: sessionsList))
                    .padding([.horizontal, .bottom])
                    .frame(maxWidth: 900)
                sessionHistoryList
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradientView()
                .ignoresSafeArea()
        )
    }
}

extension SessionHistoryView {
    var navBar: some View {
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
    }

    var noHistoryView: some View {
        ContentUnavailableView(
            "No Sessions Yet",
            systemImage: "clock.badge.xmark",
            description: Text("Complete your first session to see it here")
        )
        .foregroundStyle(.white)
    }

    var sessionHistoryList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                Section {
                    // Here goes the items
                    ForEach(sessionsList) { session in
                        SessionRowView(session: session)
                    }
                }
            }
        }
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
