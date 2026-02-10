import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            ScannerTab()
                .tabItem {
                    Label("Scan", systemImage: "camera.viewfinder")
                }
                .tag(0)

            BeerListTab()
                .tabItem {
                    Label("Beers", systemImage: "list.bullet")
                }
                .tag(1)

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "clock.arrow.circlepath")
                }
                .tag(2)
        }
        .tint(.beerGold)
    }
}

struct ScannerTab: View {
    @StateObject private var lookupService = BeerLookupService()
    @StateObject private var cameraPermission = CameraPermissionManager()
    @EnvironmentObject var scanHistory: ScanHistoryStore

    @State private var showCamera = false
    @State private var showPhotoLibrary = false
    @State private var capturedImage: UIImage?
    @State private var showResult = false

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    colors: [Color(red: 0.12, green: 0.10, blue: 0.08), Color(red: 0.20, green: 0.15, blue: 0.08)],
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()

                ScrollView {
                    VStack(spacing: 30) {
                        // Hero section
                        VStack(spacing: 16) {
                            ZStack {
                                Circle()
                                    .fill(Color.beerGold.opacity(0.15))
                                    .frame(width: 140, height: 140)

                                Circle()
                                    .fill(Color.beerGold.opacity(0.25))
                                    .frame(width: 110, height: 110)

                                Image(systemName: "camera.viewfinder")
                                    .font(.system(size: 50))
                                    .foregroundStyle(Color.beerGold)
                            }
                            .padding(.top, 20)

                            Text("Beer Scanner")
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.white)

                            Text("Point your camera at any beer can\nto discover everything about it")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.7))
                                .multilineTextAlignment(.center)
                        }

                        // Scan buttons
                        VStack(spacing: 16) {
                            Button {
                                if cameraPermission.cameraAvailable {
                                    showCamera = true
                                }
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "camera.fill")
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("Take Photo")
                                            .font(.headline)
                                        Text("Use camera to scan a beer")
                                            .font(.caption)
                                            .opacity(0.8)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(LinearGradient.beerGradient)
                                )
                            }

                            Button {
                                showPhotoLibrary = true
                            } label: {
                                HStack(spacing: 12) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.title2)
                                    VStack(alignment: .leading) {
                                        Text("Choose from Library")
                                            .font(.headline)
                                        Text("Select an existing photo")
                                            .font(.caption)
                                            .opacity(0.8)
                                    }
                                    Spacer()
                                    Image(systemName: "chevron.right")
                                }
                                .foregroundColor(.white)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color.white.opacity(0.15))
                                )
                            }
                        }
                        .padding(.horizontal)

                        // Scanning indicator
                        if lookupService.isScanning {
                            VStack(spacing: 12) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .beerGold))
                                    .scaleEffect(1.5)
                                Text("Analyzing beer label...")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.7))
                            }
                            .padding(.vertical, 30)
                        }

                        // Error message
                        if let error = lookupService.errorMessage {
                            VStack(spacing: 12) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.title)
                                    .foregroundColor(.orange)
                                Text(error)
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding()
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.orange.opacity(0.15))
                            )
                            .padding(.horizontal)
                        }

                        // Quick tips
                        VStack(alignment: .leading, spacing: 12) {
                            Text("Tips for best results")
                                .font(.headline)
                                .foregroundColor(.white)

                            TipRow(icon: "light.max", text: "Ensure good lighting on the label")
                            TipRow(icon: "arrow.up.left.and.arrow.down.right", text: "Fill the frame with the beer can")
                            TipRow(icon: "text.viewfinder", text: "Make sure the brand name is visible")
                            TipRow(icon: "hand.raised.slash", text: "Hold steady to avoid blur")
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 16)
                                .fill(Color.white.opacity(0.08))
                        )
                        .padding(.horizontal)

                        Spacer(minLength: 40)
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .sheet(isPresented: $showCamera) {
                ImagePicker(image: $capturedImage, isPresented: $showCamera, sourceType: .camera)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showPhotoLibrary) {
                ImagePicker(image: $capturedImage, isPresented: $showPhotoLibrary, sourceType: .photoLibrary)
                    .ignoresSafeArea()
            }
            .sheet(isPresented: $showResult) {
                if let result = lookupService.scanResult {
                    ScanResultView(result: result)
                }
            }
            .onChange(of: capturedImage) { _, newImage in
                if let image = newImage {
                    lookupService.scanBeerImage(image)
                }
            }
            .onChange(of: lookupService.scanResult) { _, newResult in
                if let result = newResult {
                    scanHistory.addResult(result)
                    showResult = true
                    capturedImage = nil
                }
            }
        }
    }
}

struct TipRow: View {
    let icon: String
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon)
                .foregroundColor(.beerGold)
                .frame(width: 24)
            Text(text)
                .font(.subheadline)
                .foregroundColor(.white.opacity(0.7))
        }
    }
}

struct BeerListTab: View {
    @State private var searchText = ""

    private let database = BeerDatabase.shared

    var filteredBeers: [Beer] {
        if searchText.isEmpty {
            return database.beers
        }
        return database.searchBeers(query: searchText)
    }

    var body: some View {
        NavigationStack {
            List(filteredBeers) { beer in
                NavigationLink(destination: BeerDetailView(beer: beer)) {
                    BeerListRow(beer: beer)
                }
                .listRowBackground(Color(.systemBackground))
            }
            .searchable(text: $searchText, prompt: "Search beers, styles, countries...")
            .navigationTitle("Beer Database")
        }
    }
}

struct BeerListRow: View {
    let beer: Beer

    var body: some View {
        HStack(spacing: 14) {
            ZStack {
                RoundedRectangle(cornerRadius: 12)
                    .fill(LinearGradient.beerGradient)
                    .frame(width: 50, height: 50)
                Text(String(beer.brand.prefix(2)).uppercased())
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(beer.name)
                    .font(.headline)
                HStack(spacing: 8) {
                    Text(beer.style)
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Text("  \(beer.country)")
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
            }

            Spacer()

            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f%%", beer.abv))
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.beerAmber)
                Text("ABV")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
        .padding(.vertical, 4)
    }
}
