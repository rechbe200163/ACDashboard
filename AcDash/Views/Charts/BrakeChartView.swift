//
//  BrakeChartView.swift
//  AcDash
//
//  Created by Michael Rechberger on 09.10.26.
//


import SwiftUI
import Charts

struct BrakeChartView: View {
    let vm = BrakeChartViewModel()

    var body: some View {
        Chart(vm.samples) {
            AreaMark(x: .value("Zeit", $0.time), y: .value("Bremse", $0.brake))
                .foregroundStyle(.red.opacity(0.3))
            LineMark(x: .value("Zeit", $0.time), y: .value("Bremse", $0.brake))
                .foregroundStyle(.red)
        }
        .chartYScale(domain: 0...100)
        .chartXAxisLabel("s")
        .chartYAxisLabel("%")
        .frame(height: 200)
        .padding()
    }
}

#Preview { BrakeChartView() }
