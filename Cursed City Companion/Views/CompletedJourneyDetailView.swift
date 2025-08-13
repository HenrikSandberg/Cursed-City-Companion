//
//  CompletedJourneyDetailView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct CompletedJourneyDetailView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID
    let journeyId: UUID

    var body: some View {
        if let qIndex = store.quests.firstIndex(where: {$0.id == questId}),
           let j = store.quests[qIndex].completedJourneys.first(where: {$0.id == journeyId}) {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text("\(j.type.rawValue) • Level \(j.level)").font(.title2.weight(.bold))
                        Text("\(j.startedAt.formatted(date: .abbreviated, time: .shortened)) → \(j.endedAt.formatted(date: .abbreviated, time: .shortened))")
                            .font(.caption).foregroundStyle(.secondary)
                        Text(j.wasSuccessful ? "Success" : "Failed").font(.headline).foregroundStyle(j.wasSuccessful ? .green : CCTheme.bloodRed)
                    }.ccPanel()

                    if let r = j.extractionResult {
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Extraction Event").font(.headline).foregroundStyle(CCTheme.cursedGold)
                            Text(r.name).font(.subheadline.weight(.semibold))
                            Text("Δ Influence \(r.applied.influence >= 0 ? "+" : "")\(r.applied.influence) • Δ Fear \(r.applied.fear >= 0 ? "+" : "")\(r.applied.fear)")
                                .font(.caption).foregroundStyle(CCTheme.parchment)
                        }.ccPanel()
                    }

                    if let notes = j.notes {
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
        } else {
            Text("Journey not found")
        }
    }
}
