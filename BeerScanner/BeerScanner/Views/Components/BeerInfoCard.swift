import SwiftUI

struct BeerInfoCard: View {
    let beer: Beer

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(beer.style)
                        .font(.caption)
                        .fontWeight(.medium)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(
                            Capsule()
                                .fill(Color.beerGold.opacity(0.2))
                        )
                        .foregroundColor(.beerAmber)

                    Text(beer.country)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                Image(systemName: "globe")
                    .foregroundColor(.beerGold)
            }

            Divider()

            // Manufacturer info
            VStack(alignment: .leading, spacing: 8) {
                DetailRow(icon: "building.2", label: "Manufacturer", value: beer.manufacturer)
                DetailRow(icon: "mappin.and.ellipse", label: "Country", value: beer.country)
                DetailRow(icon: "tag", label: "Brand", value: beer.brand)
                DetailRow(icon: "thermometer.medium", label: "Serve at", value: beer.servingTemperature)
            }

            Divider()

            // Alcohol details
            VStack(alignment: .leading, spacing: 8) {
                Text("Alcohol Content")
                    .font(.subheadline.bold())

                HStack(spacing: 20) {
                    AlcoholDetail(label: "ABV", value: String(format: "%.1f%%", beer.abv))
                    AlcoholDetail(label: "Promille", value: String(format: "%.0f\u{2030}", beer.promille))
                    if let ibu = beer.ibu {
                        AlcoholDetail(label: "IBU", value: "\(ibu)")
                    }
                    if let cal = beer.calories {
                        AlcoholDetail(label: "kcal", value: "\(cal)")
                    }
                }
            }

            Divider()

            // Description
            Text(beer.description)
                .font(.caption)
                .foregroundColor(.secondary)
                .lineSpacing(3)
        }
        .padding()
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
        )
    }
}

struct DetailRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: icon)
                .frame(width: 20)
                .foregroundColor(.beerGold)
            Text(label)
                .font(.caption)
                .foregroundColor(.secondary)
                .frame(width: 90, alignment: .leading)
            Text(value)
                .font(.caption)
                .fontWeight(.medium)
        }
    }
}

struct AlcoholDetail: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 2) {
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.beerAmber)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
    }
}
