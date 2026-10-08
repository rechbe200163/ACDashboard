//
//  AcDashApp.swift
//  AcDash
//
//  Created by Michael Rechberger on 02.10.26.
//

import SwiftUI
import AcBridgeKit

@main
struct AcDashApp: App {
    @State private var client = AcBridgeClient(host: "10.0.0.23")

    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(client)
                .task { client.connect() }
                .onAppear {
                    UIApplication.shared.isIdleTimerDisabled = true
                }
                .onDisappear {
                    UIApplication.shared.isIdleTimerDisabled = false
                }
        }
    }
}
