//
//  TimePickerView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import SwiftUI

struct TimePickerView: View {
    @State var position: Int? = 30
    @State var isLoaded: Bool = false
    
    var body: some View {
        GeometryReader { proxy in
            let horizontalPadding = proxy.size.width / 2
            VStack {
                Button("Tap me") {
                    withAnimation {
                        position = 10
                    }
                    
                }
                Text("\(position ?? 0)")
                ScrollView(.horizontal) {
                    HStack(alignment: .top, spacing: 10) {
                        ForEach(0...60, id: \.self) { value in
                            let reminder = value % 5
                            ZStack {
                                RoundedRectangle(cornerRadius: 5)
                                    .frame(width: 5, height: reminder != 0 ? 15 : 30, alignment: .center)
                                    .overlay {
                                        if reminder == 0 {
                                            Text("\(value)")
                                                .foregroundStyle(.red)
                                                .font(.system(size: 30))
                                                .bold()
                                                .offset(y: -35)
                                                .fixedSize()
                                        }
                                    }
                            }
                        }
                    }
                    .frame(height: 200)
                    .scrollTargetLayout()
                }
                .scrollIndicators(.hidden)
                .scrollTargetBehavior(.viewAligned)
                .scrollPosition(id: .init(get: {
                    let position: Int? = isLoaded ? self.position : nil
                    return position
                }, set: { val in
                    if let val {
                        self.position = val
                    }
                }))
                .overlay(alignment: .center) {
                    RoundedRectangle(cornerRadius: 5)
                        .frame(width: 5, height: 30)
                }
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

// Preview remains the same

#Preview {
    TimePickerView()
}
