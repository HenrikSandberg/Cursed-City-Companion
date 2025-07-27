//
//  Item.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
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
