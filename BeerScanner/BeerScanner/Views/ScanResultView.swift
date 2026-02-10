import SwiftUI

struct ScanResultView: View {
    let result: ScanResult
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 0) {
                    // Header with confidence
                    ZStack {
                        LinearGradient.beerGradient
                            .frame(height: 200)

                        VStack(spacing: 12) {
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.white)

                            Text("Beer Identified!")
                                .font(.title2.bold())
                                .foregroundColor(.white)

                            HStack(spacing: 4) {
                                Text("Confidence:")
                                    .foregroundColor(.white.opacity(0.8))
                                Text(String(format: "%.0f%%", result.confidence * 100))
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                            }
                            .font(.subheadline)
                        }
                    }

                    // Beer info
                    VStack(spacing: 20) {
                        // Name & brand
                        VStack(spacing: 6) {
                            Text(result.beer.name)
                                .font(.title.bold())
                                .multilineTextAlignment(.center)

                            Text("by \(result.beer.manufacturer)")
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding(.top, 20)

                        // Key stats grid
                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: 16) {
                            StatBadge(
                                title: "ABV",
                                value: String(format: "%.1f%%", result.beer.abv),
                                icon: "drop.fill",
                                color: .beerAmber
                            )
                            StatBadge(
                                title: "Promille",
                                value: String(format: "%.0f\u{2030}", result.beer.promille),
                                icon: "gauge.with.needle",
                                color: alcoholColor(for: result.beer.abv)
                            )
                            StatBadge(
                                title: "Volume",
                                value: result.beer.volume,
                                icon: "cup.and.saucer.fill",
                                color: .blue
                            )
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: [
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                            GridItem(.flexible()),
                        ], spacing: 16) {
                            if let ibu = result.beer.ibu {
                                StatBadge(
                                    title: "IBU",
                                    value: "\(ibu)",
                                    icon: "leaf.fill",
                                    color: .green
                                )
                            }
                            if let cal = result.beer.calories {
                                StatBadge(
                                    title: "Calories",
                                    value: "\(cal)",
                                    icon: "flame.fill",
                                    color: .orange
                                )
                            }
                            StatBadge(
                                title: "Style",
                                value: result.beer.style,
                                icon: "tag.fill",
                                color: .purple,
                                isCompact: true
                            )
                        }
                        .padding(.horizontal)

                        // Details card
                        BeerInfoCard(beer: result.beer)
                            .padding(.horizontal)

                        // Recognized text debug info
                        if !result.recognizedTexts.isEmpty {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Recognized Text")
                                    .font(.headline)
                                    .foregroundColor(.secondary)

                                FlowLayout(spacing: 6) {
                                    ForEach(result.recognizedTexts.prefix(10), id: \.self) { text in
                                        Text(text)
                                            .font(.caption)
                                            .padding(.horizontal, 8)
                                            .padding(.vertical, 4)
                                            .background(
                                                Capsule()
                                                    .fill(Color.beerGold.opacity(0.15))
                                            )
                                    }
                                }
                            }
                            .padding(.horizontal)
                        }

                        Spacer(minLength: 40)
                    }
                }
            }
            .ignoresSafeArea(edges: .top)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                    .fontWeight(.semibold)
                }
            }
        }
    }

    private func alcoholColor(for abv: Double) -> Color {
        switch abv {
        case ..<4.0: return .green
        case 4.0..<6.0: return .orange
        case 6.0..<8.0: return .red
        default: return .purple
        }
    }
}

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = layout(proposal: proposal, subviews: subviews)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = layout(proposal: proposal, subviews: subviews)
        for (index, position) in result.positions.enumerated() {
            subviews[index].place(at: CGPoint(x: bounds.minX + position.x, y: bounds.minY + position.y),
                                  proposal: .unspecified)
        }
    }

    private func layout(proposal: ProposedViewSize, subviews: Subviews) -> (size: CGSize, positions: [CGPoint]) {
        let maxWidth = proposal.width ?? .infinity
        var positions: [CGPoint] = []
        var currentX: CGFloat = 0
        var currentY: CGFloat = 0
        var lineHeight: CGFloat = 0
        var totalHeight: CGFloat = 0

        for subview in subviews {
            let size = subview.sizeThatFits(.unspecified)
            if currentX + size.width > maxWidth, currentX > 0 {
                currentX = 0
                currentY += lineHeight + spacing
                lineHeight = 0
            }
            positions.append(CGPoint(x: currentX, y: currentY))
            currentX += size.width + spacing
            lineHeight = max(lineHeight, size.height)
            totalHeight = currentY + lineHeight
        }

        return (CGSize(width: maxWidth, height: totalHeight), positions)
    }
}
