//
//  BrakeChartView.swift
//  AcDash
//
//  Created by Michael Rechberger on 09.10.26.
//

import Foundation
import Observation

struct BrakeSample: Identifiable {
    let id = UUID()
    let time: Double     // Sekunden
    let brake: Double    // 0–100 %
}

@Observable
final class BrakeChartViewModel {
    var samples: [BrakeSample] = BrakeChartViewModel.dummy()

    /// 30 s mit 10 Hz: Bremszonen mit hartem Anbremsen und langsamem Lösen (Trail Braking)
    static func dummy() -> [BrakeSample] {
        let zones: [(start: Double, length: Double, peak: Double)] = [
            (2, 1.8, 100), (8, 1.2, 75), (13, 2.2, 95), (20, 0.8, 40), (25, 1.5, 85)
        ]

        return stride(from: 0.0, through: 30.0, by: 0.1).map { t in
            var brake = 0.0
            for z in zones where t >= z.start && t <= z.start + z.length {
                let p = (t - z.start) / z.length          // 0…1 innerhalb der Zone
                brake = p < 0.15
                    ? z.peak * (p / 0.15)                 // schnell rein
                    : z.peak * (1 - (p - 0.15) / 0.85)    // langsam raus
            }
            return BrakeSample(time: t, brake: brake)
        }
    }
}
