//
//  BackgroundTaskManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/16/25.
//

import CoreLocation
import Foundation
import UserNotifications

class BackgroundTaskManager: NSObject, CLLocationManagerDelegate {
    static let shared = BackgroundTaskManager()
    private let locationManager = LocationManager.shared

    func startBackgroundLocationTask() {
        locationManager.startMonitoring()
    }

    func stopBackgroundTask() {
        locationManager.stopMonitoring()
    }
}
