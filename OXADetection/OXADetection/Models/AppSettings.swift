import Foundation

// MARK: - App Settings

class AppSettings: ObservableObject, Codable {
    @Published var scanMode: ScanMode
    @Published var maxZoomLevel: ZoomLevel
    @Published var aiSensitivity: AISensitivity
    @Published var autoCaptureEnabled: Bool
    @Published var reportFormat: ReportFormat
    @Published var dataHandling: DataHandling
    @Published var stabilizationDuration: Double
    @Published var numberOfZoomLevels: Int

    static let defaultSettings = AppSettings()

    init(
        scanMode: ScanMode = .complete,
        maxZoomLevel: ZoomLevel = .maximum,
        aiSensitivity: AISensitivity = .medium,
        autoCaptureEnabled: Bool = true,
        reportFormat: ReportFormat = .osh,
        dataHandling: DataHandling = .local,
        stabilizationDuration: Double = 0.5,
        numberOfZoomLevels: Int = 3
    ) {
        self.scanMode = scanMode
        self.maxZoomLevel = maxZoomLevel
        self.aiSensitivity = aiSensitivity
        self.autoCaptureEnabled = autoCaptureEnabled
        self.reportFormat = reportFormat
        self.dataHandling = dataHandling
        self.stabilizationDuration = stabilizationDuration
        self.numberOfZoomLevels = numberOfZoomLevels
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case scanMode, maxZoomLevel, aiSensitivity, autoCaptureEnabled
        case reportFormat, dataHandling, stabilizationDuration, numberOfZoomLevels
    }

    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        scanMode = try container.decode(ScanMode.self, forKey: .scanMode)
        maxZoomLevel = try container.decode(ZoomLevel.self, forKey: .maxZoomLevel)
        aiSensitivity = try container.decode(AISensitivity.self, forKey: .aiSensitivity)
        autoCaptureEnabled = try container.decode(Bool.self, forKey: .autoCaptureEnabled)
        reportFormat = try container.decode(ReportFormat.self, forKey: .reportFormat)
        dataHandling = try container.decode(DataHandling.self, forKey: .dataHandling)
        stabilizationDuration = try container.decode(Double.self, forKey: .stabilizationDuration)
        numberOfZoomLevels = try container.decode(Int.self, forKey: .numberOfZoomLevels)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(scanMode, forKey: .scanMode)
        try container.encode(maxZoomLevel, forKey: .maxZoomLevel)
        try container.encode(aiSensitivity, forKey: .aiSensitivity)
        try container.encode(autoCaptureEnabled, forKey: .autoCaptureEnabled)
        try container.encode(reportFormat, forKey: .reportFormat)
        try container.encode(dataHandling, forKey: .dataHandling)
        try container.encode(stabilizationDuration, forKey: .stabilizationDuration)
        try container.encode(numberOfZoomLevels, forKey: .numberOfZoomLevels)
    }

    // MARK: - Persistence

    private static let storageKey = "OXADetection.AppSettings"

    func save() {
        if let data = try? JSONEncoder().encode(self) {
            UserDefaults.standard.set(data, forKey: Self.storageKey)
        }
    }

    static func load() -> AppSettings {
        guard let data = UserDefaults.standard.data(forKey: storageKey),
              let settings = try? JSONDecoder().decode(AppSettings.self, from: data) else {
            return AppSettings()
        }
        return settings
    }
}
