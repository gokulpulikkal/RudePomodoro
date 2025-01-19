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
                            let reminder = value % 5
                            RoundedRectangle(cornerRadius: 5)
                                .frame(width: 5, height: reminder != 0 ? 15 : 30, alignment: .center)
                                .overlay {
                                    if reminder == 0 {
                                        GeometryReader { geo in
                                            let midX = geo.frame(in: .global)
                                                .midX
                                            let screenMidX = UIScreen.main
                                                .bounds.width / 2
                                            let distance =
                                                abs(midX - screenMidX)
                                            let scale = max(
                                                1.3 - (distance / 200),
                                                0.7
                                            )

                                            Text("\(value)")
                                                .foregroundStyle(.red)
                                                .font(.system(size: 30))
                                                .bold()
                                                .fixedSize()
                                                .scaleEffect(scale)
                                                .frame(width: 50, height: 50)
                                                .offset(y: -45)
                                        }
                                        .frame(width: 50)
                                    }
                                }
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
                        print("The closest lower snap point is \(val.findNearestMultipleOf5Lower())")
                        print("The closest upper snap point is \(val.findNearestMultipleOf5Lower())")
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

extension Int {
    func findNearestMultipleOf5Lower() -> Int {
        // Get the remainder when divided by 5
        let remainder = self % 5
        
        // Find the two closest multiples of 5
        let lowerMultiple = self - remainder
        let upperMultiple = lowerMultiple + 5
        
        // Compare which multiple is closer
        // If remainder is less than or equal to 2.5, round down
        // Otherwise round up
        return remainder <= 2 ? lowerMultiple : upperMultiple
    }
    
    func findNearestMultipleOf5Upper() -> Int {
        // Get the remainder when divided by 5
        let remainder = self % 5
        
        // Find the two closest multiples of 5
        let lowerMultiple = self - remainder
        let upperMultiple = lowerMultiple + 5
        
        // Compare which multiple is closer
        // If remainder is less than or equal to 2.5, round down
        // Otherwise round up
        return remainder <= 2 ? upperMultiple: lowerMultiple
    }
}
