//
//  JourneyEndView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct JourneyEndView: View {
    @ObservedObject var store = DataStore.shared
    let questID: UUID
    let journeyID: UUID

    @State private var success: Bool = true
    @State private var extractionResolved: Bool = true
    @State private var survivors: Set<UUID> = []
    @State private var fearDelta: Int = 0
    @State private var influenceDelta: Int = 0
    @State private var realmstoneGained: Int = 0

    var body: some View {
        if let qi = store.quests.firstIndex(where: { $0.id == questID }),
           let ji = store.quests[qi].activeJourneys.firstIndex(where: { $0.id == journeyID }) {
            let journey = store.quests[qi].activeJourneys[ji]

            Form {
                Section(header: Text("Result")) {
                    Toggle("Success", isOn: $success)
                    Toggle("Extraction resolved", isOn: $extractionResolved)
                }
                Section(header: Text("Survivors")) {
                    ForEach(journey.selectedHeroIDs, id: \.self) { id in
                        let name = store.quests[qi].heroes.first(where: { $0.id == id })?.name ?? "Unknown"
                        Toggle(name, isOn: Binding(get: { survivors.contains(id) }, set: { v in
                            if v { survivors.insert(id) } else { survivors.remove(id) }
                        }))
                    }
                }
                Section(header: Text("Consequences")) {
                    Stepper("Fear Δ: \(fearDelta)", value: $fearDelta, in: -10...10)
                    Stepper("Influence Δ: \(influenceDelta)", value: $influenceDelta, in: -10...10)
                    Stepper("Realmstone gained: \(realmstoneGained)", value: $realmstoneGained, in: 0...20)
                }

                Button("Finalize Journey") {
                    let cons = Consequence(fearDelta: fearDelta, influenceDelta: influenceDelta, realmstoneGained: realmstoneGained)
                    let record = JourneyRecord(journey: journey, success: success, extractionResolved: extractionResolved, survivors: Array(survivors), consequences: cons, endedAt: Date())
                    store.finishJourney(record, for: questID)
                }
                .buttonStyle(.borderedProminent)
            }
            .navigationTitle("End Journey")
            .onAppear {
                survivors = Set(journey.selectedHeroIDs) // default: all survive
            }
        } else {
            Text("Journey not found")
        }
    }
}
