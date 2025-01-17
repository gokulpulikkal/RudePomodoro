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
    private let locationManager = CLLocationManager()
    private var timer: Timer?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.pausesLocationUpdatesAutomatically = true
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
    }

    func startBackgroundLocationTask() {
        locationManager.requestAlwaysAuthorization()
        locationManager.startUpdatingLocation()
    }

    func stopBackgroundTask() {
        locationManager.stopUpdatingLocation()
        timer?.invalidate()
        timer = nil

        // Notify the user that monitoring has stopped
        let content = UNMutableNotificationContent()
        content.title = "Monitoring Stopped"
        content.body = "The background monitoring duration has ended."
        content.sound = .default

        let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: nil)
        UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print("Location updated")
    }
}

