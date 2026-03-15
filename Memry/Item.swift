//
//  Item.swift
//  Memry
//
//  Created by Yann Bodson on 16/3/2026.
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
