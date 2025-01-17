//
//  NotYourMomApp.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

// Your imports remain the same
import SwiftUI
import UserNotifications
import CoreLocation

@main
struct NotYourMomApp: App {
    
    init() {
        requestNotificationPermission()
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .criticalAlert, .sound]) { granted, error in
            if granted {
                print("Notification permission granted")
            } else if let error {
                print("Error requesting notification permission: \(error.localizedDescription)")
            }
        }
    }
}
