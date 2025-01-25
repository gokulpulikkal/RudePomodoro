//
//  SessionRowView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/24/25.
//

import Foundation
import SwiftUI

struct SessionRowView: View {
    let session: PomodoroSession

    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(session.formattedDate)
                    .font(.sourGummy(.regular, size: 16))
                Text(session.formattedDuration)
                    .font(.sourGummy(.medium, size: 14))
                    .foregroundStyle(.secondary)
            }

            Spacer()

            Image(systemName: session.wasCompleted ? "checkmark.circle.fill" : "xmark.circle.fill")
                .foregroundStyle(session.wasCompleted ? Color(hex: "#3B6B2B") : Color(hex: "#CB5042"))
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .foregroundStyle(.white)
    }
}

#Preview {}
