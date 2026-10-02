//
//  TelemetryViewModel.swift
//  AcDash
//
//  Created by Michael Rechberger on 03.10.26.
//


import Foundation
import Observation
import AcBridgeKit

@MainActor
@Observable
class TelemetryViewModel {
    let source: any TelemetrySource

    init(source: any TelemetrySource) {
        self.source = source
    }
    
    var isConnected: Bool { source.state == .connected }

    var connectionText: String {
        switch source.state {
        case .disconnected:      "Getrennt"
        case .connecting:        "Verbinde…"
        case .connected:         source.status?.connected == false ? "Bridge ok, AC nicht aktiv" : "Verbunden"
        case .failed(let error): "Fehler: \(error)"
        }
    }
    
    var frame: TelemetryFrame? { source.frame }
    var session: SessionInfo?  { source.session }
    var hasData: Bool          { frame != nil }

    static func formatLap(_ ms: Int?) -> String {
        guard let ms, ms > 0 else { return "–:––.–––" }
        return String(format: "%ld:%06.3f", ms / 60_000, Double(ms % 60_000) / 1000)
    }
    
    static func formatDelta(_ ms: Int?) -> String {
        guard let ms, ms > 0 else { return "0:00.000" }
        return String(format: "%ld:%06.3f", ms/60_000, Double(ms % 60_000) / 1000)
    }
}
