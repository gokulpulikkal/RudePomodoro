//
//  TimePickerView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import SwiftUI

struct TimePickerView: View {
    @State var position: Int? = 10
    @State var snappingPosition: Int? = 10
    @State var isLoaded = false

    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = proxy.size.width / 2
            VStack {
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(0...60, id: \.self) { value in
                            TimerChildView(value: value, position: position)
                        }
                    }
                    .frame(height: 200)
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(CustomSnappingBehavior())
                .overlay(alignment: .center) {
                    VStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 5)
                            .frame(width: 7, height: 30)
                        Circle()
                            .frame(width: 15, height: 15)
                            .foregroundStyle(.white)
                    }
                    .foregroundStyle(.white)
                    .offset(x: 2, y: 15)
                }
                .scrollPosition(id: .init(get: {
                    let position: Int? = isLoaded ? position : nil
                    return position
                }, set: { val in
                    if let val {
                        position = val
                        UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    }
                }))
                .safeAreaPadding(.horizontal, horizontalPadding)
            }
            .onAppear {
                if !isLoaded {
                    isLoaded = true
                }
            }
        }
    }
}

// Preview remains the same

#Preview {
    TimePickerView()
        .background(.blue)
}
