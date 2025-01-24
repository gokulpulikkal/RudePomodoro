//
//  LaunchScreen.swift
//  NotYourMom
//
//  Created by Gokul P on 1/19/25.
//

import SwiftUI

struct LaunchScreen: View {
    @State var isLoading = true
    var body: some View {
        ZStack {
            if isLoading {
                ZStack {
                    RadialGradientView()
                    Text("Rude Pomo")
                        .foregroundStyle(.white)
                        .font(.sourGummy(.bold, size: 50))
                }
                    .transition(.opacity)
                    .task {
                        do {
                            try await Task.sleep(for: .seconds(1))
                            
                            isLoading = false
                        } catch {
                            print("Error in starting the app")
                        }

                    }
            } else {
                HomeScreen()
                    .transition(.opacity)
            }
        }
        .animation(.snappy, value: isLoading)
    }
}

#Preview {
    LaunchScreen()
}
