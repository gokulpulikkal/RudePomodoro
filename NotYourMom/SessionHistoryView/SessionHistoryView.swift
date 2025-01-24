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

    var body: some View {
        VStack {
            Text("Session History")
                .font(.sourGummy(.bold, size: 24))
                .foregroundStyle(.white)
                .padding()

            if sessionsList.isEmpty {
                ContentUnavailableView(
                    "No Sessions Yet",
                    systemImage: "clock.badge.xmark",
                    description: Text("Complete your first session to see it here")
                )
                .foregroundStyle(.white)
            } else {
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
