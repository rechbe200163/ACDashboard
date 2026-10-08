//
//  CardView.swift
//  AcDash
//
//  Created by Michael Rechberger on 03.10.26.
//

import SwiftUI

struct CardView<Content: View>: View {
    let title: String?
    @ViewBuilder let content: Content

    init(title: String? = nil, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            if let title {
                Text(title)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            content
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topLeading) // ZUERST groß machen
        .background(.gray.opacity(0.15), in: .rect(cornerRadius: 16))            // DANN anmalen
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
