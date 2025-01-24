import Foundation
import SwiftData
import SwiftUI

@Observable
class SessionHistoryViewModel {
    private weak var modelContext: ModelContext?
    var sessions: [PomodoroSession] = []
    
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
        Task {
            await fetchSessions()
        }
    }
    
    @MainActor
    func fetchSessions() async {
        guard let modelContext else { return }
        
        let descriptor = FetchDescriptor<PomodoroSession>(
            sortBy: [SortDescriptor(\.startDate, order: .reverse)]
        )
        
        do {
            sessions = try modelContext.fetch(descriptor)
        } catch {
            print("Failed to fetch sessions: \(error)")
            sessions = []
        }
    }
    
    @MainActor
    func addSession(_ session: PomodoroSession) async {
        guard let modelContext else { return }
        
        modelContext.insert(session)
        do {
            try modelContext.save()
            await fetchSessions()
        } catch {
            print("Failed to save session: \(error)")
        }
    }
} 
