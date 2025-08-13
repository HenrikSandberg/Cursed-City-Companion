import SwiftUI

struct NewJourneyView: View {
    @EnvironmentObject private var questManager: QuestManager
    let quest: Quest
    let onStarted: () -> Void
    
    @Environment(\.dismiss) private var dismiss

    @State private var type: JourneyType = .deliverance
    @State private var level: Int = 1
    @State private var enemyGroups: Int = 3
    @State private var selectedHeroes = Set<UUID>()
    
    var body: some View {
        NavigationStack {
            // The main VStack is now wrapped in a ScrollView to ensure
            // all content is accessible, even on smaller screens.
            ScrollView {
                VStack(spacing: 16) {
                    journeySettingsPanel

                    if type == .decapitation {
                        // The placeholder is now replaced with the actual, interactive DecapitationRow.
                        DecapitationRow(quest: quest)
                    }

                    participantsPanel

                    Spacer()
                    
                    Button {
                        startJourney()
                    } label: { Label("Start Journey", systemImage: "play.fill") }
                    .buttonStyle(CCPrimaryButton())
                    .disabled(!canStart)
                }
                .padding()
            }
            .navigationTitle("New Journey")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
            }
            .ccToolbar()
            .ccBackground()
        }
    }

    private var journeySettingsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Picker("Journey Type", selection: $type) {
                ForEach(JourneyType.allCases) { t in Text(t.rawValue).tag(t) }
            }.pickerStyle(.segmented)
            Stepper("Level \(level)", value: $level, in: 1...max(1, quest.partyLevelCap))
            Stepper("Enemy groups \(enemyGroups)", value: $enemyGroups, in: 1...8)
        }.ccPanel()
    }

    private var participantsPanel: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Participants").font(.headline).foregroundStyle(CCTheme.cursedGold)
            ForEach(quest.heroes.filter { $0.alive }) { hero in
                Toggle(isOn: Binding(
                    get: { selectedHeroes.contains(hero.id) },
                    set: { isOn in
                        if isOn {
                            if selectedHeroes.count < 4 { selectedHeroes.insert(hero.id) }
                        } else {
                            selectedHeroes.remove(hero.id)
                        }
                    }
                )) {
                    HeroListRow(hero: hero)
                }
                .disabled(!selectedHeroes.contains(hero.id) && selectedHeroes.count >= 4)
            }
            Text("Select up to 4 heroes (\(selectedHeroes.count)/4).").font(.caption).foregroundStyle(.secondary)
        }.ccPanel()
    }

    private var canStart: Bool {
        guard !selectedHeroes.isEmpty && selectedHeroes.count <= 4 else { return false }
        
        if type == .decapitation {
            // The logic now correctly reads the active target directly from the quest state,
            // which is updated by the interactive DecapitationRow.
            guard let activeID = quest.decapitationState.activeID,
                  let def = DecapitationRegistry.all.first(where: { $0.id == activeID })
            else { return false }
            
            let participatingHeroes = quest.heroes.filter { selectedHeroes.contains($0.id) }
            return participatingHeroes.allSatisfy { $0.level >= def.requiredPartyLevel }
        }
        
        return true
    }

    private func startJourney() {
        // The manager is now the single point of truth for starting a journey.
        questManager.startJourney(
            questId: quest.id,
            type: type,
            level: level,
            enemyGroups: enemyGroups,
            participants: selectedHeroes
        )
        
        onStarted()
        dismiss()
    }
}
