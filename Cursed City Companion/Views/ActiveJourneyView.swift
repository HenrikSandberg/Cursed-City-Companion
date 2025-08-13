import SwiftUI

struct ActiveJourneyView: View {
    @EnvironmentObject private var questManager: QuestManager
    @Environment(\.dismiss) private var dismiss
    // The view now only needs the ID of the quest.
    let questId: UUID

    // It finds the up-to-date quest object from the manager.
    private var quest: Quest? {
        questManager.quests.first { $0.id == questId }
    }

    var body: some View {
        // Safely unwrap the quest and its active journey.
        if let quest = quest, let journey = quest.activeJourney {
            VStack(spacing: 16) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(journey.type.rawValue) • Level \(journey.level)").font(.headline)
                    Text("Participants: \(journey.participants.count) • Enemy groups: \(journey.enemyGroups)").font(.caption).foregroundStyle(.secondary)
                }.ccPanel()

                TurnsListView(quest: quest)

                HStack {
                    Button {
                        questManager.addNewTurn(questId: quest.id)
                    } label: { Label("New Turn", systemImage: "arrow.triangle.2.circlepath") }
                    .buttonStyle(CCSecondaryButton())
                    
                    Spacer()
                    
                    // The navigation link now passes the full, up-to-date quest object.
                    NavigationLink {
                        EndJourneyView(quest: quest, onSaved: {
                            dismiss()
                        })
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
                .onAppear {
                    dismiss()
                }
        }
    }
}

// TurnsListView and ReorderableInitiativeList remain largely the same,
// as they correctly receive data and use bindings to call the manager.
struct TurnsListView: View {
    @EnvironmentObject private var questManager: QuestManager
    let quest: Quest

    var body: some View {
        if let journey = quest.activeJourney {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    Text("Initiative").font(.headline).foregroundStyle(CCTheme.cursedGold)
                    ForEach(journey.turns) { turn in
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Turn \(journey.turns.firstIndex(where: {$0.id == turn.id})! + 1)")
                                .font(.subheadline.weight(.semibold))
                            
                            let entriesBinding = Binding<[InitiativeEntry]>(
                                get: { turn.entries },
                                set: { newEntries in
                                    questManager.updateInitiative(questId: quest.id, turnId: turn.id, newEntries: newEntries)
                                }
                            )
                            
                            ReorderableInitiativeList(entries: entriesBinding)
                        }.ccPanel()
                    }
                }
            }
        }
    }
}

struct ReorderableInitiativeList: View {
    @Binding var entries: [InitiativeEntry]
    @State private var editMode: EditMode = .active

    var body: some View {
        List {
            ForEach(entries) { entry in
                HStack {
                    Image(systemName: entry.heroId != nil ? "person.fill" : "bolt.fill")
                        .foregroundColor(entry.heroId != nil ? CCTheme.brass : CCTheme.bloodRed)
                    Text(entry.label)
                    Spacer()
                }
            }
            .onMove { from, to in
                entries.move(fromOffsets: from, toOffset: to)
            }
        }
        .listStyle(.plain)
        .environment(\.editMode, $editMode)
        .frame(height: min(350, CGFloat(entries.count) * 44 + 20))
        .scrollContentBackground(.hidden)
        .background(Color.clear)
    }
}
