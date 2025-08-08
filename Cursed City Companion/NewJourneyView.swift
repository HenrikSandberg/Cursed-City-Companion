import SwiftUI

struct NewJourneyView: View {
    let heroes: [Hero]
    var onCommit: (Journey) -> Void

    @State private var selectedHeroIDs: Set<UUID> = []
    @State private var enemyGroups: Double = 2
    @State private var journeyType: JourneyType = .hunt
    @State private var journeyLevel: Int = 1

    @State private var selectedHuntMap: HuntMap = .alleyways
    @State private var selectedScavengeMap: ScavengeMap = .abandonedMarketplace

    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Journey Details").foregroundColor(.cursedGold)) {
                    Picker("Journey Type", selection: $journeyType) {
                        ForEach(JourneyType.allCases, id: \.self) {
                            Text($0.rawValue)
                        }
                    }

                    // Conditionally show the map picker
                    if journeyType == .hunt {
                        Picker("Map", selection: $selectedHuntMap) {
                            ForEach(HuntMap.allCases) { map in
                                Text(map.rawValue).tag(map)
                            }
                        }
                    } else if journeyType == .scavenge {
                        Picker("Map", selection: $selectedScavengeMap) {
                            ForEach(ScavengeMap.allCases) { map in
                                Text(map.rawValue).tag(map)
                            }
                        }
                    }

                    Stepper("Journey Level: \(journeyLevel)", value: $journeyLevel, in: 1...4)
                    Stepper("Enemy Groups: \(Int(enemyGroups))", value: $enemyGroups, in: 1...10)
                }

                Section(header: Text("Select Heroes").foregroundColor(.cursedGold)) {
                    ForEach(heroes) { hero in
                        if hero.isAlive {
                            MultipleSelectionRow(
                                title: hero.name,
                                isSelected: selectedHeroIDs.contains(hero.id)
                            ) {
                                if selectedHeroIDs.contains(hero.id) {
                                    selectedHeroIDs.remove(hero.id)
                                } else {
                                    selectedHeroIDs.insert(hero.id)
                                }
                            }
                        }
                    }
                }

                Button("Start Journey") {
                    let newJourney = setupNewJourney()
                    onCommit(newJourney)
                }
                .disabled(selectedHeroIDs.isEmpty)
            }
            .navigationTitle("New Journey")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }

    func setupNewJourney() -> Journey {
        var initiativeOrder: [InitiativeParticipant] = []

        for heroID in selectedHeroIDs {
            if let hero = heroes.first(where: { $0.id == heroID }) {
                initiativeOrder.append(InitiativeParticipant(name: hero.name, isHero: true, heroID: hero.id))
            }
        }
        for i in 1...Int(enemyGroups) {
            initiativeOrder.append(InitiativeParticipant(name: "Enemy Group \(i)", isHero: false))
        }
        initiativeOrder.shuffle()

        // Determine the map name to save
        let mapName: String?
        if journeyType == .hunt {
            mapName = selectedHuntMap.rawValue
        } else if journeyType == .scavenge {
            mapName = selectedScavengeMap.rawValue
        } else {
            mapName = nil
        }

        return Journey(
            journeyType: journeyType,
            level: journeyLevel,
            mapName: mapName,
            participatingHeroes: Array(selectedHeroIDs),
            enemyGroups: Int(enemyGroups),
            initiativeOrder: initiativeOrder
        )
    }
}

#if DEBUG
struct NewJourneyView_Previews: PreviewProvider {
    static var previews: some View {
        NewJourneyView(heroes: Hero.defaultHeroes, onCommit: { _ in })
            .preferredColorScheme(.dark)
    }
}
#endif
