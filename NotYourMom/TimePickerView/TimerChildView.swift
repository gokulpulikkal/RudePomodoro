//
//  TimerChildView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import SwiftUI

@MainActor
struct TimerChildView: View {
    let value: Int
    let position: Int?

    var body: some View {
        let reminder = value % 5
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 5, height: reminder != 0 ? 15 : 30, alignment: .center)
            .foregroundStyle(.gray)
            .overlay {
                if reminder == 0 {
                    Text("\(value)")
                        .foregroundStyle(getColor(value: value, currentPosition: position))
                        .font(.system(size: 30))
                        .bold()
                        .scaleEffect(getScale(value: value, currentPosition: position))
                        .fixedSize()
                        .frame(width: 50, height: 50)
                        .offset(y: -45)
                }
            }
            .animation(.snappy, value: position)
    }

    func getScale(value: Int, currentPosition: Int?) -> CGSize {
        guard let currentPosition else {
            return CGSize(width: 1, height: 1)
        }
        let diff = abs(currentPosition - value)
        if diff >= 5 {
            return CGSize(width: 1, height: 1)
        }
        let scale: Double = 1 + (Double(5 - diff) / 10)
        return CGSize(width: scale, height: scale)
    }

    func getColor(value: Int, currentPosition: Int?) -> Color {
        guard let currentPosition else {
            return .gray
        }
        let diff = abs(currentPosition - value)
        if diff >= 5 {
            return .gray
        }
        // Calculate progress from 0.0 (gray) to 1.0 (white)
        let progress = Double(5 - diff) / 5.0

        // Interpolate between gray (0.5) and white (1.0)
        return Color(
            red: 0.5 + (1.0 - 0.5) * progress,
            green: 0.5 + (1.0 - 0.5) * progress,
            blue: 0.5 + (1.0 - 0.5) * progress
        )
    }

}

#Preview {
    TimerChildView(value: 10, position: 20)
}
