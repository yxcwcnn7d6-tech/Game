import SwiftUI

struct BeerDetailView: View {
    let beer: Beer

    var body: some View {
        ScrollView {
            VStack(spacing: 0) {
                // Header
                ZStack(alignment: .bottom) {
                    LinearGradient.beerGradient
                        .frame(height: 220)

                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.white.opacity(0.2))
                                .frame(width: 90, height: 90)
                            Text(String(beer.brand.prefix(2)).uppercased())
                                .font(.system(size: 36, weight: .black))
                                .foregroundColor(.white)
                        }

                        Text(beer.name)
                            .font(.title2.bold())
                            .foregroundColor(.white)
                            .multilineTextAlignment(.center)

                        Text(beer.manufacturer)
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.8))
                    }
                    .padding(.bottom, 20)
                }

                VStack(spacing: 24) {
                    // Quick stats
                    HStack(spacing: 0) {
                        QuickStatItem(label: "ABV", value: String(format: "%.1f%%", beer.abv))
                        Divider().frame(height: 40)
                        QuickStatItem(label: "Promille", value: String(format: "%.0f\u{2030}", beer.promille))
                        Divider().frame(height: 40)
                        QuickStatItem(label: "Style", value: beer.style)
                        Divider().frame(height: 40)
                        QuickStatItem(label: "Origin", value: beer.country)
                    }
                    .padding(.vertical, 16)
                    .background(Color(.secondarySystemBackground))
                    .cornerRadius(16)
                    .padding(.horizontal)
                    .padding(.top, 16)

                    // Alcohol information
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Alcohol Information", icon: "drop.triangle.fill")

                        VStack(spacing: 12) {
                            InfoRow(label: "Alcohol by Volume (ABV)", value: String(format: "%.1f%%", beer.abv))
                            InfoRow(label: "Alcohol Content (Promille)", value: String(format: "%.0f\u{2030}", beer.promille))
                            InfoRow(label: "Est. BAC per Serving", value: String(format: "%.3f\u{2030}", beer.estimatedBACPerServing * 10))
                            InfoRow(label: "Volume", value: beer.volume)
                            if let calories = beer.calories {
                                InfoRow(label: "Calories per Serving", value: "\(calories) kcal")
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)

                        // BAC Warning
                        HStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.orange)
                            Text("BAC estimates are approximate. Actual values depend on body weight, sex, food intake, and metabolism. Never drink and drive.")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .background(Color.orange.opacity(0.1))
                        .cornerRadius(12)
                    }
                    .padding(.horizontal)

                    // Manufacturer info
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Manufacturer", icon: "building.2.fill")

                        VStack(spacing: 12) {
                            InfoRow(label: "Brand", value: beer.brand)
                            InfoRow(label: "Manufacturer", value: beer.manufacturer)
                            InfoRow(label: "Country of Origin", value: beer.country)
                            InfoRow(label: "Beer Style", value: beer.style)
                            if let ibu = beer.ibu {
                                InfoRow(label: "Bitterness (IBU)", value: "\(ibu)")
                            }
                            InfoRow(label: "Serving Temperature", value: beer.servingTemperature)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // Description
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "About This Beer", icon: "info.circle.fill")

                        Text(beer.description)
                            .font(.body)
                            .foregroundColor(.secondary)
                            .lineSpacing(4)
                            .padding()
                            .background(Color(.secondarySystemBackground))
                            .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // Flavor profile
                    VStack(alignment: .leading, spacing: 16) {
                        SectionHeader(title: "Flavor Profile", icon: "chart.bar.fill")

                        VStack(spacing: 14) {
                            FlavorBar(label: "Sweetness", value: beer.flavorProfile.sweetness, color: .pink)
                            FlavorBar(label: "Bitterness", value: beer.flavorProfile.bitterness, color: .green)
                            FlavorBar(label: "Body", value: beer.flavorProfile.body, color: .beerAmber)
                            FlavorBar(label: "Hoppy", value: beer.flavorProfile.hoppy, color: .mint)
                            FlavorBar(label: "Malty", value: beer.flavorProfile.malty, color: .brown)
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // Ingredients
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Ingredients", icon: "leaf.fill")

                        FlowLayout(spacing: 8) {
                            ForEach(beer.ingredients, id: \.self) { ingredient in
                                Text(ingredient)
                                    .font(.subheadline)
                                    .padding(.horizontal, 14)
                                    .padding(.vertical, 8)
                                    .background(
                                        Capsule()
                                            .fill(Color.beerGold.opacity(0.15))
                                    )
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    // Food pairings
                    VStack(alignment: .leading, spacing: 12) {
                        SectionHeader(title: "Food Pairings", icon: "fork.knife")

                        VStack(alignment: .leading, spacing: 10) {
                            ForEach(beer.pairings, id: \.self) { pairing in
                                HStack(spacing: 10) {
                                    Image(systemName: "circle.fill")
                                        .font(.system(size: 6))
                                        .foregroundColor(.beerGold)
                                    Text(pairing)
                                        .font(.subheadline)
                                }
                            }
                        }
                        .padding()
                        .background(Color(.secondarySystemBackground))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal)

                    Spacer(minLength: 40)
                }
            }
        }
        .ignoresSafeArea(edges: .top)
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct QuickStatItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.system(size: 13, weight: .bold))
                .lineLimit(1)
                .minimumScaleFactor(0.7)
            Text(label)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct SectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .foregroundColor(.beerGold)
            Text(title)
                .font(.headline)
        }
    }
}

struct InfoRow: View {
    let label: String
    let value: String

    var body: some View {
        HStack {
            Text(label)
                .font(.subheadline)
                .foregroundColor(.secondary)
            Spacer()
            Text(value)
                .font(.subheadline)
                .fontWeight(.medium)
        }
    }
}

struct FlavorBar: View {
    let label: String
    let value: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value)/5")
                    .font(.caption)
                    .foregroundColor(.secondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(color.opacity(0.15))
                        .frame(height: 8)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(color)
                        .frame(width: geo.size.width * CGFloat(value) / 5.0, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}
