//
//  NotYourMomApp.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//
import RevenueCat
import RevenueCatUI
import SwiftData
import SwiftUI

@main
struct NotYourMomApp: App {

    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    let container: ModelContainer
    @State private var purchaseManager: PurchaseManager = PurchaseManager()

    init() {
        do {
            self.container = try ModelContainer(for: PomodoroSession.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        setUPRevenueCat()
    }

    private func setUPRevenueCat() {
        Purchases.logLevel = .debug
        Purchases.configure(withAPIKey: "appl_xMElYuadfMMrEHjMsuJdLoCfSDd")
    }

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
                .environment(purchaseManager)
                .presentPaywallIfNeeded(
                    requiredEntitlementIdentifier: "Pro",
                    purchaseCompleted: { customerInfo in
                        purchaseManager.isEntitled = customerInfo.entitlements.active.keys.contains("Pro")
                        print("The user now is entitled \(purchaseManager.isEntitled)")
                    },
                    restoreCompleted: { customerInfo in
                        purchaseManager.isEntitled = customerInfo.entitlements.active.keys.contains("Pro")
                        print("The user now is entitled \(purchaseManager.isEntitled)")
                    }
                    
                )
                .task {
                    await checkEntitlement()
                }
        }
        .modelContainer(container)
    }

    func checkEntitlement() async {
        do {
            let customerInfo = try await Purchases.shared.customerInfo()
            purchaseManager.isEntitled = customerInfo.entitlements.active.keys.contains("Pro")
            print("checkEntitlement The user is entitled \(purchaseManager.isEntitled)")
        } catch {
            print("Error in getting entitlement details")
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, @preconcurrency UNUserNotificationCenterDelegate {
    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Specify how you want to present the notification when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
