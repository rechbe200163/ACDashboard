//
//  SectorsView.swift
//  AcDash
//
//  Created by Michael Rechberger on 08.10.26.
//

import SwiftUI
import AcBridgeKit

struct SectorsView: View {
    let currentLapSectorDeltas: [String]
    var body: some View {
        CardView(title: "Sectors") {
            ForEach(currentLapSectorDeltas, id: \.self) { sectorText in
                Text(sectorText)
                    .font(.system(size: 58, weight: .heavy, design: .rounded).monospacedDigit())
                    .foregroundStyle(.primary)
                Divider()
            }
        }
    }
}

#Preview {
    SectorsView(currentLapSectorDeltas: ["23:456", "35:346", "20:234"])
}
