//
//  SessionHistoryManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/24/25.
//

import Foundation
import SwiftData
import SwiftUI

@Observable
class SessionHistoryManager {

    /// Whatever fetching or inserting thing on this model context should happen on the Main actor
    private weak var modelContext: ModelContext?
    

    func setModelContext(_ context: ModelContext) {
        modelContext = context
    }

    @MainActor
    func fetchSessions() async -> [PomodoroSession] {
        guard let modelContext else {
            return []
        }

        let descriptor = FetchDescriptor<PomodoroSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )

        do {
            return try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch sessions: \(error)")
            return []
        }
    }

    @MainActor
    func addSession(_ session: PomodoroSession) async {
        guard let modelContext else {
            return
        }

        modelContext.insert(session)
        do {
            try modelContext.save()
            await fetchSessions()
        } catch {
            print("Failed to save session: \(error)")
        }
    }
}
