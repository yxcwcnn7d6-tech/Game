import Foundation
import CoreLocation

// MARK: - OSH Report (Objekt/Skada/Hot)

struct OSHReport: Codable, Identifiable {
    let id: UUID
    let timestamp: Date
    let location: CLLocationCoordinate2D?
    let overviewImagePath: String?
    let detections: [OSHDetection]
    let totalImages: Int
    let scanMode: ScanMode
    let aiModelVersion: String

    init(from session: ScanSession) {
        self.id = session.id
        self.timestamp = session.startTime
        self.location = session.location
        self.overviewImagePath = session.capturedImages.first(where: {
            $0.zoomLevel == .overview
        })?.imagePath
        self.detections = session.detections.map { OSHDetection(from: $0) }
        self.totalImages = session.totalImages
        self.scanMode = session.scanMode
        self.aiModelVersion = "1.0"
    }

    enum CodingKeys: String, CodingKey {
        case id
        case timestamp
        case location
        case overviewImagePath = "overview_image"
        case detections
        case totalImages = "total_images"
        case scanMode = "scan_mode"
        case aiModelVersion = "ai_model_version"
    }
}

struct OSHDetection: Codable, Identifiable {
    let id: UUID
    let quadrant: String
    let type: String
    let confidence: String
    let description: String
    let imagePath: String?
    let markedImagePath: String?
    let coordinates: DetectionCoordinates

    init(from detection: Detection) {
        self.id = detection.id
        self.quadrant = detection.quadrantId
        self.type = detection.type.rawValue
        self.confidence = Self.confidenceLabel(detection.confidence)
        self.description = detection.description
        self.imagePath = detection.imagePath
        self.markedImagePath = detection.markedImagePath
        self.coordinates = DetectionCoordinates(
            x: Int(detection.boundingBox.midX),
            y: Int(detection.boundingBox.midY)
        )
    }

    private static func confidenceLabel(_ value: Float) -> String {
        switch value {
        case 0.8...: return "hög"
        case 0.5..<0.8: return "medel"
        default: return "låg"
        }
    }

    enum CodingKeys: String, CodingKey {
        case id, quadrant, type, confidence, description
        case imagePath = "image"
        case markedImagePath = "marked_image"
        case coordinates
    }
}

struct DetectionCoordinates: Codable {
    let x: Int
    let y: Int
}
