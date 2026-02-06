import SwiftUI
import Combine

// MARK: - Scan ViewModel

@MainActor
class ScanViewModel: ObservableObject {
    // MARK: - Published State
    @Published var session: ScanSession
    @Published var isCapturing = false
    @Published var showingGrid = false
    @Published var currentDetections: [Detection] = []
    @Published var guidanceText = "Tryck för att ta översiktsbild"
    @Published var progressText = ""
    @Published var showAnalysisOverlay = false
    @Published var analysisProgress: Double = 0
    @Published var errorMessage: String?
    @Published var scanComplete = false

    // MARK: - Services
    let cameraManager = CameraManager()
    let motionManager: MotionManager
    let locationManager = LocationManager()
    let analysisService: AIAnalysisService
    let storageService = StorageService.shared

    // MARK: - Settings
    let settings: AppSettings

    // MARK: - Internal State
    private var pendingQuadrants: [Quadrant] = []
    private var currentQuadrantIndex = 0
    private var cancellables = Set<AnyCancellable>()

    // MARK: - Init

    init(settings: AppSettings) {
        self.settings = settings
        self.session = ScanSession(scanMode: settings.scanMode)
        self.motionManager = MotionManager(stabilityDuration: settings.stabilizationDuration)
        self.analysisService = AIAnalysisService(sensitivity: settings.aiSensitivity)

        setupAutoCapture()
    }

    // MARK: - Setup

    func setup() {
        cameraManager.configure()
        cameraManager.start()
        locationManager.requestPermission()

        if settings.autoCaptureEnabled {
            motionManager.startMonitoring()
        }
    }

    func teardown() {
        cameraManager.stop()
        motionManager.stopMonitoring()
        locationManager.stopUpdating()
    }

    private func setupAutoCapture() {
        guard settings.autoCaptureEnabled else { return }

        motionManager.$isStable
            .removeDuplicates()
            .filter { $0 }
            .sink { [weak self] _ in
                guard let self = self,
                      self.showingGrid,
                      self.session.currentQuadrant != nil,
                      !self.isCapturing else { return }
                Task {
                    await self.captureCurrentQuadrant()
                }
            }
            .store(in: &cancellables)
    }

    // MARK: - Scan Flow

    /// Step 1: Capture overview image
    func captureOverview() async {
        isCapturing = true
        guidanceText = "Tar översiktsbild..."

        do {
            cameraManager.setZoomLevel(.overview)
            let image = try await cameraManager.capturePhoto()

            session.location = locationManager.currentLocation

            let imagePath = try storageService.saveImage(
                image,
                sessionId: session.id,
                name: "overview_1x"
            )

            let capture = CapturedImage(
                quadrantId: "root",
                zoomLevel: .overview,
                imagePath: imagePath,
                location: session.location
            )
            session.addCapture(capture)

            // Analyze overview
            guidanceText = "Analyserar översiktsbild..."
            showAnalysisOverlay = true
            session.scanPhase = .analyzing

            let result = try await analysisService.analyzeImage(
                image,
                quadrantId: "root",
                zoomLevel: .overview
            )

            currentDetections = result.detections
            result.detections.forEach { session.addDetection($0) }

            showAnalysisOverlay = false
            showingGrid = true

            // Setup quadrant scanning
            setupQuadrantQueue(suspiciousQuadrants: result.suspiciousQuadrants)

            session.scanPhase = .detailScan
            updateGuidance()

        } catch {
            errorMessage = error.localizedDescription
        }

        isCapturing = false
    }

    /// Setup which quadrants to scan based on mode
    private func setupQuadrantQueue(suspiciousQuadrants: Set<String>) {
        let rootQuadrants = session.rootQuadrants

        switch settings.scanMode {
        case .quick:
            // Only scan quadrants flagged by AI
            pendingQuadrants = rootQuadrants.filter { q in
                suspiciousQuadrants.contains(q.id)
            }
            if pendingQuadrants.isEmpty {
                // If no suspicions, still scan all at detail level
                pendingQuadrants = rootQuadrants
            }
        case .complete:
            pendingQuadrants = rootQuadrants
        case .custom:
            // In custom mode, user selects quadrants - start with all
            pendingQuadrants = rootQuadrants
        }

        currentQuadrantIndex = 0
        if let first = pendingQuadrants.first {
            session.currentQuadrant = first
        }
    }

