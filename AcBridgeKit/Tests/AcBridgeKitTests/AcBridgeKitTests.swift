import Foundation
import Testing
@testable import AcBridgeKit

// Echte Nachrichten aus der Bridge (Mock-Modus). Läuft mit `swift test` im Terminal oder in VS Code.

@Test func decodesTelemetry() throws {
    let msg = try JSONDecoder().decode(BridgeMessage.self, from: Data(Fixtures.telemetry.utf8))
    guard case .telemetry(let frame) = msg else {
        Issue.record("Erwartet .telemetry, bekommen: \(msg)")
        return
    }
    #expect(frame.speedKmh > 0)
    #expect(frame.status == "live")
    #expect(frame.tyres.coreTemp.fl > 0)
}

@Test func decodesSession() throws {
    let msg = try JSONDecoder().decode(BridgeMessage.self, from: Data(Fixtures.session.utf8))
    guard case .session(let session) = msg else {
        Issue.record("Erwartet .session")
        return
    }
    #expect(session?.track == "ks_red_bull_ring")
}

@Test func decodesEmptySession() throws {
    let msg = try JSONDecoder().decode(BridgeMessage.self, from: Data(#"{"type":"session","data":null}"#.utf8))
    guard case .session(let session) = msg else {
        Issue.record("Erwartet .session")
        return
    }
    #expect(session == nil)
}

@Test func decodesStatus() throws {
    let msg = try JSONDecoder().decode(BridgeMessage.self, from: Data(Fixtures.status.utf8))
    guard case .status(let status) = msg else {
        Issue.record("Erwartet .status")
        return
    }
    #expect(status.connected)
}

@Test(arguments: [(-1, "R"), (0, "N"), (3, "3")])
func gearLabel(gear: Int, expected: String) throws {
    var json = try JSONSerialization.jsonObject(with: Data(Fixtures.telemetry.utf8)) as! [String: Any]
    var data = json["data"] as! [String: Any]
    data["gear"] = gear
    json["data"] = data
    let msg = try JSONDecoder().decode(BridgeMessage.self, from: JSONSerialization.data(withJSONObject: json))
    guard case .telemetry(let frame) = msg else { Issue.record("kein Frame"); return }
    #expect(frame.gearLabel == expected)
}

enum Fixtures {
    static let telemetry = #"{"type":"telemetry","data":{"seq":208,"timestamp":"2026-10-01T06:15:29.1998342+00:00","status":"live","session":"practice","flag":"none","speedKmh":230.56387,"rpm":4056,"gear":6,"throttle":1,"brake":0,"clutch":1,"steerAngle":0.2923912,"fuel":59.557888,"turboBoost":0,"tc":0.2,"abs":0.3,"brakeBias":0.58,"drsAvailable":false,"drsEnabled":false,"pitLimiterOn":false,"gForce":{"lateral":1.3157604,"longitudinal":0.817051,"vertical":1},"tyres":{"coreTemp":{"fl":90.043915,"fr":90.45956,"rl":85.85571,"rr":80.465126},"innerTemp":{"fl":97.88456,"fr":98.369484,"rl":92.99833,"rr":86.70932},"middleTemp":{"fl":91.043915,"fr":91.45956,"rl":86.85571,"rr":81.465126},"outerTemp":{"fl":85.043915,"fr":85.45956,"rl":80.85571,"rr":75.465126},"pressure":{"fl":28.00439,"fr":28.045956,"rl":27.585571,"rr":27.046513},"wear":{"fl":98.16813,"fr":98.181984,"rl":98.02853,"rr":97.84884},"slip":{"fl":0.08362608,"fr":0.08639707,"rl":0.055704758,"rr":0.019767527},"load":{"fl":4004.391,"fr":4045.956,"rl":3585.5713,"rr":3046.513},"compound":"Semislick"},"brakeTemp":{"fl":366.81305,"fr":368.19852,"rl":352.8524,"rr":334.88376},"suspensionTravel":{"fl":0.05260978,"fr":0.053648897,"rl":0.042139284,"rr":0.028662821},"lap":{"completedLaps":0,"position":1,"currentLapMs":3328,"lastLapMs":0,"bestLapMs":0,"currentSector":0,"lastSectorMs":0,"numberOfLaps":0,"trackPosition":0.04359989,"sessionTimeLeftMs":-1,"isInPit":false,"isInPitLane":false},"carCoordinates":[577.62646,0,108.21303],"airTemp":24,"roadTemp":32,"surfaceGrip":0.98,"carDamage":[0,0,0,0,0]}}"#
    static let session = #"{"type":"session","data":{"acVersion":"mock","smVersion":"1.7","car":"ks_porsche_911_gt3_r_2016","carSkin":"mock","track":"ks_red_bull_ring","trackConfiguration":"layout_gp","trackLengthM":4000,"player":"Michael","numCars":1,"sectorCount":3,"maxRpm":9000,"maxFuel":120,"maxPower":368000,"maxTorque":480,"hasDrs":false,"hasErs":false,"hasKers":false,"isTimedRace":false,"fuelRate":1,"tyreRate":1,"damageRate":1}}"#
    static let status = #"{"type":"status","data":{"connected":true,"source":"Mock","gameStatus":"live","streamClients":0,"lastFrameAt":"2026-10-01T06:15:29.2991792+00:00"}}"#
}
