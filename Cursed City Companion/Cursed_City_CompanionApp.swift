//
//  Cursed_City_CompanionApp.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import SwiftUI
import SwiftData

@main
struct Cursed_City_CompanionApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(sharedModelContainer)
    }
}
