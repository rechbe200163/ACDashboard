//
//  LiveDeltaView.swift
//  AcDash
//
//  Created by Michael Rechberger on 06.10.26.
//

import SwiftUI

struct LiveDeltaView: View {
    let deltaMs: Int?            // negativ = schneller, nil = keine Referenz
    let predictedLapText: String    // "1:29.198"
    let bestLapText: String         // "1:29.412"
    var rangeMs: Int = 500       // Balken geht von −0.5 bis +0.5

    var body: some View {
        CardView {
            HStack(alignment: .top) {
                // links: großes Delta
                VStack(alignment: .leading, spacing: 0) {
                    Text("Live delta to best")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(deltaText)
                        .font(.system(size: 96, weight: .heavy, design: .rounded).monospacedDigit())
                        .foregroundStyle(color)
                        .lineLimit(1)
                        .minimumScaleFactor(0.4)      // wird kleiner, wenn der Platz nicht reicht
                }

                Spacer()

                // rechts: Predicted + Best
                VStack(alignment: .trailing, spacing: 4) {
                    Text("Predicted lap")
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.secondary)
                    Text(predictedLapText)
                        .font(.system(size: 40, weight: .bold, design: .rounded).monospacedDigit())
                    HStack(spacing: 4) {
                        Text("Best").foregroundStyle(.secondary)
                        Text(bestLapText).foregroundStyle(.purple).bold()
                    }
                    .font(.subheadline.monospacedDigit())
                }
            }

            DeltaBar(deltaMs: deltaMs ?? 0, rangeMs: rangeMs, color: color)
                .padding(.top, 8)

            HStack {
                Text("−\(rangeMs / 1000, specifier: "%.1f") faster")
                Spacer()
                Text("0")
                Spacer()
                Text("slower +\(rangeMs / 1000, specifier: "%.1f")")
            }
            .font(.caption)
            .foregroundStyle(.secondary)
        }
    }

    private var deltaText: String {
        guard let deltaMs else { return "–.–––" }
        return String(format: "%+.3f", Double(deltaMs) / 1000)   // erst Double, dann teilen
            .replacingOccurrences(of: "-", with: "−")
    }
    
    private var color: Color {
        guard let deltaMs else { return .secondary }
        return deltaMs < 0 ? .green : .red
    }
}

/// Balken mit Nullpunkt in der Mitte: schneller füllt nach links, langsamer nach rechts.
struct DeltaBar: View {
    let deltaMs: Int
    var rangeMs: Int = 500
    let color: Color

    var body: some View {
        GeometryReader { geo in
            let half = geo.size.width / 2
            let fraction = min(max(Double(deltaMs) / Double(rangeMs), -1), 1)   // erst Double, dann teilen
            let fill = abs(fraction) * half

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.white.opacity(0.08))
                Capsule()
                    .fill(color)
                    .frame(width: fill)
                    .offset(x: fraction < 0 ? half - fill : half)
                Rectangle()
                    .fill(.white)
                    .frame(width: 2, height: geo.size.height + 8)
                    .offset(x: half - 1)
            }
        }
        .frame(height: 12)
    }
}

#Preview {
    LiveDeltaView(deltaMs: 344, predictedLapText: "1:29.198", bestLapText: "1:29.412")
        .padding()
        .preferredColorScheme(.dark)
}
