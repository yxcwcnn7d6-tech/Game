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

    // MARK: - AI API Configuration

    @Published var aiProvider: AIProvider
    @Published var aiAPIEndpoint: String
    @Published var aiAPIKey: String
    @Published var aiModelName: String

    // MARK: - Report Delivery Configuration

    @Published var reportRecipientEmail: String
    @Published var reportAPIEndpoint: String
    @Published var reportAPIKey: String
    @Published var autoSendReport: Bool

    static let defaultSettings = AppSettings()

    init(
        scanMode: ScanMode = .complete,
        maxZoomLevel: ZoomLevel = .maximum,
        aiSensitivity: AISensitivity = .medium,
        autoCaptureEnabled: Bool = true,
        reportFormat: ReportFormat = .osh,
        dataHandling: DataHandling = .local,
        stabilizationDuration: Double = 0.5,
        numberOfZoomLevels: Int = 3,
        aiProvider: AIProvider = .onDevice,
        aiAPIEndpoint: String = "",
        aiAPIKey: String = "",
        aiModelName: String = "",
        reportRecipientEmail: String = "",
        reportAPIEndpoint: String = "",
        reportAPIKey: String = "",
        autoSendReport: Bool = false
    ) {
        self.scanMode = scanMode
        self.maxZoomLevel = maxZoomLevel
        self.aiSensitivity = aiSensitivity
        self.autoCaptureEnabled = autoCaptureEnabled
        self.reportFormat = reportFormat
        self.dataHandling = dataHandling
        self.stabilizationDuration = stabilizationDuration
        self.numberOfZoomLevels = numberOfZoomLevels
        self.aiProvider = aiProvider
        self.aiAPIEndpoint = aiAPIEndpoint
        self.aiAPIKey = aiAPIKey
        self.aiModelName = aiModelName
        self.reportRecipientEmail = reportRecipientEmail
        self.reportAPIEndpoint = reportAPIEndpoint
        self.reportAPIKey = reportAPIKey
        self.autoSendReport = autoSendReport
    }

    // MARK: - Codable

    enum CodingKeys: String, CodingKey {
        case scanMode, maxZoomLevel, aiSensitivity, autoCaptureEnabled
        case reportFormat, dataHandling, stabilizationDuration, numberOfZoomLevels
        case aiProvider, aiAPIEndpoint, aiAPIKey, aiModelName
        case reportRecipientEmail, reportAPIEndpoint, reportAPIKey, autoSendReport
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
        aiProvider = try container.decodeIfPresent(AIProvider.self, forKey: .aiProvider) ?? .onDevice
        aiAPIEndpoint = try container.decodeIfPresent(String.self, forKey: .aiAPIEndpoint) ?? ""
        aiAPIKey = try container.decodeIfPresent(String.self, forKey: .aiAPIKey) ?? ""
        aiModelName = try container.decodeIfPresent(String.self, forKey: .aiModelName) ?? ""
        reportRecipientEmail = try container.decodeIfPresent(String.self, forKey: .reportRecipientEmail) ?? ""
        reportAPIEndpoint = try container.decodeIfPresent(String.self, forKey: .reportAPIEndpoint) ?? ""
        reportAPIKey = try container.decodeIfPresent(String.self, forKey: .reportAPIKey) ?? ""
        autoSendReport = try container.decodeIfPresent(Bool.self, forKey: .autoSendReport) ?? false
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
        try container.encode(aiProvider, forKey: .aiProvider)
        try container.encode(aiAPIEndpoint, forKey: .aiAPIEndpoint)
        try container.encode(aiAPIKey, forKey: .aiAPIKey)
        try container.encode(aiModelName, forKey: .aiModelName)
        try container.encode(reportRecipientEmail, forKey: .reportRecipientEmail)
        try container.encode(reportAPIEndpoint, forKey: .reportAPIEndpoint)
        try container.encode(reportAPIKey, forKey: .reportAPIKey)
        try container.encode(autoSendReport, forKey: .autoSendReport)
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
