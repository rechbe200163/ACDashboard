//
//  AppSection.swift
//  AcDash
//
//  Created by Michael Rechberger on 04.10.26.
//


enum AppSection: String, CaseIterable, Identifiable, Hashable {
    case tyres, sectors, settings, live

    var id: Self { self }

    var title: String {
        switch self {
        case .live: "Live"
        case .tyres:     "Reifen"
        case .sectors:   "Sektoren"
        case .settings:  "Einstellungen"
        }
    }

    var icon: String {              // SF Symbols
        switch self {
        case .live:      "dot.radiowaves.left.and.right"
        case .tyres:     "circle.circle"
        case .sectors:   "flag.checkered"
        case .settings:  "gearshape"
        }
    }
}
