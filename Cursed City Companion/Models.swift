//
//  Models.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import Foundation
import SwiftUI

enum JourneyType: String, Codable, CaseIterable {
    case hunt, scavenge, decapitation, deliverance
}

struct Hero: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var level: Int
    var alive: Bool = true
    var items: [String] = []
    var treasureCards: [String] = []
    var realmstone: Int = 0
    // add more fields: class, traits, vit/def/agi etc as needed
}

struct Quest: Identifiable, Codable {
    var id: UUID = UUID()
    var title: String
    var fear: Int
    var influence: Int
    var decapitationTokens: Int
    var heroes: [Hero]
    var activeJourneys: [Journey] = []
    var history: [JourneyRecord] = []
}

struct Journey: Identifiable, Codable {
    var id: UUID = UUID()
    var type: JourneyType
    var level: Int
    var selectedHeroIDs: [UUID]
    var enemyGroups: Int
    var initiative: [InitiativeEntry] = []
    var startedAt: Date = Date()
    var isActive: Bool = true
}

struct InitiativeEntry: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var isHero: Bool
    var orderIndex: Int
}

struct JourneyRecord: Identifiable, Codable {
    var id: UUID = UUID()
    var journey: Journey
    var success: Bool
    var extractionResolved: Bool
    var survivors: [UUID]
    var consequences: Consequence
    var endedAt: Date = Date()
}

struct Consequence: Codable {
    var fearDelta: Int
    var influenceDelta: Int
    var realmstoneGained: Int
    // optionally: items gained, hero XP changes etc
}
