import SwiftUI

extension Color {
    static let beerGold = Color(red: 0.91, green: 0.73, blue: 0.18)
    static let beerAmber = Color(red: 0.84, green: 0.52, blue: 0.10)
    static let beerDark = Color(red: 0.25, green: 0.15, blue: 0.05)
    static let beerFoam = Color(red: 0.98, green: 0.96, blue: 0.90)
    static let beerCopper = Color(red: 0.72, green: 0.45, blue: 0.20)

    static let cardBackground = Color(.systemBackground)
    static let cardShadow = Color.black.opacity(0.08)

    static let ratingLow = Color.green
    static let ratingMedium = Color.orange
    static let ratingHigh = Color.red
}

extension LinearGradient {
    static let beerGradient = LinearGradient(
        colors: [Color.beerGold, Color.beerAmber],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    static let darkBeerGradient = LinearGradient(
        colors: [Color.beerDark, Color(red: 0.15, green: 0.08, blue: 0.02)],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}
