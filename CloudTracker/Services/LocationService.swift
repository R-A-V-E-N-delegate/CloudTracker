import Foundation
import CoreLocation

/// Service for managing location access and geocoding
@MainActor
class LocationService: NSObject, ObservableObject {
    static let shared = LocationService()

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var locationName: String?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let locationManager = CLLocationManager()
    private let geocoder = CLGeocoder()

    private var locationContinuation: CheckedContinuation<CLLocation?, Never>?

    override init() {
        super.init()
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        authorizationStatus = locationManager.authorizationStatus
    }

    // MARK: - Public Methods

    /// Request location permissions
    func requestPermission() {
        locationManager.requestWhenInUseAuthorization()
    }

    /// Get the current location
    func getCurrentLocation() async -> CLLocation? {
        isLoading = true
        errorMessage = nil

        // Check authorization
        switch authorizationStatus {
        case .notDetermined:
            requestPermission()
            // Wait briefly for user response
            try? await Task.sleep(nanoseconds: 500_000_000)
            if authorizationStatus == .notDetermined {
                isLoading = false
                return nil
            }
        case .denied, .restricted:
            errorMessage = "Location access denied"
            isLoading = false
            return nil
        default:
            break
        }

        // Request location
        return await withCheckedContinuation { continuation in
            self.locationContinuation = continuation
            locationManager.requestLocation()
        }
    }

    /// Get a readable location name from coordinates
    func getLocationName(latitude: Double, longitude: Double) async -> String? {
        let location = CLLocation(latitude: latitude, longitude: longitude)

        do {
            let placemarks = try await geocoder.reverseGeocodeLocation(location)
            if let placemark = placemarks.first {
                return formatPlacemark(placemark)
            }
        } catch {
            print("Geocoding error: \(error.localizedDescription)")
        }

        return nil
    }

    // MARK: - Private Methods

    private func formatPlacemark(_ placemark: CLPlacemark) -> String {
        var components: [String] = []

        if let locality = placemark.locality {
            components.append(locality)
        }

        if let administrativeArea = placemark.administrativeArea {
            components.append(administrativeArea)
        }

        if components.isEmpty, let country = placemark.country {
            components.append(country)
        }

        return components.joined(separator: ", ")
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationService: CLLocationManagerDelegate {
    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        Task { @MainActor in
            let location = locations.last
            self.currentLocation = location
            self.isLoading = false

            if let location = location {
                self.locationName = await getLocationName(
                    latitude: location.coordinate.latitude,
                    longitude: location.coordinate.longitude
                )
            }

            locationContinuation?.resume(returning: location)
            locationContinuation = nil
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in
            self.errorMessage = error.localizedDescription
            self.isLoading = false
            locationContinuation?.resume(returning: nil)
            locationContinuation = nil
        }
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            self.authorizationStatus = manager.authorizationStatus
        }
    }
}
