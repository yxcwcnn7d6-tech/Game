import SwiftUI

// MARK: - Grid Overlay View

struct GridOverlayView: View {
    let quadrants: [Quadrant]
    let currentQuadrant: Quadrant?
    let completedQuadrants: Set<String>
    let suspiciousQuadrants: Set<String>
    let detections: [Detection]
    let onQuadrantTap: (Quadrant) -> Void

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let height = geometry.size.height
            let cellWidth = width / 2
            let cellHeight = height / 2

            ZStack {
                // Grid lines
                Path { path in
                    // Vertical center line
                    path.move(to: CGPoint(x: width / 2, y: 0))
                    path.addLine(to: CGPoint(x: width / 2, y: height))
                    // Horizontal center line
                    path.move(to: CGPoint(x: 0, y: height / 2))
                    path.addLine(to: CGPoint(x: width, y: height / 2))
                }
                .stroke(.white.opacity(0.6), lineWidth: 1.5)

                // Quadrant overlays
                ForEach(quadrants) { quadrant in
                    let rect = quadrantRect(quadrant, cellWidth: cellWidth, cellHeight: cellHeight)

                    QuadrantCell(
                        quadrant: quadrant,
                        isCurrent: currentQuadrant?.id == quadrant.id,
                        isCompleted: completedQuadrants.contains(quadrant.id),
                        isSuspicious: suspiciousQuadrants.contains(quadrant.id),
                        rect: rect
                    )
                    .onTapGesture {
                        onQuadrantTap(quadrant)
                    }
                }
            }
        }
    }

    private func quadrantRect(_ quadrant: Quadrant, cellWidth: CGFloat, cellHeight: CGFloat) -> CGRect {
        CGRect(
            x: CGFloat(quadrant.col) * cellWidth,
            y: CGFloat(quadrant.row) * cellHeight,
            width: cellWidth,
            height: cellHeight
        )
    }
}

// MARK: - Quadrant Cell

struct QuadrantCell: View {
    let quadrant: Quadrant
    let isCurrent: Bool
    let isCompleted: Bool
    let isSuspicious: Bool
    let rect: CGRect

    var body: some View {
        ZStack {
            // Background tint
            Rectangle()
                .fill(backgroundColor)
                .frame(width: rect.width, height: rect.height)

            // Border for current quadrant
            if isCurrent {
                Rectangle()
                    .stroke(Color.orange, lineWidth: 3)
                    .frame(width: rect.width, height: rect.height)
            }

            // Status icon
            VStack {
                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                        .font(.title3)
                } else if isSuspicious {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.red)
                        .font(.title3)
                }

                // Label
                Text(quadrant.label)
                    .font(.caption2.bold())
                    .foregroundStyle(.white)
                    .padding(.horizontal, 6)
                    .padding(.vertical, 2)
                    .background(.black.opacity(0.5))
                    .clipShape(Capsule())
            }
        }
        .position(x: rect.midX, y: rect.midY)
    }

    private var backgroundColor: Color {
        if isCurrent {
            return .orange.opacity(0.15)
        } else if isCompleted {
            return .green.opacity(0.1)
        } else if isSuspicious {
            return .red.opacity(0.15)
        }
        return .clear
    }
}

// MARK: - Detection Overlay View

struct DetectionOverlayView: View {
    let detections: [Detection]

    var body: some View {
        GeometryReader { geometry in
            ForEach(detections) { detection in
                let rect = scaledRect(detection.boundingBox, in: geometry.size)

                ZStack(alignment: .topLeading) {
                    // Bounding box
                    Rectangle()
                        .stroke(detectionColor(detection), lineWidth: 2)
                        .frame(width: rect.width, height: rect.height)

                    // Label
                    Text(detection.type.displayName)
                        .font(.system(size: 9, weight: .bold))
                        .foregroundStyle(.white)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 2)
                        .background(detectionColor(detection))
                        .clipShape(RoundedRectangle(cornerRadius: 3))
                        .offset(y: -16)
                }
                .position(x: rect.midX, y: rect.midY)
            }
        }
    }

    private func scaledRect(_ normalized: CGRect, in size: CGSize) -> CGRect {
        // Vision coordinates: origin at bottom-left, SwiftUI at top-left
        CGRect(
            x: normalized.origin.x * size.width,
            y: (1 - normalized.origin.y - normalized.height) * size.height,
            width: normalized.width * size.width,
            height: normalized.height * size.height
        )
    }

    private func detectionColor(_ detection: Detection) -> Color {
        switch detection.confidence {
        case 0.8...: return .red
        case 0.5..<0.8: return .orange
        default: return .yellow
        }
    }
}

// MARK: - Guidance Arrow View

struct GuidanceArrowView: View {
    let targetQuadrant: Quadrant?

    var body: some View {
        if let quadrant = targetQuadrant {
            GeometryReader { geometry in
                let center = CGPoint(x: geometry.size.width / 2, y: geometry.size.height / 2)
                let target = quadrantCenter(quadrant, in: geometry.size)
                let angle = atan2(target.y - center.y, target.x - center.x)

                Image(systemName: "arrow.up")
                    .font(.system(size: 40, weight: .bold))
                    .foregroundStyle(.orange)
                    .rotationEffect(.radians(angle + .pi / 2))
                    .position(x: center.x, y: center.y - 100)
                    .shadow(color: .black.opacity(0.5), radius: 4)
            }
        }
    }

    private func quadrantCenter(_ quadrant: Quadrant, in size: CGSize) -> CGPoint {
        CGPoint(
            x: (CGFloat(quadrant.col) + 0.5) * size.width / 2,
            y: (CGFloat(quadrant.row) + 0.5) * size.height / 2
        )
    }
}
