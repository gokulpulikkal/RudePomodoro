import Foundation
import SwiftData

@Model
class PomodoroSession {
    var startDate: Date
    var duration: TimeInterval
    var wasCompleted: Bool
    
    init(startDate: Date, duration: TimeInterval, wasCompleted: Bool) {
        self.startDate = startDate
        self.duration = duration
        self.wasCompleted = wasCompleted
    }
    
    var formattedDuration: String {
        let minutes = Int(duration / 60)
        return "\(minutes) min"
    }
    
    var formattedDate: String {
        startDate.formatted(date: .abbreviated, time: .shortened)
    }
} 
