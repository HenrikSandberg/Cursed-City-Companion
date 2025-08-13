//
//  CursedCityCompanionApp.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import SwiftUI

@main
struct CursedCityCompanionApp: App {
    @StateObject private var store = Store()
    @StateObject private var settings = AppSettings()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                StartScreen()
            }
            .environmentObject(store)
            .environmentObject(settings)
            .preferredColorScheme(.dark)
        }
    }
}
