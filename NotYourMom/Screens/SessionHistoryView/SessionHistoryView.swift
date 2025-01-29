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
        .overlay {
            bottomSnackBarForPremium
                .opacity(1)
                .padding()
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
                    Image(systemName: "multiply.circle.fill")
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

    var bottomSnackBarForPremium: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                Text("This is demo chart, subscribe to unlock this feature")
                    .font(.sourGummy(.regular, size: 14))
                Button(action: {}, label: {
                    Text("Try Free")
                        .font(.sourGummy(.regular, size: 16))
                        .bold()
                        .foregroundStyle(.white)
                })
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#CB5042")))
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
