//
//  GameData.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import Foundation

struct GameData: Codable {
    let journeyTypes: [JourneyTypeData]
    let encounters: [EncounterData]
    let enemyGroups: [EnemyGroupData]
    let counters: CountersData
}

struct JourneyTypeData: Codable {
    let name: String
    let description: String
}

struct EncounterData: Codable {
    let type: String
    let rules: String
}

struct EnemyGroupData: Codable {
    let name: String
    let notes: String
}

struct CountersData: Codable {
    let fear: CounterData
    let influence: CounterData
}

struct CounterData: Codable {
    let max: Int
    let start: Int
    let description: String
}
