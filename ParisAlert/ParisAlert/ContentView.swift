import SwiftUI
import CoreLocation

struct ContentView: View {
    @EnvironmentObject var locationManager: LocationManager

    var body: some View {
        ZStack {
            backgroundGradient
            mainContent
        }
    }

    // MARK: - Background

    private var backgroundGradient: some View {
        LinearGradient(
            colors: locationManager.isInParis
                ? [Color.blue, Color.white, Color.red]   // French tricolore
                : [Color(.systemBackground), Color(.systemGray6)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
        .ignoresSafeArea()
    }

    // MARK: - Main Content

    private var mainContent: some View {
        VStack(spacing: 32) {
            Spacer()
            statusIcon
            statusText
            coordinatesView
            Spacer()
            actionButton
            Spacer()
        }
        .padding()
    }

    // MARK: - Status Icon

    private var statusIcon: some View {
        Text(locationManager.isInParis ? "🗼" : "🌍")
            .font(.system(size: 100))
            .shadow(radius: 10)
    }

    // MARK: - Status Text

    private var statusText: some View {
        VStack(spacing: 8) {
            Text(locationManager.isInParis ? "Du är i Paris!" : "Du är inte i Paris")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundStyle(locationManager.isInParis ? .white : .primary)

            Text(statusSubtitle)
                .font(.body)
                .foregroundStyle(locationManager.isInParis ? .white.opacity(0.9) : .secondary)
                .multilineTextAlignment(.center)
        }
    }

    private var statusSubtitle: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Tillåt platstjänster för att börja."
        case .denied, .restricted:
            return "Platstjänster är avstängda. Aktivera dem i Inställningar."
        default:
            if locationManager.monitoringActive {
                return locationManager.isInParis
                    ? "Bienvenue! Appen övervakar din plats."
                    : "Appen meddelar dig när du anländer till Paris."
            }
            return "Tryck på knappen för att starta."
        }
    }

    // MARK: - Coordinates

    @ViewBuilder
    private var coordinatesView: some View {
        if let loc = locationManager.lastLocation {
            let distance = loc.distance(from: CLLocation(
                latitude: LocationManager.parisCenter.latitude,
                longitude: LocationManager.parisCenter.longitude
            ))

            VStack(spacing: 4) {
                Text("Avstånd till Paris centrum")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Text(formattedDistance(distance))
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundStyle(locationManager.isInParis ? .white : .primary)
            }
            .padding()
            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
        }
    }

    private func formattedDistance(_ meters: CLLocationDistance) -> String {
        if meters < 1_000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.1f km", meters / 1_000)
        }
    }

    // MARK: - Action Button

    private var actionButton: some View {
        Button(action: handleButtonTap) {
            Text(buttonTitle)
                .font(.headline)
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(
                    locationManager.monitoringActive ? Color.red : Color.blue,
                    in: RoundedRectangle(cornerRadius: 14)
                )
        }
        .padding(.horizontal)
    }

    private var buttonTitle: String {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            return "Aktivera platstjänster"
        case .denied, .restricted:
            return "Öppna Inställningar"
        default:
            return locationManager.monitoringActive ? "Stoppa övervakning" : "Börja övervaka"
        }
    }

    private func handleButtonTap() {
        switch locationManager.authorizationStatus {
        case .notDetermined:
            locationManager.requestPermission()
        case .denied, .restricted:
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url)
            }
        default:
            if locationManager.monitoringActive {
                locationManager.stopMonitoring()
            } else {
                locationManager.startMonitoring()
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(LocationManager())
}
