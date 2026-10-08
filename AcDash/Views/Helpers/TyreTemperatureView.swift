//
//  TyreTemperatureView.swift
//  AcDash
//

import SwiftUI
import AcBridgeKit

struct TyreTemperatureView: View {
    let data: TyreData
    /// Fenster aus den Autodateien (session.carPhysics). nil → grobe Schätzung nach Mischungsname
    var front: TempWindow? = nil
    var rear: TempWindow? = nil

    var body: some View {
        CardView {
            Grid(horizontalSpacing: 15, verticalSpacing: 15) {   // 2×2 wie am Auto
                GridRow { tyre(\.fl, isLeft: true,  isFront: true);  tyre(\.fr, isLeft: false, isFront: true) }
                GridRow { tyre(\.rl, isLeft: true,  isFront: false); tyre(\.rr, isLeft: false, isFront: false) }
            }
        }
    }

    /// Ein Reifen. Welcher, sagt der KeyPath: \.fl, \.fr, \.rl, \.rr
    private func tyre(_ corner: KeyPath<Wheels, Double>, isLeft: Bool, isFront: Bool) -> some View {
        let window   = (isFront ? front : rear) ?? .estimate(for: data.compound)
        let core     = data.coreTemp[keyPath: corner]
        let pressure = data.pressure[keyPath: corner]
        let inner    = data.innerTemp[keyPath: corner]
        let middle   = data.middleTemp[keyPath: corner]
        let outer    = data.outerTemp[keyPath: corner]

        // Die Innenseite zeigt zur Fahrzeugmitte: links montiert → innen ist rechts
        let surface = isLeft ? [outer, middle, inner] : [inner, middle, outer]

        return VStack(spacing: 6) {
            // Innen / Mitte / Außen
            HStack(spacing: 3) {
                ForEach(surface.indices, id: \.self) { i in
                    Capsule()
                        .fill(window.color(for: surface[i]))
                        .frame(height: 6)
                }
            }

            RoundedRectangle(cornerRadius: 16)
                .fill(window.color(for: core))
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .overlay {
                    VStack(spacing: 2) {
                        Text("\(core, specifier: "%.0f")°")
                            .font(.title3.bold().monospacedDigit())
                        Text("\(pressure, specifier: "%.1f") psi")
                            .font(.caption2.monospacedDigit())
                    }
                    .foregroundStyle(.black)
                }
        }
        .aspectRatio(0.7, contentMode: .fit)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

extension TempWindow {
    /// blau = kalt, cyan = fast, grün = optimal, gelb = etwas zu heiß, rot = zu heiß
    func color(for temp: Double) -> Color {
        switch Int(temp.rounded()) {
        case ..<okMinC:      .blue
        case ..<optimalMinC: .cyan
        case ...optimalMaxC: .green
        case ...okMaxC:      .yellow
        default:             .red
        }
    }

    /// Fallback, wenn die Bridge keine Autodaten hat: grobe Richtwerte nach Mischungsname
    static func estimate(for compound: String) -> TempWindow {
        let n = compound.lowercased()
        let (min, max) =
            n.contains("street") || n.contains("road") ? (70, 90) :
            n.contains("semi")                         ? (75, 95) :
                                                         (80, 100)   // Slicks
        return TempWindow(peakC: (min + max) / 2,
                          optimalMinC: min, optimalMaxC: max,
                          okMinC: min - 10, okMaxC: max + 10)
    }
}

#Preview {
    // C1 Hard der RSS Formula Hybrid 2020
    let c1 = TempWindow(peakC: 125, optimalMinC: 111, optimalMaxC: 139, okMinC: 94, okMaxC: 156)

    TyreTemperatureView(
        data: TyreData(
            coreTemp:   Wheels(fl: 125, fr: 145, rl: 105, rr: 85),
            innerTemp:  Wheels(fl: 132, fr: 160, rl: 110, rr: 90),
            middleTemp: Wheels(fl: 125, fr: 145, rl: 104, rr: 85),
            outerTemp:  Wheels(fl: 118, fr: 135, rl: 98,  rr: 80),
            pressure:   Wheels(all: 22.0),
            wear:       Wheels(all: 100),
            slip:       Wheels(all: 0),
            load:       Wheels(all: 0),
            compound:   "Hard (C1)"
        ),
        front: c1,
        rear: c1
    )
    .padding()
    .preferredColorScheme(.dark)
}
