//
//  JourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import SwiftUI
internal import UniformTypeIdentifiers

struct JourneyView: View {
    @ObservedObject var store = DataStore.shared
    let questID: UUID
    let journeyID: UUID

    @State private var isEditingOrder = false
    @State private var draggingItem: InitiativeEntry?
    @State private var currentTurnIndex: Int = 0

    var questIndex: Int? { store.quests.firstIndex(where: { $0.id == questID }) }
    var journeyIndex: Int? {
        guard let qi = questIndex else { return nil }
        return store.quests[qi].activeJourneys.firstIndex(where: { $0.id == journeyID })
    }

    var body: some View {
        Group {
            if let qi = questIndex, let ji = journeyIndex {
                let journey = store.quests[qi].activeJourneys[ji]

                VStack {
                    HStack {
                        Text(journey.type.rawValue.capitalized).font(.title2)
                        Spacer()
                        Text("Lvl \(journey.level)")
                    }.padding()

                    ScrollView {
                        LazyVStack(spacing: 12) {
                            ForEach(journey.initiative.sorted(by: { $0.orderIndex < $1.orderIndex })) { entry in
                                InitiativeRow(entry: entry, isCurrent: entry.orderIndex == currentTurnIndex)
                                    .onDrag {
                                        self.draggingItem = entry
                                        return NSItemProvider(object: entry.name as NSString)
                                    }
                                    .onDrop(of: [.text], delegate: InitiativeDropDelegate(
                                        item: entry,
                                        current: $draggingItem,
                                        reorder: { from, to in
                                            reorderInitiative(from: from, to: to, questIndex: qi, journeyIndex: ji)
                                        }
                                    ))
                            }
                        }
                        .padding()
                    }

                    HStack {
                        Button("End Journey") {
                            openEndJourney(questIndex: qi, journeyIndex: ji)
                        }
                        .buttonStyle(.borderedProminent)
                        Spacer()
                        Button(isEditingOrder ? "Done" : "Reorder") {
                            isEditingOrder.toggle()
                        }
                    }.padding()
                }
                .navigationTitle("Journey")
            } else {
                Text("Journey not found")
            }
        }
    }

    // Revised: Update the journey via a new Quest and updateQuest(:)
    func reorderInitiative(from: InitiativeEntry, to: InitiativeEntry, questIndex qi: Int, journeyIndex ji: Int) {
        var quest = store.quests[qi]
        var journey = quest.activeJourneys[ji]
        var list = journey.initiative.sorted(by: { $0.orderIndex < $1.orderIndex })
        guard let fromIndex = list.firstIndex(of: from),
              let toIndex = list.firstIndex(of: to) else {
            return
        }
        list.move(fromOffsets: IndexSet(integer: fromIndex), toOffset: toIndex > fromIndex ? toIndex + 1 : toIndex)
        for (i, _) in list.enumerated() {
            list[i].orderIndex = i
        }
        journey.initiative = list
        // Replace journey in quest
        quest.activeJourneys[ji] = journey
        store.updateQuest(quest)
    }

    func openEndJourney(questIndex qi: Int, journeyIndex ji: Int) {
        // present JourneyEndView sheet — simple implementation: push JourneyEndView
        // For simplicity, we directly create a minimal JourneyRecord and finalize:
        _ = store.quests[qi].activeJourneys[ji]
        // present guided UI in real app; here we quickly demo:
        // We push a full-screen sheet normally — but here, to keep simple, call a function that
        // would present the JourneyEndView. Implementation left to full UI iteration.
    }
}


