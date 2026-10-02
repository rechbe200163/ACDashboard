//
//  TelemetrySource.swift
//  AcDash
//
//  Created by Michael Rechberger on 03.10.26.
//


import AcBridgeKit

@MainActor
protocol TelemetrySource: AnyObject {
    var state: AcBridgeClient.ConnectionState { get }
    var status: BridgeStatus? { get }
    var session: SessionInfo? { get }
    var frame: TelemetryFrame? { get }
}

extension AcBridgeClient: TelemetrySource {}