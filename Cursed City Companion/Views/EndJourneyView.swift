import SwiftUI

struct EndJourneyView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var wasSuccessful: Bool = true
    @State private var extraction: ExtractionEventDef?
    @State private var survival: [UUID: Bool] = [:]
    @State private var notes: String = ""

    var body: some View {
        if let qIndex = store.quests.firstIndex(where: {$0.id == questId}),
           let active = store.quests[qIndex].activeJourney {

            let defs = ExtractionRegistry.load()

            ScrollView {
                VStack(spacing: 16) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Outcome").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        Picker("Result", selection: $wasSuccessful) {
                            Text("Success").tag(true)
                            Text("Failed").tag(false)
                        }
                        .pickerStyle(.segmented)
                    }.ccPanel()

                    ExtractionPicker(defs: defs, selected: $extraction)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Survival").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        ForEach(active.participants, id: \.self) { hid in
                            if let hero = store.quests[qIndex].heroes.first(where: {$0.id == hid}) {
                                Toggle(isOn: Binding(get: { survival[hid, default: true] },
                                                    set: { survival[hid] = $0 })) {
                                    Text(hero.name)
                                }
                            }
                        }
                    }.ccPanel()

                    VStack(alignment: .leading) {
                        Text("Notes").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        TextEditor(text: $notes).frame(height: 120)
                    }.ccPanel()

                    Button {
                        save(qIndex: qIndex)
                        dismiss()
                    } label: { Label("Save Journey", systemImage: "checkmark.circle.fill") }
                    .buttonStyle(CCPrimaryButton())
                    .disabled(extraction == nil)

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationTitle("End Journey")
            .ccBackground()
            .ccToolbar()
            .onAppear {
                // Default survival to true for all participants
                for id in active.participants { survival[id] = true }
            }
        }
    }

    private func save(qIndex: Int) {
        var quest = store.quests[qIndex]
        guard let active = quest.activeJourney,
              let extraction = extraction else { return }

        let delta = wasSuccessful ? extraction.onSuccess : extraction.onFailure
        quest.influence += delta.influence
        quest.fear += delta.fear

        for hid in active.participants {
            if survival[hid] == false {
                if let idx = quest.heroes.firstIndex(where: {$0.id == hid}) {
                    quest.heroes[idx].alive = false
                }
            }
        }

        let cj = CompletedJourney(
            id: active.id,
            type: active.type,
            level: active.level,
            enemyGroups: active.enemyGroups,
            participants: active.participants,
            startedAt: active.startedAt,
            endedAt: Date(),
            wasSuccessful: wasSuccessful,
            extractionResult: ExtractionEventResult(id: extraction.id, name: extraction.name, applied: delta, at: Date(), journeyId: active.id),
            notes: notes.isEmpty ? nil : notes
        )
        quest.completedJourneys.insert(cj, at: 0)
        quest.lastExtraction = cj.extractionResult

        quest.activeJourney = nil

        if active.type == .decapitation, wasSuccessful {
            if let id = quest.decapitationState.activeID {
                quest.decapitationState.completedIDs.insert(id)
                quest.decapitationState.activeID = nil
                let set2: Set<String> = ["captain_of_the_damned", "shuffling_horrors"]
                let set3: Set<String> = ["whispers_in_the_dark", "family_ties"]
                var cap = 1
                if quest.decapitationState.completedIDs.contains("fell_guardian") { cap = 2 }
                if quest.decapitationState.completedIDs.isSuperset(of: set2) { cap = 3 }
                if quest.decapitationState.completedIDs.isSuperset(of: set3) { cap = 4 }
                quest.partyLevelCap = cap
            }
        }

        store.quests[qIndex] = quest
    }
}
