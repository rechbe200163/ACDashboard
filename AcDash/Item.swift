//
//  Item.swift
//  AcDash
//
//  Created by Michael Rechberger on 02.10.26.
//

import Foundation
import SwiftData

@Model
final class Item {
    var timestamp: Date
    
    init(timestamp: Date) {
        self.timestamp = timestamp
    }
}
