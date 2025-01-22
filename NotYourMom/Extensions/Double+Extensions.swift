//
//  Double+Extensions.swift
//  NotYourMom
//
//  Created by Gokul P on 1/21/25.
//

import Foundation

extension Double {
    var formattedRemainingTime: String {
        let minutes = Int(self) / 60
        let seconds = Int(self) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
}
