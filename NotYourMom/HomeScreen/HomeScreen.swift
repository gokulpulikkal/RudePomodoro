//
//  HomeScreen.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import RiveRuntime
import SwiftUI

struct HomeScreen: View {
    @State var viewModel = ViewModel()

    let rivAnimModel = RiveViewModel(fileName: "pomodoro_app_mob", stateMachineName: "State Machine")

    var body: some View {
        ZStack {
            rivAnimation
            timerText
                .padding(.top, 300)
            actionButton
        }
        .animation(.snappy, value: viewModel.remainingTime)
    }
}

extension HomeScreen {
    var rivAnimation: some View {
        rivAnimModel.view()
            .ignoresSafeArea()
            .aspectRatio(contentMode: .fill)
            .offset(x: -50)
            .ignoresSafeArea()
    }

    var timerText: some View {
        Text(viewModel.formattedRemainingTime)
            .font(.system(size: 60, weight: .bold, design: .monospaced))
            .foregroundStyle(.white)
            .contentTransition(.numericText())
    }

    var actionButton: some View {
        VStack {
            Spacer()
            Button(action: {
                handleActionButtons()
            }, label: {
                Circle()
                    .fill(Color.red.opacity(0.9))
                    .frame(width: 60, height: 60)
                    .overlay(
                        Image(systemName: viewModel.currentSymbol)
                            .font(.system(size: 30))
                            .foregroundColor(.white)
                            .offset(x: viewModel.currentSymbol == "play.fill" ? 2 : 0)
                            .bold()
                            .contentTransition(.symbolEffect(.replace.downUp))
                    )
            })
            .buttonStyle(.plain)
            Spacer()
                .frame(height: 100)
        }
    }

    func handleActionButtons() {
        Task {
            switch viewModel.currentState {
            case .idle:
                if await viewModel.startMonitoring() {
                    rivAnimModel.triggerInput("start")
                }
            case .running:
                await viewModel.stopMonitoring()
                rivAnimModel.triggerInput("stop")
            case .stopped:
                viewModel.setInitialValues()
                rivAnimModel.triggerInput("reset")
            case .finished:
                viewModel.setInitialValues()
                rivAnimModel.triggerInput("reset")
            }
        }
    }
}

#Preview {
    HomeScreen()
}
