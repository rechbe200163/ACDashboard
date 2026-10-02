import SwiftUI
import AcBridgeKit

struct SegementsView: View {
    let segments: [SectorResult]
    var groupSize: Int = 8          // nach jeweils 15 eine Lücke

    var body: some View {
        HStack(spacing: 8) {
            Spacer()
            ForEach(segments.indices, id: \.self) { i in
                if i > 0 && i % groupSize == 0 {
                    Spacer()
                }
                Capsule()
                    .fill(color(segments[i]))
                    .frame(width: 32, height: 16)
            }
            Spacer()
        }
        .padding()
    }

    private func color(_ result: SectorResult) -> Color {
        switch result {
        case .purple:  .purple
        case .green:   .green
        case .yellow:  .yellow
        case .pending: .gray
        case .neutral: .secondary.opacity(0.15)
        }
    }
}

#Preview {
    SegementsView(segments: [.purple, .yellow, .green, .pending] + Array(repeating: .neutral, count: 20))
}
