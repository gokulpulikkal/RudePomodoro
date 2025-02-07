//
//  SessionHistoryView+ViewModel.swift
//  NotYourMom
//
//  Created by Gokul P on 2/4/25.
//

import Foundation
import Observation

extension SessionHistoryView {

    @Observable
    class ViewModel {
        
        var displayPaywall = false

        var dummyChartItems: [PomodoroSession]
        
        init() {
            dummyChartItems = PreviewData.generateSessions()
        }
    }

}
