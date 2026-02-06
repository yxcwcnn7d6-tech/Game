import Foundation
import CoreLocation

// MARK: - Scan Session

class ScanSession: ObservableObject, Identifiable, Codable {
    let id: UUID
    let startTime: Date
    @Published var endTime: Date?
    @Published var scanMode: ScanMode
    @Published var location: CLLocationCoordinate2D?
    @Published var capturedImages: [CapturedImage]
    @Published var detections: [Detection]
    @Published var currentZoomLevel: ZoomLevel
    @Published var currentQuadrant: Quadrant?
    @Published var scanPhase: ScanPhase
    @Published var completedQuadrants: Set<String>
    @Published var suspiciousQuadrants: Set<String>

    var totalImages: Int { capturedImages.count }

    var rootQuadrants: [Quadrant] {
        (0..<2).flatMap { r in
            (0..<2).map { c in
                Quadrant(id: "\(r)\(c)", row: r, col: c, zoomLevel: .overview, parentId: nil)
            }
        }
    }

    init(
        id: UUID = UUID(),
        scanMode: ScanMode = .complete,
        location: CLLocationCoordinate2D? = nil
    ) {
        self.id = id
        self.startTime = Date()
        self.endTime = nil
        self.scanMode = scanMode
        self.location = location
        self.capturedImages = []
        self.detections = []
        self.currentZoomLevel = .overview
        self.currentQuadrant = nil
        self.scanPhase = .overview
        self.completedQuadrants = []
        self.suspiciousQuadrants = []
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case id, startTime, endTime, scanMode, location
        case capturedImages, detections, currentZoomLevel
        case scanPhase, completedQuadrants, suspiciousQuadrants
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        startTime = try container.decode(Date.self, forKey: .startTime)
        endTime = try container.decodeIfPresent(Date.self, forKey: .endTime)
        scanMode = try container.decode(ScanMode.self, forKey: .scanMode)
        location = try container.decodeIfPresent(CLLocationCoordinate2D.self, forKey: .location)
        capturedImages = try container.decode([CapturedImage].self, forKey: .capturedImages)
        detections = try container.decode([Detection].self, forKey: .detections)
        currentZoomLevel = try container.decode(ZoomLevel.self, forKey: .currentZoomLevel)
        scanPhase = try container.decode(ScanPhase.self, forKey: .scanPhase)
        completedQuadrants = try container.decode(Set<String>.self, forKey: .completedQuadrants)
        suspiciousQuadrants = try container.decode(Set<String>.self, forKey: .suspiciousQuadrants)
        currentQuadrant = nil
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(startTime, forKey: .startTime)
        try container.encode(endTime, forKey: .endTime)
        try container.encode(scanMode, forKey: .scanMode)
        try container.encode(location, forKey: .location)
        try container.encode(capturedImages, forKey: .capturedImages)
        try container.encode(detections, forKey: .detections)
        try container.encode(currentZoomLevel, forKey: .currentZoomLevel)
        try container.encode(scanPhase, forKey: .scanPhase)
        try container.encode(completedQuadrants, forKey: .completedQuadrants)
        try container.encode(suspiciousQuadrants, forKey: .suspiciousQuadrants)
    }

    // MARK: - Session Management

    func addCapture(_ image: CapturedImage) {
        capturedImages.append(image)
    }

    func addDetection(_ detection: Detection) {
        detections.append(detection)
        suspiciousQuadrants.insert(detection.quadrantId)
    }

    func markQuadrantCompleted(_ quadrantId: String) {
        completedQuadrants.insert(quadrantId)
    }

    func finishSession() {
        endTime = Date()
        scanPhase = .completed
    }
}

// MARK: - Scan Phase

enum ScanPhase: String, Codable {
    case overview
    case detailScan
    case maximumZoom
    case analyzing
    case completed

    var displayName: String {
        switch self {
        case .overview: return "Översiktsbild"
        case .detailScan: return "Detaljskanning"
        case .maximumZoom: return "Maximal zoom"
        case .analyzing: return "Analyserar..."
        case .completed: return "Klar"
        }
    }
}
