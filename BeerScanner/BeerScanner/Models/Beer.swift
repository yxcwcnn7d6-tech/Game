import Foundation

struct Beer: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    let brand: String
    let manufacturer: String
    let country: String
    let style: String
    let abv: Double          // Alcohol by volume (percentage)
    let ibu: Int?            // International Bitterness Units
    let volume: String       // e.g. "330ml", "500ml"
    let calories: Int?       // per serving
    let ingredients: [String]
    let description: String
    let flavorProfile: FlavorProfile
    let servingTemperature: String
    let pairings: [String]

    /// Alcohol content expressed as promille (parts per thousand)
    /// ABV 5.0% = 50 promille
    var promille: Double {
        abv * 10.0
    }

    /// Estimated blood alcohol content (BAC) contribution per standard serving
    /// Based on Widmark formula for a 70kg person
    var estimatedBACPerServing: Double {
        let volumeMl = extractVolumeMl()
        let alcoholGrams = volumeMl * (abv / 100.0) * 0.789
        let bac = alcoholGrams / (70.0 * 0.68)
        return bac
    }

    private func extractVolumeMl() -> Double {
        let digits = volume.filter { $0.isNumber || $0 == "." }
        return Double(digits) ?? 330.0
    }
}

struct FlavorProfile: Codable, Equatable {
    let sweetness: Int    // 1-5
    let bitterness: Int   // 1-5
    let body: Int         // 1-5 (light to full)
    let hoppy: Int        // 1-5
    let malty: Int        // 1-5
}

struct ScanResult: Identifiable, Codable {
    let id: UUID
    let beer: Beer
    let scannedAt: Date
    let recognizedTexts: [String]
    let confidence: Double

    init(beer: Beer, recognizedTexts: [String], confidence: Double) {
        self.id = UUID()
        self.beer = beer
        self.scannedAt = Date()
        self.recognizedTexts = recognizedTexts
        self.confidence = confidence
    }
}
