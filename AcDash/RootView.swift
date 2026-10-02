//
//  RootView.swift
//  AcDash
//
//  Created by Michael Rechberger on 04.10.26.
//

import SwiftUI
import AcBridgeKit

struct RootView: View {
    @State private var selection: AppSection? = .live
    
    var body: some View {
        NavigationSplitView {
            // links: Sidebar
            List(AppSection.allCases, selection: $selection) { section in
                NavigationLink(value: section) {
                    Label(section.title, systemImage: section.icon)
                }
            }
            .navigationTitle("AcDash")
        } detail: {
            // rechts: Segmente fix oben, darunter die gewählte Seite
            VStack(spacing: 0) {                
                NavigationStack {
                    page
                        .navigationTitle(selection?.title ?? "")
                }
            }
        }
    }
    
    @ViewBuilder
    private var page: some View {
        switch selection {
        case .live, nil: LiveView()
        case .tyres:          Text("Reifen")         // später TyreView()
        case .sectors:        Text("Sektoren")
        case .settings:       Text("Einstellungen")
        }
    }
}

#Preview {
    RootView()
        .environment(AcBridgeClient(host: "localhost"))
}
