//
//  LocationManager.swift
//  NotYourMom
//
//  Created by Gokul P on 1/17/25.
//

import CoreLocation
import Foundation

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
        locationManager.showsBackgroundLocationIndicator = true
    }

    func startMonitoring() {
        // Request authorization first
        locationManager.requestWhenInUseAuthorization()
        // Use significant location changes instead
        locationManager.startUpdatingLocation()
    }

    func stopMonitoring() {
        locationManager.stopUpdatingLocation()
    }

    // MARK: - CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        switch manager.authorizationStatus {
        case .notDetermined, .authorizedWhenInUse:
            print("✅ Location permission granted")
            locationManager.requestAlwaysAuthorization()
        default:
            print("❌ Location permission not granted")
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        // Keep the location service alive
        print("📍 Location update received")
    }
}
