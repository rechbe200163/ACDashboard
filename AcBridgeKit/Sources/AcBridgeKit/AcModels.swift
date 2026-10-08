import Foundation

// MARK: - Modelle
//
// TS-Vergleich:  interface Wheels { fl: number; fr: number; ... }
// In Swift:      struct + Decodable. Die Feldnamen müssen exakt wie im JSON heißen (camelCase),
//                dann braucht man keinen Mapping-Code.
// `let` = readonly, `Double` = number, `Int` = number (ganzzahlig), `String?` = string | null

public struct Wheels: Decodable, Sendable {
    public let fl, fr, rl, rr: Double

    public init(fl: Double, fr: Double, rl: Double, rr: Double) {
        self.fl = fl; self.fr = fr; self.rl = rl; self.rr = rr
    }

    /// Alle vier gleich, praktisch für Previews: Wheels(all: 80)
    public init(all value: Double) {
        self.init(fl: value, fr: value, rl: value, rr: value)
    }
}

public struct GForce: Decodable, Sendable {
    public let lateral, longitudinal, vertical: Double
}

public struct TyreData: Decodable, Sendable {
    public let coreTemp, innerTemp, middleTemp, outerTemp: Wheels
    public let pressure, wear, slip, load: Wheels
    public let compound: String
    /// Index in session.carPhysics.tyreCompounds (nil = unbekannt)
    public let compoundIndex: Int?

    public init(coreTemp: Wheels, innerTemp: Wheels, middleTemp: Wheels, outerTemp: Wheels,
                pressure: Wheels, wear: Wheels, slip: Wheels, load: Wheels, compound: String,
                compoundIndex: Int? = nil) {
        self.coreTemp = coreTemp; self.innerTemp = innerTemp
        self.middleTemp = middleTemp; self.outerTemp = outerTemp
        self.pressure = pressure; self.wear = wear
        self.slip = slip; self.load = load
        self.compound = compound
        self.compoundIndex = compoundIndex
    }
}

public struct LapData: Decodable, Sendable {
    public let completedLaps: Int
    public let position: Int
    public let currentLapMs: Int
    public let lastLapMs: Int
    public let bestLapMs: Int
    public let currentSector: Int
    public let lastSectorMs: Int
    public let numberOfLaps: Int
    public let trackPosition: Double      // 0…1
    public let sessionTimeLeftMs: Int
    public let acDeltaMs: Int             // Live-Delta von AC in ms: −1500 = 1,5 s schneller, +1500 = langsamer
    public let isInPit: Bool
    public let isInPitLane: Bool
}

public struct TelemetryFrame: Decodable, Sendable {
    public let seq: Int
    public let timestamp: String          // ISO-String, als String gelassen (.NET schickt 7 Nachkommastellen)
    public let status: String             // off | replay | live | pause
    public let session: String
    public let flag: String
    public let speedKmh: Double
    public let rpm: Int
    public let gear: Int                  // -1 = R, 0 = N
    public let throttle: Double
    public let brake: Double
    public let clutch: Double
    public let steerAngle: Double
    public let fuel: Double
    public let turboBoost: Double
    public let tc: Double
    public let abs: Double
    public let brakeBias: Double
    public let drsAvailable: Bool
    public let drsEnabled: Bool
    public let pitLimiterOn: Bool
    public let gForce: GForce
    public let tyres: TyreData
    public let brakeTemp: Wheels
    public let suspensionTravel: Wheels
    public let lap: LapData
    public let carCoordinates: [Double]   // [x, y, z]
    public let airTemp: Double
    public let roadTemp: Double
    public let surfaceGrip: Double
    public let carDamage: [Double]
    public let miniSectors: MiniSectorData
    public let sectors: SectorData

    /// Computed Property = wie ein Getter in TS: get gearLabel() { ... }
    public var gearLabel: String {
        switch gear {
        case -1: "R"
        case 0: "N"
        default: String(gear)
        }
    }
}

/// Ergebnis eines Minisektors. Kommt als String vom Backend ("purple", "green", …).
/// TS-Vergleich: type SectorResult = "purple" | "green" | "yellow" | "neutral" | "pending"
/// Bedeutung je nach MiniSectorData.mode:
///   solo : purple = eigener Bestwert, green = schneller als eigene beste Runde, yellow = langsamer
///   field: purple = Feld-Bestwert,    green = eigener Bestwert,                yellow = langsamer
public enum SectorResult: String, Decodable, Sendable {
    case purple
    case green
    case yellow
    case neutral   // gefahren, aber noch kein Vergleichswert (erste gültige Runde fehlt)
    case pending   // noch nicht gefahren

    /// Unbekannte Werte (z. B. neuere Bridge) werden zu .pending, statt den ganzen Frame zu verwerfen.
    public init(from decoder: Decoder) throws {
        let raw = try decoder.singleValueContainer().decode(String.self)
        self = SectorResult(rawValue: raw) ?? .pending
    }
}

public struct MiniSectorData: Decodable, Sendable {
    public let count: Int
    public let current: Int                    // Index des Minisektors, in dem das Auto gerade ist
    public let results: [SectorResult]         // aktuelle Runde
    public let lastLapResults: [SectorResult]  // komplette letzte Runde (leer, wenn keine)
    public let lapValid: Bool
    public let mode: String?                   // "solo" | "field" (optional, ältere Bridges schicken es nicht)
    public let fieldCars: Int?                 // Anzahl anderer Autos auf der Strecke

