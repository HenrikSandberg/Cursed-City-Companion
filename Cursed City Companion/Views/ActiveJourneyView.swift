//
//  ActiveJourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct ActiveJourneyView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID

    var body: some View {
        if let qIndex = store.quests.firstIndex(where: {$0.id == questId}),
           let active = store.quests[qIndex].activeJourney {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(active.type.rawValue) • Level \(active.level)").font(.headline)
                    Text("Participants: \(active.participants.count) • Enemy groups: \(active.enemyGroups)").font(.caption).foregroundStyle(.secondary)
                }.ccPanel()

                TurnsList(questIndex: qIndex)

                HStack {
                    Button { duplicateTurn(qIndex: qIndex) } label: { Label("New Turn", systemImage: "arrow.triangle.2.circlepath") }
                        .buttonStyle(CCSecondaryButton())
                    Spacer()
                    NavigationLink {
                        EndJourneyView(questId: store.quests[qIndex].id)
                    } label: { Label("End Journey", systemImage: "flag.checkered") }
                    .buttonStyle(CCPrimaryButton())
                }

                Spacer()
            }
            .padding()
            .navigationTitle("Active Journey")
            .ccBackground().ccToolbar()
        } else {
            Text("No active journey")
        }
    }

    private func duplicateTurn(qIndex: Int) {
        var quest = store.quests[qIndex]
        guard var active = quest.activeJourney, let last = active.turns.last else { return }
        let copy = Turn(entries: last.entries)
        active.turns.append(copy)
        quest.activeJourney = active
        store.quests[qIndex] = quest
    }
}

struct TurnsList: View {
    @EnvironmentObject private var store: Store
    let questIndex: Int

    var body: some View {
        if var active = store.quests[questIndex].activeJourney {
            VStack(alignment: .leading, spacing: 8) {
                Text("Initiative").font(.headline).foregroundStyle(CCTheme.cursedGold)
                ForEach(active.turns) { turn in
                    VStack(alignment: .leading, spacing: 6) {
                        Text("Turn \(active.turns.firstIndex(where: {$0.id == turn.id})! + 1)")
                            .font(.subheadline.weight(.semibold))
                        ReorderableList(entries: Binding(
                            get: { active.turns.first(where: {$0.id == turn.id})?.entries ?? [] },
                            set: { newVal in
                                if let idx = active.turns.firstIndex(where: {$0.id == turn.id}) {
                                    active.turns[idx].entries = newVal
                                    var q = store.quests[questIndex]
                                    q.activeJourney = active
                                    store.quests[questIndex] = q
                                }
                            }
                        ))
                    }.ccPanel()
                }
            }
        }
    }
}

struct ReorderableList: View {
    @Binding var entries: [InitiativeEntry]
    @State private var editMode: EditMode = .active
    var body: some View {
        List {
            ForEach(entries) { e in
                HStack {
                    if let _ = e.heroId {
                        Image(systemName: "person.fill")
                    } else {
                        Image(systemName: "bolt.fill")
                    }
                    Text(e.label)
                    Spacer()
                }
            }
            .onMove { from, to in entries.move(fromOffsets: from, toOffset: to) }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .frame(height: min(300, CGFloat(entries.count) * 44 + 20))
    }
}
