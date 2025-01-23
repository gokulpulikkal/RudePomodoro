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
                ZStack {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(lineWidth: 5)
                        .fill(Color(hex: "5E2929"))
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)

                    TypewriterView(text: viewModel.pomoMessage, typingDelay: .milliseconds(15))
                        .multilineTextAlignment(.center)
//                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .font(.sourGummy(.medium, size: 20))
                        .foregroundStyle(.white)
                        .padding(5)
                }
                .frame(width: 300, height: 100)
                Spacer()
            }
            .padding(.top)
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
            Text(viewModel.currentSymbol)
                .font(.sourGummy(.regular, size: 20))
                .bold()
                .foregroundStyle(.white)
        })
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25))
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
