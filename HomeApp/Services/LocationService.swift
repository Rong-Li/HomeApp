//
//  LocationService.swift
//  HomeApp
//
//  Family Expense Tracker - Location Services
//

import CoreLocation

@MainActor
final class LocationService: NSObject, CLLocationManagerDelegate {
    static let shared = LocationService()
    
    private let manager = CLLocationManager()
    private let geocoder = CLGeocoder()
    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?
    
    private override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyKilometer
    }
    
    /// Requests location permission. Call this when the expense logger view appears.
    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }
    
    /// Fetches the user's postal code with ~1km accuracy.
    /// Returns nil if permission denied, location unavailable, or geocoding fails.
    func fetchPostalCode() async -> String? {
        // Check authorization
        let status = manager.authorizationStatus
        guard status == .authorizedWhenInUse || status == .authorizedAlways else {
            return nil
        }
        
        // Get location with timeout
        let location = await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            manager.requestLocation()
            
            // Timeout after 5 seconds
            Task {
                try? await Task.sleep(for: .seconds(5))
                if self.locationContinuation != nil {
                    self.locationContinuation?.resume(returning: nil)
                    self.locationContinuation = nil
                }
            }
        }
        
        guard let location else { return nil }
        
        // Reverse geocode
        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            return placemarks.first?.postalCode
        } catch {
            return nil
        }
    }
    
    // MARK: - CLLocationManagerDelegate
    
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            guard let location = locations.first else { return }
            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }
    
    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
        }
    }
}
