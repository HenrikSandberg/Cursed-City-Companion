import SwiftUI

struct NewJourneyView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID
    let onStarted: (() -> Void)?
    @Environment(\.dismiss) private var dismiss

    @State private var type: JourneyType = .deliverance
    @State private var level: Int = 1
    @State private var enemyGroups: Int = 3
    @State private var selectedHeroes = Set<UUID>()

    init(questId: UUID, onStarted: (() -> Void)? = nil) {
        self.questId = questId
        self.onStarted = onStarted
    }

    var body: some View {
        if let qIndex = store.quests.firstIndex(where: {$0.id == questId}) {
            let quest = store.quests[qIndex]
            NavigationStack {
                VStack(spacing: 16) {
                    // Type & level
                    VStack(alignment: .leading, spacing: 8) {
                        Picker("Journey Type", selection: $type) {
                            ForEach(JourneyType.allCases) { t in
                                Text(t.rawValue).tag(t)
                            }
                        }.pickerStyle(.segmented)
                        Stepper("Level \(level)", value: $level, in: 1...max(1, quest.partyLevelCap))
                        Stepper("Enemy groups \(enemyGroups)", value: $enemyGroups, in: 1...8)
                    }.ccPanel()

                    if type == .decapitation {
                        DecapitationRow(state: Binding(get: { store.quests[qIndex].decapitationState }, set: { store.quests[qIndex].decapitationState = $0 }), heroes: quest.heroes)
                            .overlay(alignment: .bottomLeading) {
                                Text("Pick a target above.").font(.caption).padding(8).foregroundStyle(.secondary)
                            }
                    }

                    // Participants
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Participants").font(.headline).foregroundStyle(CCTheme.cursedGold)
                        ForEach(quest.heroes) { h in
                            let disabled = !h.alive
                            HStack {
                                Toggle(isOn: Binding(
                                    get: { selectedHeroes.contains(h.id) },
                                    set: { isOn in
                                        if isOn {
                                            if !selectedHeroes.contains(h.id) && selectedHeroes.count < 4 {
                                                selectedHeroes.insert(h.id)
                                            }
                                        } else {
                                            selectedHeroes.remove(h.id)
                                        }
                                    }
                                )) {
                                    HStack(spacing: 8) {
                                        Image(h.name)
                                            .resizable()
                                            .scaledToFill()
                                            .frame(width: 28, height: 28)
                                            .clipShape(Circle())
                                            .overlay(Circle().stroke(.secondary.opacity(0.3), lineWidth: 1))
                                        Text(h.name)
                                        if disabled { Text("(fallen)").foregroundStyle(CCTheme.bloodRed) }
                                    }
                                }
                                .disabled(disabled || (!selectedHeroes.contains(h.id) && selectedHeroes.count >= 4))
                            }
                        }
                        Text("Select exactly 4 heroes (\(selectedHeroes.count)/4).").font(.caption).foregroundStyle(.secondary)
                    }.ccPanel()

                    Spacer()
                    Button {
                        start(qIndex: qIndex)
                        dismiss()
                    } label: { Label("Start Journey", systemImage: "play.fill") }
                    .buttonStyle(CCPrimaryButton())
                    .disabled(!canStart(quest: quest))
                }
                .padding()
                .navigationTitle("New Journey")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) { Button("Cancel") { dismiss() } }
                }
                .ccToolbar()
                .ccBackground()
            }
        }
    }

    private func canStart(quest: Quest) -> Bool {
        guard selectedHeroes.count == 4 else { return false }
        if type == .decapitation {
            guard let active = quest.decapitationState.activeID,
                  let def = DecapitationRegistry.all.first(where: {$0.id == active}) else { return false }
            let eligible = quest.heroes.allSatisfy { $0.level == def.requiredPartyLevel && $0.alive }
            return eligible
        }
        return true
    }

    private func start(qIndex: Int) {
        var quest = store.quests[qIndex]
        let participants = Array(selectedHeroes)
        let entries: [InitiativeEntry] =
            participants.map { id in
                let name = store.quests[qIndex].heroes.first(where: { $0.id == id })?.name ?? "Hero"
                return InitiativeEntry(heroId: id, label: name)
            } +
            (0..<enemyGroups).map { i in InitiativeEntry(isEnemy: true, label: "Enemy \(i+1)") }
        let turn = Turn(entries: entries)
        quest.activeJourney = ActiveJourney(type: type, level: level, enemyGroups: enemyGroups, participants: participants, turns: [turn])
        store.quests[qIndex] = quest
        onStarted?()
    }
}

#if DEBUG
#Preview("New Journey – Empty Store") {
    NewJourneyView(questId: UUID())
        .environmentObject(Store())
}
#endif
