import SwiftUI

// MARK: - Start Screen

struct StartScreen: View {
    @EnvironmentObject var settings: AppSettings
    @State private var showingScan = false
    @State private var showingSettings = false
    @State private var showingHistory = false
    @State private var selectedMode: ScanMode?

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                LinearGradient(
                    colors: [Color(hex: "1a1a2e"), Color(hex: "16213e")],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                VStack(spacing: 32) {
                    Spacer()

                    // App Icon / Logo
                    VStack(spacing: 16) {
                        Image(systemName: "viewfinder.trianglebadge.exclamationmark")
                            .font(.system(size: 72, weight: .thin))
                            .foregroundStyle(.orange)

                        Text("OXA Detektion")
                            .font(.system(size: 36, weight: .bold, design: .rounded))
                            .foregroundStyle(.white)

                        Text("Identifiering av oidentifierad explosiv ammunition")
                            .font(.subheadline)
                            .foregroundStyle(.gray)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }

                    Spacer()

                    // Action Buttons
                    VStack(spacing: 16) {
                        // Quick Scan
                        Button {
                            selectedMode = settings.scanMode
                            showingScan = true
                        } label: {
                            HStack {
                                Image(systemName: "bolt.fill")
                                Text("Snabbstart")
                                    .fontWeight(.semibold)
                                Spacer()
                                Text(settings.scanMode.rawValue)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.7))
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.orange)
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // New Scan (choose mode)
                        Button {
                            selectedMode = nil
                            showingScan = true
                        } label: {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                Text("Ny skanning")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.15))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // History
                        Button {
                            showingHistory = true
                        } label: {
                            HStack {
                                Image(systemName: "clock.arrow.circlepath")
                                Text("Historik")
                                    .fontWeight(.semibold)
                                Spacer()
                                Image(systemName: "chevron.right")
                            }
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.white.opacity(0.1))
                            .foregroundStyle(.white.opacity(0.8))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }
                    }
                    .padding(.horizontal, 24)

                    Spacer()

                    // Version info
                    Text("v1.0 MVP")
                        .font(.caption2)
                        .foregroundStyle(.gray.opacity(0.5))
                        .padding(.bottom, 8)
                }
            }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showingSettings = true
                    } label: {
                        Image(systemName: "gearshape.fill")
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }
            .fullScreenCover(isPresented: $showingScan) {
                if let mode = selectedMode {
                    ScanView(scanMode: mode)
                        .environmentObject(settings)
                } else {
                    ScanModeSelector { mode in
                        selectedMode = mode
                    }
                    .environmentObject(settings)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(settings)
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView()
            }
        }
    }
}

// MARK: - Scan Mode Selector

struct ScanModeSelector: View {
    let onSelect: (ScanMode) -> Void
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ZStack {
                Color(hex: "1a1a2e").ignoresSafeArea()

                VStack(spacing: 20) {
                    Text("Välj skanningsläge")
                        .font(.title2.bold())
                        .foregroundStyle(.white)
                        .padding(.top)

                    ForEach(ScanMode.allCases, id: \.self) { mode in
                        Button {
                            onSelect(mode)
                        } label: {
                            VStack(alignment: .leading, spacing: 8) {
                                Text(mode.rawValue)
                                    .font(.headline)
                                Text(mode.description)
                                    .font(.caption)
                                    .foregroundStyle(.white.opacity(0.6))
                            }
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .background(Color.white.opacity(0.12))
                            .foregroundStyle(.white)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                        }
                    }

                    Spacer()
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Avbryt") { dismiss() }
                        .foregroundStyle(.orange)
                }
            }
        }
    }
}

// MARK: - Color Extension

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 6:
            (a, r, g, b) = (255, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = ((int >> 24) & 0xFF, (int >> 16) & 0xFF, (int >> 8) & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
