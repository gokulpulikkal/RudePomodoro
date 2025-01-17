//
//  LocationManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/17/25.
//

import Foundation
import CoreLocation

class LocationManager: NSObject, CLLocationManagerDelegate {
    static let shared = LocationManager()
    private let locationManager = CLLocationManager()

    override init() {
        super.init()
        setupLocationManager()
    }

    private func setupLocationManager() {
        locationManager.delegate = self
        // Use significant location changes for better battery life
        locationManager.desiredAccuracy = kCLLocationAccuracyReduced
        locationManager.allowsBackgroundLocationUpdates = true
        locationManager.showsBackgroundLocationIndicator = true // Changed to true for transparency
        locationManager.pausesLocationUpdatesAutomatically = false
    }

    func startMonitoring() {
        // Request authorization first
        locationManager.requestAlwaysAuthorization()
        // Use significant location changes instead
        locationManager.startMonitoringSignificantLocationChanges()
    }

    func stopMonitoring() {
        locationManager.stopMonitoringSignificantLocationChanges()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .authorizedAlways:
            print("✅ Location permission granted")
            // Start significant location changes
            locationManager.startMonitoringSignificantLocationChanges()
        default:
            print("❌ Location permission not granted")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Keep the location service alive
        print("📍 Location update received")
    }
}
