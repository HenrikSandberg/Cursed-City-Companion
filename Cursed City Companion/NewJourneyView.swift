//
//  NewJourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct NewJourneyView: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var store = DataStore.shared
    let questID: UUID

    @State private var selectedHeroes: Set<UUID> = []
    @State private var journeyType: JourneyType = .hunt
    @State private var journeyLevel: Int = 1
    @State private var enemyGroups: Int = 1
    @State private var selectedEnemyGroups: [String] = []

    var body: some View {
        NavigationView {
            Form {
                if let types = store.gameData?.journeyTypes {
                    Picker("Type", selection: $journeyType) {
                        ForEach(types, id: \.name) { type in
                            Text(type.name)
                        }
                    }
                    .pickerStyle(SegmentedPickerStyle())
                }

                Section(header: Text("Level")) {
                    Stepper("Level \(journeyLevel)", value: $journeyLevel, in: 1...5)
                }

                Section(header: Text("Select Heroes")) {
                    if let quest = store.quests.first(where: { $0.id == questID }) {
                        ForEach(quest.heroes) { hero in
                            if hero.alive {
                                Toggle(hero.name, isOn: Binding(
                                    get: { selectedHeroes.contains(hero.id) },
                                    set: { val in
                                        if val { selectedHeroes.insert(hero.id) }
                                        else { selectedHeroes.remove(hero.id) }
                                    }
                                ))
                            }
                        }
                    }
                }

                Section(header: Text("Enemy Groups")) {
                    if let groups = store.gameData?.enemyGroups {
                        ForEach(groups, id: \.name) { group in
                            Toggle(group.name, isOn: Binding(
                                get: { selectedEnemyGroups.contains(group.name) },
                                set: { val in
                                    if val { selectedEnemyGroups.append(group.name) }
                                    else { selectedEnemyGroups.removeAll { $0 == group.name } }
                                }
                            ))
                        }
                    } else {
                        Stepper("\(enemyGroups) group\(enemyGroups > 1 ? "s" : "")", value: $enemyGroups, in: 1...8)
                    }
                }
            }
            .navigationTitle("New Journey")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Start") {
                        startJourney()
                        dismiss()
                    }
                    .disabled(selectedHeroes.isEmpty)
                }
            }
        }
    }

    func startJourney() {
        guard let quest = store.quests.first(where: { $0.id == questID }) else { return }

        // Build initiative list: heroes first, then enemies
        var initiative: [InitiativeEntry] = []
        var orderIndex = 0
        for heroID in selectedHeroes {
            if let hero = quest.heroes.first(where: { $0.id == heroID }) {
                initiative.append(InitiativeEntry(name: hero.name, isHero: true, orderIndex: orderIndex))
                orderIndex += 1
            }
        }
        
        for groupName in selectedEnemyGroups {
            initiative.append(InitiativeEntry(name: groupName, isHero: false, orderIndex: orderIndex))
            orderIndex += 1
        }

        let journey = Journey(
            type: journeyType,
            level: journeyLevel,
            selectedHeroIDs: Array(selectedHeroes),
            enemyGroups: enemyGroups,
            initiative: initiative
        )

        store.addJourney(journey, to: questID)
    }
}
