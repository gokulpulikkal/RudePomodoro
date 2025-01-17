//
//  BackgroundTaskManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import Foundation
import CoreLocation
import UserNotifications

class BackgroundTaskManager: NSObject, CLLocationManagerDelegate {
    static let shared = BackgroundTaskManager()
    private let locationManager = LocationManager.shared

    func startBackgroundLocationTask() {
        locationManager.startMonitoring()
    }

    func stopBackgroundTask() {
        locationManager.stopMonitoring()
        // Notify the user that monitoring has stopped
        let content = UNMutableNotificationContent()
        content.title = "Monitoring Stopped"
        content.body = "The background monitoring duration has ended."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }
}

