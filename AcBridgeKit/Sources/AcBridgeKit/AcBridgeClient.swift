import Foundation
import Observation

/// Verbindet sich mit der AC Bridge: WebSocket für den Live-Stream, dazu REST-Helper.
///
/// TS-Vergleich: Das ist ungefähr ein Angular-Service mit Signals.
/// - `@Observable`  → jede `var` ist wie ein Signal; SwiftUI-Views, die sie lesen, rendern automatisch neu
/// - `@MainActor`   → alles läuft auf dem UI-Thread (wie im Browser: ein Thread, async/await dazwischen)
///
/// Verwendung:
///   let client = AcBridgeClient(host: "192.168.0.42")
///   client.connect()
///   client.frame?.speedKmh
@MainActor
@Observable
public final class AcBridgeClient {

    public enum ConnectionState: Equatable, Sendable {
        case disconnected
        case connecting
        case connected
        case failed(String)
    }

    // MARK: Öffentlicher Zustand (wie Signals)

    public private(set) var state: ConnectionState = .disconnected
    public private(set) var status: BridgeStatus?
    public private(set) var session: SessionInfo?
    public private(set) var frame: TelemetryFrame?

    // MARK: Konfiguration

    public var host: String
    public var port: Int
    public var hz: Int

    @ObservationIgnored private var socket: URLSessionWebSocketTask?
    @ObservationIgnored private var loop: Task<Void, Never>?      // ≈ eine Subscription, die man canceln kann
    private let decoder = JSONDecoder()

    public init(host: String, port: Int = 5080, hz: Int = 30) {
        self.host = host
        self.port = port
        self.hz = hz
    }

    private var baseURL: String { "\(host):\(port)" }

    // MARK: - WebSocket

    /// Verbindet und verbindet automatisch neu, bis `disconnect()` aufgerufen wird.
    public func connect() {
        guard loop == nil else { return }   // schon verbunden
        loop = Task { await runLoop() }
    }

    public func disconnect() {
        loop?.cancel()
        loop = nil
        socket?.cancel(with: .normalClosure, reason: nil)
        socket = nil
        state = .disconnected
    }

    /// Stream-Rate zur Laufzeit ändern, schickt { "hz": 10 } an die Bridge.
    public func setRate(_ newHz: Int) {
        hz = newHz
        socket?.send(.string("{\"hz\":\(newHz)}")) { _ in }
    }

    private func runLoop() async {
        // while (!cancelled) { verbinden; lesen bis Fehler; 2s warten; nochmal }
        while !Task.isCancelled {
            guard let url = URL(string: "ws://\(baseURL)/ws/telemetry?hz=\(hz)") else {
                state = .failed("Ungültige Adresse")
                return
            }

            state = .connecting
            let ws = URLSession.shared.webSocketTask(with: url)
            socket = ws
            ws.resume()

            do {
                // Jede receive()-Runde wartet auf genau eine Nachricht.
                // Ähnlich wie: for await (const msg of socket) { ... }
                while !Task.isCancelled {
                    let message = try await ws.receive()
                    if state != .connected { state = .connected }
                    handle(message)
                }
            } catch {
                if Task.isCancelled { break }
                state = .failed(error.localizedDescription)
            }

            ws.cancel(with: .goingAway, reason: nil)
            try? await Task.sleep(for: .seconds(2))   // kurz warten, dann neu verbinden
        }
    }

    private func handle(_ message: URLSessionWebSocketTask.Message) {
        // Die Bridge schickt Text-Frames; Data nehmen wir sicherheitshalber auch.
        let data: Data
        switch message {
        case .string(let text): data = Data(text.utf8)
        case .data(let bytes):  data = bytes
        @unknown default:       return
        }

        do {
            switch try decoder.decode(BridgeMessage.self, from: data) {
            case .telemetry(let f): frame = f
            case .session(let s):   session = s
            case .status(let s):    status = s
            case .unknown:          break
            }
        } catch {
            // Passiert, wenn Modell und JSON nicht zusammenpassen → Feldname/Typ in AcModels.swift prüfen
            print("Decode-Fehler:", error)
        }
    }

    // MARK: - REST
    //
    // TS-Vergleich:  async get<T>(path: string): Promise<T | null>
    // `throws` heißt: kann einen Fehler werfen, Aufrufer schreibt `try await`.

    public func get<T: Decodable>(_ path: String, as type: T.Type) async throws -> T? {
        guard let url = URL(string: "http://\(baseURL)\(path)") else { throw URLError(.badURL) }
        let (data, response) = try await URLSession.shared.data(from: url)

        guard let http = response as? HTTPURLResponse else { throw URLError(.badServerResponse) }
        if http.statusCode == 204 { return nil }                     // keine Daten (z. B. AC nicht auf der Strecke)
        guard (200..<300).contains(http.statusCode) else { throw URLError(.badServerResponse) }

        return try decoder.decode(T.self, from: data)
    }

    public func fetchStatus() async throws -> BridgeStatus? {
        try await get("/api/status", as: BridgeStatus.self)
    }

    public func fetchSession() async throws -> SessionInfo? {
        try await get("/api/session", as: SessionInfo.self)
    }

    public func fetchTelemetry() async throws -> TelemetryFrame? {
        try await get("/api/telemetry", as: TelemetryFrame.self)
    }
}
