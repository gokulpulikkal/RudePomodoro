//
//  HomeScreen.swift
//  NotYourMom
//
//  Created by Gokul P on 1/18/25.
//

import ActivityKit
import RiveRuntime
import SwiftData
import SwiftUI

@MainActor
struct HomeScreen: View {
    @Environment(\.modelContext) private var modelContext
    @State private var showingHistory = false
    @State private var viewModel = ViewModel()

    var body: some View {
        ZStack {
            ZStack {
                VStack {
                    infoText
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
                            skipBreakButton
                                .opacity(viewModel.showSkipButton() ? 1 : 0)
                        }
                        .opacity(viewModel.isTimerEditing ? 0 : 1)
                        .offset(x: viewModel.isTimerEditing ? -UIScreen.main.bounds.width : 0)
                        timeSelectorView
                            .opacity(viewModel.isTimerEditing ? 1 : 0)
                            .offset(x: viewModel.isTimerEditing ? 0 : UIScreen.main.bounds.width)
                    }
                }
                featureToggles
            }
            .padding(.vertical)
            .background(
                RadialGradientView()
                    .ignoresSafeArea()
            )
            // Session history view
            SessionHistoryView(isShowing: $showingHistory)
                .opacity(!showingHistory ? 0 : 1)
                .offset(x: showingHistory ? 0 : -UIScreen.main.bounds.width)
        }
        .animation(.snappy, value: viewModel.remainingTime)
        .animation(.easeInOut, value: viewModel.isTimerEditing)
        .gesture(
            DragGesture()
                .onEnded { gesture in
                    let threshold: CGFloat = 50
                    if viewModel.currentState != .running, gesture.translation.width > threshold {
                        withAnimation {
                            showingHistory = true
                        }
                    } else if gesture.translation.width > threshold {
                        withAnimation {
                            showingHistory = false
                        }
                    }
                }
        )
        .onAppear {
            viewModel.setModelContext(modelContext)
        }
    }
}

extension HomeScreen {
    var infoText: some View {
        VStack {
            TypewriterView(text: viewModel.pomoMessage, typingDelay: .milliseconds(15))
                .multilineTextAlignment(.center)
                .frame(maxWidth: 400)
                .font(.sourGummy(.medium, size: 20))
                .foregroundStyle(.white)
                .padding()
                .background {
                    RoundedRectangle(cornerRadius: 15)
                        .stroke(.white, lineWidth: 5)
                        .fill(Color(hex: "5E2929"))
                        .shadow(color: .gray.opacity(0.3), radius: 10, x: 0, y: 5)
                }
        }
        .frame(height: 150)
        .padding(.horizontal)
    }

    var rivAnimation: some View {
        viewModel.rivAnimModel.view()
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
            UIImpactFeedbackGenerator(style: .light).impactOccurred()
            viewModel.onMainActionButtonPress()
        }, label: {
            Text(viewModel.actionButtonText)
                .font(.sourGummy(.regular, size: 20))
                .bold()
                .foregroundStyle(.white)
        })
        .padding()
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 25))
    }

    var skipBreakButton: some View {
        Button(action: {
            viewModel.skipBreak()
        }, label: {
            Text("Skip Break")
                .font(.sourGummy(.regular, size: 16))
                .bold()
                .foregroundStyle(.white)
        })
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(.thinMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }

    var timeSelectorView: some View {
        VStack(spacing: 30) {
            TimePickerView(position: viewModel.isBreakSession ? $viewModel.breakTime : $viewModel.timerTime)
                .frame(height: 150)
            Button(action: {
                viewModel.isTimerEditing = false
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

    var featureToggles: some View {
        VStack {
            Spacer()
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation {
                        showingHistory = true
                    }
                }, label: {
                    Image(systemName: "chart.xyaxis.line")
                        .font(.system(size: 20))
                        .frame(width: 20, height: 20, alignment: .center)
                        .contentTransition(.symbolEffect(.replace))
                })
                Spacer()
                HStack(spacing: 20) {
                    Button(action: {
                        viewModel.toggleAudioMute()
                    }, label: {
                        Image(systemName: viewModel.isMute == true ? "speaker.slash" : "speaker")
                            .font(.system(size: 20))
                            .frame(width: 20, height: 20, alignment: .center)
                            .contentTransition(.symbolEffect(.replace))
                    })
                    Button(action: {
                        viewModel.toggleMotionMonitoring()
                    }, label: {
                        Image(
                            systemName: "iphone.gen3.radiowaves.left.and.right",
                            variableValue: viewModel.isMotionDetectionOn ? 2 : 0
                        )
                        .font(.system(size: 20))
                        .frame(width: 20, height: 20, alignment: .center)
                    })
                }
                .disabled(!viewModel.showFeatureToggleButtons())
            }
            .buttonStyle(.plain)
            .foregroundStyle(.white)
            .padding(30)
        }
    }
}

struct HomeScreen_Preview: PreviewProvider {
    static var previews: some View {
        HomeScreen()
            .modelContainer(for: PomodoroSession.self)
            .environment(PurchaseManager())
    }
}
