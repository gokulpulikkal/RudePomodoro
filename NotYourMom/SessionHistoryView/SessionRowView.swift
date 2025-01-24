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
                .foregroundStyle(session.wasCompleted ? .green : .red)
        }
        .padding(.vertical, 8)
        .listRowBackground(Color.clear)
        .foregroundStyle(.white)
    }
}

#Preview {}
