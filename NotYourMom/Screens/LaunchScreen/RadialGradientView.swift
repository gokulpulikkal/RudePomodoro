//
//  RadialGradientView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import Foundation

import SwiftUI

struct RadialGradientView: View {

    var gradient = Gradient(colors: [
        .clear, .black.opacity(0.5)
    ])

    var body: some View {
        ZStack {
            let size = max(UIScreen.main.bounds.width, UIScreen.main.bounds.height)
            Color(hex: "5E2929")
            Circle()
                .fill(
                    RadialGradient(
                        gradient: gradient,
                        center: .center,
                        startRadius: 1,
                        endRadius: 400
                    )
                )
                .frame(width: size*2, height: size*2)
        }
        .ignoresSafeArea()
    }
}

#Preview {
    RadialGradientView()
}

/// Helper extension to create Color from hex
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