    /// Step 2: Capture current quadrant at detail zoom
    func captureCurrentQuadrant() async {
        guard let quadrant = session.currentQuadrant, !isCapturing else { return }

        isCapturing = true
        let zoomLevel = quadrant.zoomLevel == .overview ? ZoomLevel.detail : ZoomLevel.maximum

        do {
            cameraManager.setZoomLevel(zoomLevel)
            guidanceText = "Tar detaljbild av \(quadrant.label)..."

            let image = try await cameraManager.capturePhoto()

            let imageName = "detail_\(zoomLevel.rawValue)x_\(quadrant.id)"
            let imagePath = try storageService.saveImage(
                image,
                sessionId: session.id,
                name: imageName
            )

            let capture = CapturedImage(
                quadrantId: quadrant.id,
                zoomLevel: zoomLevel,
                imagePath: imagePath,
                location: locationManager.currentLocation
            )
            session.addCapture(capture)

            // Analyze detail image
            guidanceText = "Analyserar \(quadrant.label)..."
            showAnalysisOverlay = true

            let result = try await analysisService.analyzeImage(
                image,
                quadrantId: quadrant.id,
                zoomLevel: zoomLevel
            )

            result.detections.forEach { session.addDetection($0) }
            currentDetections.append(contentsOf: result.detections)

            showAnalysisOverlay = false
            session.markQuadrantCompleted(quadrant.id)

            // If suspicious detections found at detail level, queue max-zoom children
            if zoomLevel == .detail && !result.suspiciousQuadrants.isEmpty {
                let children = quadrant.children
                let suspiciousChildren = children.filter { child in
                    result.suspiciousQuadrants.contains(child.id)
                }
                if !suspiciousChildren.isEmpty {
                    pendingQuadrants.insert(contentsOf: suspiciousChildren,
                                           at: currentQuadrantIndex + 1)
                }
            }

            // Move to next quadrant
            advanceToNextQuadrant()

        } catch {
            errorMessage = error.localizedDescription
        }

        isCapturing = false
    }

    /// Select a specific quadrant (for custom mode)
    func selectQuadrant(_ quadrant: Quadrant) {
        session.currentQuadrant = quadrant
        if !pendingQuadrants.contains(where: { $0.id == quadrant.id }) {
            pendingQuadrants.append(quadrant)
        }
        updateGuidance()
    }

    /// Advance to next queued quadrant
    private func advanceToNextQuadrant() {
        currentQuadrantIndex += 1

        if currentQuadrantIndex < pendingQuadrants.count {
            session.currentQuadrant = pendingQuadrants[currentQuadrantIndex]
            updateGuidance()
        } else {
            completeScan()
        }
    }

    /// Skip current quadrant
    func skipCurrentQuadrant() {
        session.markQuadrantCompleted(session.currentQuadrant?.id ?? "")
        advanceToNextQuadrant()
    }

    // MARK: - Completion

    private func completeScan() {
        session.finishSession()
        scanComplete = true
        guidanceText = "Skanning klar!"

        // Save session
        do {
            try storageService.saveSession(session)
        } catch {
            errorMessage = "Kunde inte spara session: \(error.localizedDescription)"
        }
    }

    // MARK: - Guidance

    private func updateGuidance() {
        guard let quadrant = session.currentQuadrant else {
            guidanceText = "Skanning klar"
            return
        }

        let completedCount = session.completedQuadrants.count
        let totalCount = pendingQuadrants.count

        progressText = "Kvadrant \(completedCount + 1) av \(totalCount)"

        if settings.autoCaptureEnabled {
            guidanceText = "Rikta kameran mot \(quadrant.label) - auto-capture vid stabilitet"
        } else {
            guidanceText = "Rikta kameran mot \(quadrant.label) och tryck för att ta bild"
        }
    }

    // MARK: - Report

    func generateReport() -> OSHReport {
        OSHReport(from: session)
    }
}
