//
//  BarProgressStyle.swift
//  AcDash
//
//  Created by Michael Rechberger on 03.10.26.
//


import SwiftUI

struct BarProgressStyle: ProgressViewStyle {
    var height: CGFloat = 10
    var color: Color = .accentColor

    func makeBody(configuration: Configuration) -> some View {
        Capsule()
            .fill(.quaternary)                       // Hintergrund
            .frame(height: height)
            .overlay(alignment: .leading) {
                GeometryReader { geo in              // ≈ ActualWidth in WPF
                    Capsule()
                        .fill(.green)
                        .frame(width: geo.size.width * min(max(configuration.fractionCompleted ?? 0, 0), 1))
                }
            }
    }
}

// Damit du .bar(...) schreiben kannst, wie bei .linear oder .circular
extension ProgressViewStyle where Self == BarProgressStyle {
    static func bar(height: CGFloat = 10, color: Color = .accentColor) -> BarProgressStyle {
        BarProgressStyle(height: height, color: color)
    }
}
