import Foundation
import CoreLocation

// MARK: - Scan Mode

enum ScanMode: String, Codable, CaseIterable {
    case quick = "Snabb scan"
    case complete = "Komplett scan"
    case custom = "Custom"

    var description: String {
        switch self {
        case .quick: return "AI-styrd - Endast misstänkta områden"
        case .complete: return "Full täckning - Alla kvadranter systematiskt"
        case .custom: return "Välj områden manuellt"
        }
    }
}

// MARK: - AI Sensitivity

enum AISensitivity: String, Codable, CaseIterable {
    case low = "Låg"
    case medium = "Medel"
    case high = "Hög"

    var description: String {
        switch self {
        case .low: return "Endast uppenbara objekt"
        case .medium: return "Balanserad"
        case .high: return "Flaggar allt misstänkt"
        }
    }

    var confidenceThreshold: Float {
        switch self {
        case .low: return 0.8
        case .medium: return 0.5
        case .high: return 0.3
        }
    }
}

// MARK: - Report Format

enum ReportFormat: String, Codable, CaseIterable {
    case simple = "Enkel"
    case osh = "OSH-standard"
    case custom = "Custom template"
}

// MARK: - Data Handling

enum DataHandling: String, Codable, CaseIterable {
    case local = "Spara lokalt"
    case remote = "Auto-skicka till central"
    case both = "Båda"
}

// MARK: - Zoom Level

enum ZoomLevel: Int, Codable, CaseIterable {
    case overview = 1
    case detail = 2
    case maximum = 3

    var zoomFactor: CGFloat {
        switch self {
        case .overview: return 1.0
        case .detail: return 2.0
        case .maximum: return 5.0
        }
    }

    var label: String {
        switch self {
        case .overview: return "Översikt (1x)"
        case .detail: return "Detalj (2x)"
        case .maximum: return "Max (5x)"
        }
    }
}

// MARK: - Quadrant

struct Quadrant: Identifiable, Codable, Hashable {
    let id: String
    let row: Int
    let col: Int
    let zoomLevel: ZoomLevel
    let parentId: String?

    var label: String {
        let directions = ["NW", "NE", "SW", "SE"]
        let index = row * 2 + col
        guard index < directions.count else { return id }
        return directions[index]
    }

    var children: [Quadrant] {
        guard zoomLevel != .maximum else { return [] }
        let nextLevel: ZoomLevel = zoomLevel == .overview ? .detail : .maximum
        return (0..<2).flatMap { r in
            (0..<2).map { c in
                Quadrant(
                    id: "\(id)-\(r)\(c)",
                    row: r,
                    col: c,
                    zoomLevel: nextLevel,
                    parentId: id
                )
            }
        }
    }

    /// Normalized rect within parent (0...1)
    var normalizedRect: CGRect {
        CGRect(
            x: CGFloat(col) * 0.5,
            y: CGFloat(row) * 0.5,
            width: 0.5,
            height: 0.5
        )
    }
}

// MARK: - Detection

struct Detection: Identifiable, Codable {
    let id: UUID
    let quadrantId: String
    let type: DetectionType
    let confidence: Float
    let description: String
    let boundingBox: CGRect
    let imagePath: String?
    let markedImagePath: String?
    let timestamp: Date

    init(
        id: UUID = UUID(),
        quadrantId: String,
        type: DetectionType,
        confidence: Float,
        description: String,
        boundingBox: CGRect,
        imagePath: String? = nil,
        markedImagePath: String? = nil,
        timestamp: Date = Date()
    ) {
        self.id = id
        self.quadrantId = quadrantId
        self.type = type
        self.confidence = confidence
        self.description = description
        self.boundingBox = boundingBox
        self.imagePath = imagePath
        self.markedImagePath = markedImagePath
        self.timestamp = timestamp
    }
}

enum DetectionType: String, Codable {
    case suspectedOXA = "misstänkt_oxa"
    case metallic = "metalliskt_föremål"
    case cylindrical = "cylindriskt_föremål"
    case unknown = "okänt_föremål"

    var displayName: String {
        switch self {
        case .suspectedOXA: return "Misstänkt OXA"
        case .metallic: return "Metalliskt föremål"
        case .cylindrical: return "Cylindriskt föremål"
        case .unknown: return "Okänt föremål"
        }
    }
}

// MARK: - Captured Image

struct CapturedImage: Identifiable, Codable {
    let id: UUID
    let quadrantId: String
    let zoomLevel: ZoomLevel
    let imagePath: String
    let timestamp: Date
    let location: CLLocationCoordinate2D?

    init(
        id: UUID = UUID(),
        quadrantId: String,
        zoomLevel: ZoomLevel,
        imagePath: String,
        timestamp: Date = Date(),
        location: CLLocationCoordinate2D? = nil
    ) {
        self.id = id
        self.quadrantId = quadrantId
        self.zoomLevel = zoomLevel
        self.imagePath = imagePath
        self.timestamp = timestamp
        self.location = location
    }
}

// CLLocationCoordinate2D Codable conformance
extension CLLocationCoordinate2D: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case latitude = "lat"
        case longitude = "lng"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let lat = try container.decode(Double.self, forKey: .latitude)
        let lng = try container.decode(Double.self, forKey: .longitude)
        self.init(latitude: lat, longitude: lng)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(latitude, forKey: .latitude)
        try container.encode(longitude, forKey: .longitude)
    }
}

// CGRect Codable conformance
extension CGRect: @retroactive Codable {
    enum CodingKeys: String, CodingKey {
        case x, y, width, height
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let x = try container.decode(CGFloat.self, forKey: .x)
        let y = try container.decode(CGFloat.self, forKey: .y)
        let w = try container.decode(CGFloat.self, forKey: .width)
        let h = try container.decode(CGFloat.self, forKey: .height)
        self.init(x: x, y: y, width: w, height: h)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(origin.x, forKey: .x)
        try container.encode(origin.y, forKey: .y)
        try container.encode(size.width, forKey: .width)
        try container.encode(size.height, forKey: .height)
    }
}
