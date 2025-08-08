//
//  PersistenceManager.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import Foundation


// MARK: - Data Persistence Manager
// Denne klassen håndterer lagring og lasting av kampanjedata til enhetens minne.
class PersistenceManager {
    static let campaignDataKey = "CursedCityCampaignData"

    // Lagrer kampanjedata som JSON.
    static func saveCampaign(data: CampaignData) {
        if let encodedData = try? JSONEncoder().encode(data) {
            UserDefaults.standard.set(encodedData, forKey: campaignDataKey)
            print("Campaign data saved!")
        }
    }

    // Laster kampanjedata. Returnerer nil hvis ingen data er lagret.
    static func loadCampaign() -> CampaignData? {
        if let savedData = UserDefaults.standard.data(forKey: campaignDataKey) {
            if let decodedData = try? JSONDecoder().decode(CampaignData.self, from: savedData) {
                print("Campaign data loaded!")
                return decodedData
            }
        }
        print("No saved data found. Starting new campaign.")
        return nil
    }
}
