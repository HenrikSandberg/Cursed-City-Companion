import SwiftUI

struct HeroRow: View {
    let name: String
    let aliveBinding: Binding<Bool>

    var body: some View {
        HStack(spacing: 12) {
            Image(name)
                .resizable()
                .scaledToFill()
                .frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
                .accessibilityHidden(true)
            Toggle(isOn: aliveBinding) {
                Text(name)
            }
        }
    }
}

struct EndJourneyView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID
    @Environment(\.dismiss) private var dismiss

    @State private var wasSuccessful: Bool = true
    @State private var extraction: ExtractionEventDef?
    @State private var survival: [UUID: Bool] = [:]
    @State private var notes: String = ""
    
    let onSaved: (() -> Void)?

    var body: some View {
        if let qIndex = store.quests.firstIndex(where: {$0.id == questId}),
           let active = store.quests[qIndex].activeJourney {

            let defs = ExtractionRegistry.load()

            let previewDelta = (wasSuccessful ? extraction?.onSuccess : extraction?.onFailure)
            let projectedInfluence = store.quests[qIndex].influence + (previewDelta?.influence ?? 0)
            let projectedFear = store.quests[qIndex].fear + (previewDelta?.fear ?? 0)

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

                    VStack(alignment: .leading, spacing: 6) {
                        Text("Consequences preview").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        HStack(spacing: 16) {
                            Label("Influence: \(projectedInfluence)", systemImage: "flame")
                            Label("Fear: \(projectedFear)", systemImage: "exclamationmark.triangle")
                        }.font(.subheadline)
                        Text("This reflects the selected Extraction Event and whether the journey was a success or failure.")
                            .font(.footnote)
                            .foregroundStyle(.secondary)
                    }
                    .ccPanel()

                    ExtractionPicker(defs: defs, selected: $extraction)

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Survival").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        ForEach(active.participants, id: \.self) { hid in
                            if let hero = store.quests[qIndex].heroes.first(where: { $0.id == hid }) {
                                HeroRow(
                                    name: hero.name,
                                    aliveBinding: Binding(
                                        get: { survival[hid, default: true] },
                                        set: { survival[hid] = $0 }
                                    )
                                )
                            }
                        }
                    }.ccPanel()

                    VStack(alignment: .leading) {
                        Text("Notes").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        TextEditor(text: $notes).frame(height: 120)
                    }.ccPanel()

                    Button {
                        save(qIndex: qIndex)
                        // Close End Journey
                        dismiss()
                        // Then ask parent to close Active Journey so we land on Quest Detail
                        DispatchQueue.main.async { onSaved?() }
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
    
    private func awardExperienceAndLevels(qIndex: Int, participants: [UUID], success: Bool) {
        guard success else { return }

        let heroes = store.quests[qIndex].heroes
        let levelsById = Dictionary(uniqueKeysWithValues: heroes.map { ($0.id, $0.level) })
        let partyLevels = participants.compactMap { levelsById[$0] }

        for pid in participants {
            guard var hero = store.quests[qIndex].heroes.first(where: { $0.id == pid }) else { continue }

            var gains = 1
            if let my = levelsById[pid], partyLevels.contains(where: { $0 > my }) {
                gains += 1 // Quick Learners: +1 XP if a higher-level hero is present
            }

            hero.experience += gains
            while hero.experience >= 3 {
                hero.experience -= 3
                hero.level += 1
            }

            if let idx = store.quests[qIndex].heroes.firstIndex(where: { $0.id == pid }) {
                store.quests[qIndex].heroes[idx] = hero
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
        // NOTE: If your Hero model tracks experience/level, this is the right place to increment on success per Rulebook p.34.
        awardExperienceAndLevels(qIndex: qIndex, participants: active.participants, success: cj.wasSuccessful)
        
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
