import Foundation
import CoreLocation

@MainActor
final class LocationService: NSObject, ObservableObject, CLLocationManagerDelegate {
    @Published var location: CLLocation?
    @Published var heading: CLHeading?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var errorMessage: String?
    @Published private(set) var backgroundTrackingEnabled = false

    private let manager = CLLocationManager()
    private var trackLocationHandler: ((CLLocation) -> Void)?

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 1
        manager.headingFilter = 2
        manager.activityType = .fitness
        authorizationStatus = manager.authorizationStatus
    }

    func requestAndStart() {
        if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    /// Starts continuous location updates that are permitted to continue while the
    /// app is in the background or the screen is locked. iOS still controls actual
    /// delivery based on authorization, system policy and whether the user force-quits.
    func beginBackgroundTracking(handler: @escaping (CLLocation) -> Void) {
        trackLocationHandler = handler
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 2
        manager.activityType = .fitness
        manager.pausesLocationUpdatesAutomatically = false
        manager.allowsBackgroundLocationUpdates = true
        manager.showsBackgroundLocationIndicator = true
        backgroundTrackingEnabled = true

        switch manager.authorizationStatus {
        case .notDetermined:
            manager.requestWhenInUseAuthorization()
        case .authorizedWhenInUse:
            manager.requestAlwaysAuthorization()
        case .authorizedAlways:
            break
        default:
            break
        }

        manager.startUpdatingLocation()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
    }

    func requestAlwaysAuthorizationIfPossible() {
        if manager.authorizationStatus == .authorizedWhenInUse {
            manager.requestAlwaysAuthorization()
        } else if manager.authorizationStatus == .notDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }

    func endBackgroundTracking(keepForegroundLocation: Bool = true) {
        trackLocationHandler = nil
        backgroundTrackingEnabled = false
        manager.allowsBackgroundLocationUpdates = false
        manager.pausesLocationUpdatesAutomatically = true
        manager.distanceFilter = 1
        if keepForegroundLocation {
            manager.startUpdatingLocation()
        } else {
            stop()
        }
    }

    func stop() {
        manager.stopUpdatingLocation()
        manager.stopUpdatingHeading()
    }

    nonisolated func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        Task { @MainActor in
            authorizationStatus = manager.authorizationStatus
            if manager.authorizationStatus == .authorizedWhenInUse || manager.authorizationStatus == .authorizedAlways {
                if backgroundTrackingEnabled && manager.authorizationStatus == .authorizedWhenInUse {
                    manager.requestAlwaysAuthorization()
                }
                manager.startUpdatingLocation()
                if CLLocationManager.headingAvailable() { manager.startUpdatingHeading() }
            }
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let latest = locations.last else { return }
        Task { @MainActor in
            location = latest
            trackLocationHandler?(latest)
        }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        guard newHeading.headingAccuracy >= 0 else { return }
        Task { @MainActor in heading = newHeading }
    }

    nonisolated func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        Task { @MainActor in errorMessage = error.localizedDescription }
    }
}
