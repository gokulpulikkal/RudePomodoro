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
            VStack {
                timerText
                    .onTapGesture {
                        withAnimation(.easeInOut) {
                            if viewModel.currentState == .idle {
                                viewModel.isTimerEditing = true
                            }
                        }
                    }
                actionButton
            }
            .padding(.top, 330)
            .opacity(viewModel.isTimerEditing ? 0 : 1)
            .offset(x: viewModel.isTimerEditing ? -UIScreen.main.bounds.width : 0)

            timeSelectorView
                .padding(.top, 330)
                .opacity(viewModel.isTimerEditing ? 1 : 0)
                .offset(x: viewModel.isTimerEditing ? 0 : UIScreen.main.bounds.width)
        }
        .animation(.snappy, value: viewModel.remainingTime)
        .animation(.easeInOut, value: viewModel.isTimerEditing)
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
    }

    var timeSelectorView: some View {
        VStack(spacing: 30) {
            TimePickerView(position: $viewModel.timerTime)
                .frame(height: 150)
            Button(action: {
                viewModel.isTimerEditing = false
                Task { @MainActor in
                    await viewModel.setSelectedDuration()
                }
            }, label: {
                Text("Done")
                    .font(.system(size: 20))
                    .bold()
                    .foregroundStyle(.white)
            })
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
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
                await viewModel.setInitialValues()
                rivAnimModel.triggerInput("reset")
            case .finished:
                await viewModel.setInitialValues()
                rivAnimModel.triggerInput("reset")
            }
        }
    }
}

#Preview {
    HomeScreen()
}
