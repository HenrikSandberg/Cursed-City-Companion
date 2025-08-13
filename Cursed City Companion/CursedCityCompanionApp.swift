//
//  CursedCityCompanionApp.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import SwiftUI

@main
struct CursedCityCompanionApp: App {
    // The QuestManager is now the single source of truth for all quest data.
    @StateObject private var questManager = QuestManager()
    // AppSettings can remain as it is for managing UI state or other settings.
    // @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                // The manager is injected into the environment for all child views to access.
                StartScreen()
            }
            .environmentObject(questManager)
            .preferredColorScheme(.dark)
        }
    }
}

// A simple placeholder for AppSettings.
// You can expand this for any app-wide settings you might need.
// class AppSettings: ObservableObject {}
