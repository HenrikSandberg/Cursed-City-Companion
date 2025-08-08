//
//  CursedCityApp.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

@main
struct CursedCityApp: App {
    var body: some Scene {
        WindowGroup {
            StartView()
                .environmentObject(DataStore.shared)
        }
    }
}
