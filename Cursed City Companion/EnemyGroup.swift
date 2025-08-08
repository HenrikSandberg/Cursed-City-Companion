//
//  EnemyGroup.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import Foundation


struct EnemyGroup: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var count: Int
}
