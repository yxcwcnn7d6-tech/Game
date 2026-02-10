import SwiftUI

struct StatBadge: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    var isCompact: Bool = false

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundColor(color)

            if isCompact {
                Text(value)
                    .font(.system(size: 11, weight: .bold))
                    .lineLimit(2)
                    .minimumScaleFactor(0.7)
                    .multilineTextAlignment(.center)
            } else {
                Text(value)
                    .font(.system(size: 18, weight: .bold))
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
            }

            Text(title)
                .font(.caption2)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(color.opacity(0.1))
        )
    }
}
