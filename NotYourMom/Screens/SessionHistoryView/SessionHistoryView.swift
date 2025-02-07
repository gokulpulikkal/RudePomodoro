//
//  SessionHistoryView.swift
//  NotYourMom
//
//  Created by Gokul P on 1/24/25.
//

import Foundation
import RevenueCat
import RevenueCatUI
import SwiftData
import SwiftUI

struct SessionHistoryView: View {

    @Query(sort: \PomodoroSession.startDate, order: .reverse) var sessionsList: [PomodoroSession]
    @Environment(PurchaseManager.self) var purchaseManager: PurchaseManager
    @Binding var isShowing: Bool

    private let columns = [
        GridItem(.adaptive(minimum: 360, maximum: 360), spacing: 50)
    ]

    @State var viewModel = ViewModel()

    var body: some View {
        VStack(spacing: 0) {
            navBar
            if purchaseManager.isEntitled {
                if sessionsList.isEmpty {
                    noHistoryView
                } else {
                    WeeklyStatsView(weeklyStatsHelper: WeeklyStatsHelper(sessions: sessionsList))
                        .padding([.horizontal, .bottom])
                        .frame(maxWidth: 900)
                    sessionHistoryList
                }
            } else {
                WeeklyStatsView(weeklyStatsHelper: WeeklyStatsHelper(sessions: viewModel.dummyChartItems))
                    .padding([.horizontal, .bottom])
                    .frame(maxWidth: 900)
                sessionHistoryList
            }
        }
        .overlay {
            bottomSnackBarForPremium
                .opacity(purchaseManager.isEntitled ? 0 : 1)
                .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(
            RadialGradientView()
                .ignoresSafeArea()
        )
        .sheet(isPresented: $viewModel.displayPaywall, onDismiss: {
            Task {
                do {
                    let customerInfo = try await Purchases.shared.customerInfo()
                    purchaseManager.isEntitled = customerInfo.entitlements.active.keys.contains("Pro")
                    print("The user now is entitled \(purchaseManager.isEntitled)")
                } catch {
                    print(error.localizedDescription)
                }
            }
        }) {
            PaywallView(displayCloseButton: true)
        }
    }
}

extension SessionHistoryView {
    var navBar: some View {
        ZStack {
            Text("Session History")
                .font(.sourGummy(.bold, size: 24))
                .foregroundStyle(.white)
                .padding(.vertical)
            HStack {
                Button(action: {
                    UIImpactFeedbackGenerator(style: .light).impactOccurred()
                    withAnimation {
                        isShowing = false
                    }
                }, label: {
                    Image(systemName: "multiply.circle.fill")
                        .font(.system(size: 20))
                        .foregroundStyle(.white)
                })
                Spacer()
            }
            .padding()
        }
    }

    var noHistoryView: some View {
        ContentUnavailableView(
            "No Sessions Yet",
            systemImage: "clock.badge.xmark",
            description: Text("Complete your first session to see it here")
        )
        .foregroundStyle(.white)
    }

    var sessionHistoryList: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 18) {
                Section {
                    // Here goes the items
                    ForEach(!purchaseManager.isEntitled ? viewModel.dummyChartItems : sessionsList) { session in
                        SessionRowView(session: session)
                    }
                }
            }
        }
    }

    var bottomSnackBarForPremium: some View {
        VStack {
            Spacer()
            HStack(spacing: 20) {
                Text("This is demo chart, subscribe to unlock this feature")
                    .font(.sourGummy(.regular, size: 14))
                Button(action: {
                    viewModel.displayPaywall = true
                }, label: {
                    Text("Subscribe")
                        .font(.sourGummy(.regular, size: 16))
                        .bold()
                        .foregroundStyle(.white)
                })
                .padding()
                .background(.thinMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 25))
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 10).fill(Color(hex: "#CB5042")))
        }
    }
}

#Preview {
    SessionHistoryView(isShowing: .constant(true))
        .environment(PurchaseManager())
}
