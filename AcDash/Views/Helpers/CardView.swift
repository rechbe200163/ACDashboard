//
//  CardView.swift
//  AcDash
//
//  Created by Michael Rechberger on 03.10.26.
//

import SwiftUI

struct CardView<Content:View>: View {
    @ViewBuilder let content: Content
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            content
        }
        .padding()
        .frame(alignment: .leading)
        .background(.quaternary, in: RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    CardView {
        VStack {
            ForEach(0..<2) {_ in
                HStack(spacing: 16) {
                    ForEach(0..<2) {_ in
                        CardView() {
                            HStack {
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(.green)
                                    .frame(width: 12, height: 120)
                                VStack(alignment: .leading) {
                                    Text("FL")
                                        .font(.title2)
                                        .foregroundStyle(.secondary)
                                    Text("88°")
                                        .font(.title.bold().monospacedDigit())
                                    Text("27.1 psi")
                                        .font(.subheadline)
                                    ProgressView(value: 0.90)
                                        .progressViewStyle(.bar(height: 25, color: .green))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
