//
//  CampaignData.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//


struct CampaignData: Codable {
    var fearLevel: Int
    var influenceLevel: Int
    var heroes: [Hero]
    var journeys: [Journey]
    var defeatedBosses: [String]
    var successfulDecapitations: Int
}
