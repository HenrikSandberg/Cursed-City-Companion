//
//  CompletedJourneyDetailView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct CompletedJourneyDetailView: View {
    // This view now only needs the specific journey and the heroes from the quest
    // to display all necessary information.
    let journey: CompletedJourney
    let quest: Quest

    // Helper to get hero names from their IDs for the participants list.
    private func heroName(for id: UUID) -> String {
        quest.heroes.first { $0.id == id }?.name ?? "Unknown Hero"
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Journey Summary
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(journey.type.rawValue) • Level \(journey.level)").font(.title2.weight(.bold))
                    Text("\(journey.startedAt.formatted(date: .abbreviated, time: .shortened)) → \(journey.endedAt.formatted(date: .abbreviated, time: .shortened))")
                        .font(.caption).foregroundStyle(.secondary)
                    Text(journey.wasSuccessful ? "Success" : "Failed").font(.headline).foregroundStyle(journey.wasSuccessful ? .green : CCTheme.bloodRed)
                }.ccPanel()

                // Extraction Event Details
                if let result = journey.extractionResult {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Extraction Event").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        Text(result.name).font(.subheadline.weight(.semibold))
                        Text("Δ Influence \(result.applied.influence >= 0 ? "+" : "")\(result.applied.influence) • Δ Fear \(result.applied.fear >= 0 ? "+" : "")\(result.applied.fear)")
                            .font(.caption).foregroundStyle(CCTheme.parchment)
                    }.ccPanel()
                }
                
                // Participants List
                VStack(alignment: .leading, spacing: 6) {
                    Text("Participants").font(.headline).foregroundStyle(CCTheme.cursedGold)
                    ForEach(journey.participants, id: \.self) { heroId in
                        Text(heroName(for: heroId))
                    }
                }.ccPanel()

                // Notes Section
                if let notes = journey.notes, !notes.isEmpty {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Notes").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        Text(notes)
                    }.ccPanel()
                }
                
                Spacer(minLength: 20)
            }.padding()
        }
        .navigationTitle("Journey Result")
        .ccBackground().ccToolbar()
    }
}
