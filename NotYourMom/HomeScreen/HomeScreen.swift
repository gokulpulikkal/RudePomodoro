//
//  HomeScreen.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import ActivityKit
import RiveRuntime
import SwiftUI

@MainActor
struct HomeScreen: View {
    @State var viewModel = ViewModel()

    let rivAnimModel = RiveViewModel(fileName: "pomoNoBG", stateMachineName: "State Machine")

    var body: some View {
        ZStack {
            VStack {
                rivAnimation
                    .frame(width: 300, height: 300)
                ZStack {
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
                    .opacity(viewModel.isTimerEditing ? 0 : 1)
                    .offset(x: viewModel.isTimerEditing ? -UIScreen.main.bounds.width : 0)
                    timeSelectorView
                        .opacity(viewModel.isTimerEditing ? 1 : 0)
                        .offset(x: viewModel.isTimerEditing ? 0 : UIScreen.main.bounds.width)
                }
            }
            musicToggle
                .disabled(viewModel.currentState != .running)
        }
        .background(
            RadialGradientView()
                .ignoresSafeArea()
        )
        .animation(.snappy, value: viewModel.remainingTime)
        .animation(.easeInOut, value: viewModel.isTimerEditing)
        .onChange(of: viewModel.currentState) {
            handleAnimationStates()
        }
    }
}

extension HomeScreen {
    var rivAnimation: some View {
        rivAnimModel.view()
            .aspectRatio(contentMode: .fit)
    }

    var timerText: some View {
        Text(viewModel.remainingTime.formattedRemainingTime)
            .font(.sourGummy(.bold, size: 60))
            .foregroundStyle(.white)
            .contentTransition(viewModel.currentState != .running ? .identity : .numericText())
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
                viewModel.setSelectedDuration()
            }, label: {
                Text("Done")
                    .font(.sourGummy(.regular, size: 20))
                    .bold()
                    .foregroundStyle(.white)
            })
            .padding()
            .background(.thinMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 25))
        }
    }

    var musicToggle: some View {
        VStack {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    viewModel.toggleAudioMute()
                }, label: {
                    Image(systemName: viewModel.isMute ? "speaker.slash" : "speaker")
                        .font(.system(size: 30))
                        .frame(width: 30, height: 30, alignment: .center)
                        .contentTransition(.symbolEffect(.replace))
                })
                .buttonStyle(.plain)
                .foregroundStyle(.white)
            }
            .padding()
        }
    }

    func handleActionButtons() {
        Task { @MainActor in
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

    func handleAnimationStates() {
        Task { @MainActor in
            switch viewModel.currentState {
            case .finished:
                print("Calling the finish!!")
                rivAnimModel.triggerInput("finish")
            default:
                print("No need of handling! for the state \(viewModel.currentState)")
            }
        }
    }
}

#Preview {
    HomeScreen()
}
