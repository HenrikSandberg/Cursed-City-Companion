//
//  Journey.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import Foundation


struct Journey: Identifiable, Codable, Hashable {
    enum Status: String, Codable, CaseIterable {
        case notStarted = "Ikke startet"
        case completed = "Fullført"
        case failed = "Feilet"
    }

    let id: UUID
    var name: String
    var type: JourneyType
    var status: Status = .notStarted
    var encounteredEnemies: [EnemyGroup] = [] // Fiender møtt på denne reisen
}

// Representerer en aktivering i en runde (enten en helt eller en fiendegruppe).
struct Activation: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let isHero: Bool
}
