import Foundation
import CoreLocation
import UserNotifications

class LocationManager: NSObject, ObservableObject {

    // Paris city center and approximate radius (~10 km covers central Paris)
    static let parisCenter = CLLocationCoordinate2D(latitude: 48.8566, longitude: 2.3522)
    static let parisRadiusMeters: CLLocationDistance = 10_000
    static let regionIdentifier = "paris-geofence"

    @Published var isInParis = false
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var lastLocation: CLLocation?
    @Published var monitoringActive = false

    private var manager: CLLocationManager?

    override init() {
        super.init()
        let mgr = CLLocationManager()
        mgr.delegate = self
        mgr.desiredAccuracy = kCLLocationAccuracyHundredMeters
        mgr.allowsBackgroundLocationUpdates = true
        mgr.pausesLocationUpdatesAutomatically = false
        manager = mgr
        authorizationStatus = mgr.authorizationStatus
    }

    /// Preview-only initializer — does not create a real CLLocationManager.
    init(
        isInParis: Bool,
        authorizationStatus: CLAuthorizationStatus,
        lastLocation: CLLocation?,
        monitoringActive: Bool
    ) {
        super.init()
        self.isInParis = isInParis
        self.authorizationStatus = authorizationStatus
        self.lastLocation = lastLocation
        self.monitoringActive = monitoringActive
    }

    // MARK: - Public API

    func requestPermission() {
        manager?.requestAlwaysAuthorization()
        requestNotificationPermission()
    }

    func startMonitoring() {
        let region = CLCircularRegion(
            center: Self.parisCenter,
            radius: Self.parisRadiusMeters,
            identifier: Self.regionIdentifier
        )
        region.notifyOnEntry = true
        region.notifyOnExit = true

        manager?.startMonitoring(for: region)
        manager?.startUpdatingLocation()
        monitoringActive = true
    }

    func stopMonitoring() {
        if let manager {
            for region in manager.monitoredRegions {
                manager.stopMonitoring(for: region)
            }
            manager.stopUpdatingLocation()
        }
        monitoringActive = false
    }

    func checkCurrentLocation() {
        manager?.requestLocation()
    }

    // MARK: - Notifications

    private func requestNotificationPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { _, _ in }
    }

    private func sendNotification(title: String, body: String) {
        let content = UNMutableNotificationContent()
        content.title = title
        content.body = body
        content.sound = .default

        let request = UNNotificationRequest(
            identifier: UUID().uuidString,
            content: content,
            trigger: nil
        )
        UNUserNotificationCenter.current().add(request)
    }

    // MARK: - Helpers

    private func updateParisStatus(for location: CLLocation) {
        let parisLocation = CLLocation(
            latitude: Self.parisCenter.latitude,
            longitude: Self.parisCenter.longitude
        )
        let distance = location.distance(from: parisLocation)
        let wasInParis = isInParis
        isInParis = distance <= Self.parisRadiusMeters

        if isInParis && !wasInParis {
            sendNotification(
                title: "Bienvenue à Paris! 🇫🇷",
                body: "Du befinner dig nu i Paris."
            )
        } else if !isInParis && wasInParis {
            sendNotification(
                title: "Au revoir Paris!",
                body: "Du har lämnat Paris."
            )
        }
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        lastLocation = location
        updateParisStatus(for: location)
    }

    func locationManager(_ manager: CLLocationManager, didEnterRegion region: CLRegion) {
        guard region.identifier == Self.regionIdentifier else { return }
        isInParis = true
        sendNotification(
            title: "Bienvenue à Paris! 🇫🇷",
            body: "Du befinner dig nu i Paris."
        )
    }

    func locationManager(_ manager: CLLocationManager, didExitRegion region: CLRegion) {
        guard region.identifier == Self.regionIdentifier else { return }
        isInParis = false
        sendNotification(
            title: "Au revoir Paris!",
            body: "Du har lämnat Paris."
        )
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedAlways || authorizationStatus == .authorizedWhenInUse {
            startMonitoring()
        }
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Location error: \(error.localizedDescription)")
    }

    func locationManager(_ manager: CLLocationManager, monitoringDidFailFor region: CLRegion?, withError error: Error) {
        print("Region monitoring error: \(error.localizedDescription)")
    }
}