    /// true = andere Autos fahren → F1-Logik (lila = Feld-Bestwert, grün = eigener Bestwert)
    public var isFieldMode: Bool { mode == "field" }
}

/// Echte AC-Sektoren (meist 3), alle Zeiten in ms. Array-Index = Sektor (0 = S1).
/// nil in einem Array = (noch) kein Wert. Die Bestzeit der Runde steht in lap.bestLapMs.
public struct SectorData: Decodable, Sendable {
    public let count: Int
    public let current: Int                    // aktueller Sektor (0-basiert)
    public let currentRunningMs: Int?          // läuft gerade im aktuellen Sektor (nil = Sektorstart nicht gesehen)
    public let currentLap: [Int?]              // fertige Sektoren der laufenden Runde
    public let currentResults: [SectorResult]
    public let lastLap: [Int?]                 // komplette letzte Runde (leer, wenn es noch keine gibt)
    public let lastLapResults: [SectorResult]
    public let best: [Int?]                    // beste Zeit je Sektor in dieser Session (nur gültige Runden)
    public let bestLap: [Int?]                 // Sektoren der besten Runde
    public let theoreticalBestMs: Int?         // Summe der besten Sektoren
}

public struct SessionInfo: Decodable, Sendable {
    public let acVersion: String
    public let smVersion: String
    public let car: String
    public let carSkin: String
    public let track: String
    public let trackConfiguration: String
    public let trackLengthM: Double
    public let player: String
    public let numCars: Int
    public let sectorCount: Int
    public let maxRpm: Int
    public let maxFuel: Double
    public let maxPower: Double
    public let maxTorque: Double
    public let hasDrs: Bool
    public let hasErs: Bool
    public let hasKers: Bool
    public let isTimedRace: Bool
    public let fuelRate: Double
    public let tyreRate: Double
    public let damageRate: Double
    /// Temperaturfenster aus den Autodateien (nil, wenn die Bridge sie nicht lesen konnte)
    public let carPhysics: CarPhysics?
}

// MARK: - Autodaten (aus data.acd)

/// Temperaturfenster aus AC's Performance-Kurve, alles in °C.
/// optimal = ≥ 99,5 % vom maximalen Grip, ok = ≥ 98 %
public struct TempWindow: Decodable, Sendable {
    public let peakC: Int
    public let optimalMinC, optimalMaxC: Int
    public let okMinC, okMaxC: Int

    public init(peakC: Int, optimalMinC: Int, optimalMaxC: Int, okMinC: Int, okMaxC: Int) {
        self.peakC = peakC
        self.optimalMinC = optimalMinC; self.optimalMaxC = optimalMaxC
        self.okMinC = okMinC; self.okMaxC = okMaxC
    }
}

public struct TyreCompoundInfo: Decodable, Sendable {
    public let index: Int
    public let name: String
    public let shortName: String
    public let front: TempWindow?
    public let rear: TempWindow?
    public let idealPressureFront: Double?   // psi
    public let idealPressureRear: Double?
}

/// nil pro Achse = Auto hat dort kein Bremstemperatur-Modell
public struct BrakeWindows: Decodable, Sendable {
    public let front: TempWindow?
    public let rear: TempWindow?
}

public struct CarPhysics: Decodable, Sendable {
    public let tyreCompounds: [TyreCompoundInfo]
    public let brakes: BrakeWindows?

    /// Sicherer Zugriff über den Index aus frame.tyres.compoundIndex
    public func compound(at index: Int?) -> TyreCompoundInfo? {
        guard let index, tyreCompounds.indices.contains(index) else { return nil }
        return tyreCompounds[index]
    }
}

public struct BridgeStatus: Decodable, Sendable {
    public let connected: Bool
    public let source: String
    public let gameStatus: String?
    public let streamClients: Int
    public let lastFrameAt: String?
}

// MARK: - WebSocket-Nachricht
//
// TS-Vergleich (Discriminated Union):
//   type BridgeMessage =
//     | { type: "status";    data: BridgeStatus }
//     | { type: "session";   data: SessionInfo | null }
//     | { type: "telemetry"; data: TelemetryFrame }
//
// In Swift ist das ein enum mit "associated values". Den Decoder schreiben wir
// selbst: erst "type" lesen, dann je nachdem "data" als passenden Typ dekodieren.

public enum BridgeMessage: Decodable, Sendable {
    case status(BridgeStatus)
    case session(SessionInfo?)
    case telemetry(TelemetryFrame)
    case unknown(String)

    private enum Keys: String, CodingKey { case type, data }

    public init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: Keys.self)
        let type = try c.decode(String.self, forKey: .type)
        switch type {
        case "status":    self = .status(try c.decode(BridgeStatus.self, forKey: .data))
        case "session":   self = .session(try c.decodeIfPresent(SessionInfo.self, forKey: .data))
        case "telemetry": self = .telemetry(try c.decode(TelemetryFrame.self, forKey: .data))
        default:          self = .unknown(type)
        }
    }
}
