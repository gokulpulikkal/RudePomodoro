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
                Text("\(position ?? 0)")
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
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 7, height: 30)
                        .offset(x: 2)
                }
                .scrollPosition(id: .init(get: {
                    let position: Int? = isLoaded ? position : nil
                    return position
                }, set: { val in
                    if let val {
                        position = val
                    }
                }))
                .safeAreaPadding(.horizontal, horizontalPadding)
                .background(.yellow)
            }
            .onAppear {
                if !isLoaded {
                    isLoaded = true
                }
            }
        }
    }
}

/// Add custom snapping behavior
/// Snaps to nearest multiple of 5
struct CustomSnappingBehavior: ScrollTargetBehavior {
    func updateTarget(_ target: inout ScrollTarget, context: TargetContext) {
        let itemValue = target.rect.origin.x

        let itemWidth: CGFloat = 15 // Width of item + spacing
        let snapPoint = round(itemValue / (itemWidth * 5)) * (itemWidth * 5)
        target.rect.origin.x = snapPoint
    }
}

// Preview remains the same

#Preview {
    TimePickerView()
}

struct TimerChildView: View {
    let value: Int
    let position: Int?

    var body: some View {
        let reminder = value % 5
        RoundedRectangle(cornerRadius: 5)
            .frame(width: 5, height: reminder != 0 ? 15 : 30, alignment: .center)
            .overlay {
                if reminder == 0 {
                    Text("\(value)")
                        .foregroundStyle(.red)
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

}
