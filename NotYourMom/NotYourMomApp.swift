//
//  NotYourMomApp.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//
import SwiftData
import SwiftUI

@main
struct NotYourMomApp: App {
    @UIApplicationDelegateAdaptor private var appDelegate: AppDelegate
    let container: ModelContainer

    init() {
        do {
            self.container = try ModelContainer(for: PomodoroSession.self)
        } catch {
            fatalError("Failed to initialize ModelContainer: \(error)")
        }
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            LaunchScreen()
        }
        .modelContainer(container)
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [
            .alert,
            .criticalAlert,
            .sound
        ]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
}

class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {
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
