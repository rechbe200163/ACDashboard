import Foundation
import AcBridgeKit

final class LiveViewModel: TelemetryViewModel {
    private var lap: LapData? { frame?.lap }
    private var segments: MiniSectorData? { frame?.miniSectors }
    private var sectore: SectorData? {frame?.sectors}

    var sessionTitle: String? { session.map { "\($0.car) · \($0.track)" } }

    var speedText: String { frame.map { String(format: "%.0f", $0.speedKmh) } ?? "–" }
    var gearText: String  { frame?.gearLabel ?? "–" }
    var rpmText: String   { frame.map { "\($0.rpm)" } ?? "–" }
    
    var tyres: TyreData? {frame?.tyres}

    var rpmFraction: Double {
        guard let frame, let maxRpm = session?.maxRpm, maxRpm > 0 else { return 0 }
        return min(Double(frame.rpm) / Double(maxRpm), 1)
    }

    var throttle: Double { frame?.throttle ?? 0 }
    var brake: Double    { frame?.brake ?? 0 }
    
    var positionText: String {
        guard let pos = frame?.lap.position, pos > 0 else { return "–" }
        return "P\(pos)"
    }

    var currentLapText: String { Self.formatLap(lap?.currentLapMs) }
    var lastLapText: String    { Self.formatLap(lap?.lastLapMs) }
    var bestLapText: String    { Self.formatLap(lap?.bestLapMs) }
    
    var segmentCount: Int { frame?.miniSectors.count ?? 45 }
    
    var liveDeltaText: String { Self.formatLap(lap?.acDeltaMs)}
    var liveDelta: Int { lap?.acDeltaMs ?? 0}
    var currentSegments: [SectorResult] {segments?.results ?? []}
    
    var predictedLapText: String {
        guard let best = frame?.lap.bestLapMs,
              let delta = lap?.acDeltaMs else { return "–:––.–––" }
        return Self.formatLap(best + delta)
    }
}
