import SwiftUI

struct StartScreen: View {
    @EnvironmentObject private var questManager: QuestManager
    @State private var showingCreateSheet = false

    var body: some View {
        ZStack {
            ArcadeBackground()
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cursed City").font(.largeTitle.weight(.bold))
                    Text("Companion").font(.title3.weight(.semibold)).foregroundStyle(CCTheme.cursedGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if questManager.quests.isEmpty {
                    Text("No quests yet. Start a new campaign.")
                        .foregroundStyle(CCTheme.parchment).opacity(0.9)
                        .ccPanel()
                }

                List {
                    Section {
                        ForEach(questManager.quests) { quest in
                            // Navigation is now based on the stable UUID of the quest.
                            NavigationLink(value: quest.id) {
                                QuestListRow(quest: quest)
                            }
                        }
                        .onDelete { indexSet in
                            questManager.deleteQuest(at: indexSet)
                        }
                    } header: { Text("Quests") }
                }
                .scrollContentBackground(.hidden)
                .frame(maxHeight: 400)

                Button {
                    showingCreateSheet = true
                } label: {
                    Label("New Quest", systemImage: "plus.circle.fill")
                }
                .buttonStyle(CCPrimaryButton())

                Spacer()
            }
            .padding()
            // The navigation destination now listens for a UUID to show the QuestDetailView.
            .navigationDestination(for: UUID.self) { questId in
                QuestDetailView(questId: questId)
            }
        }
        .sheet(isPresented: $showingCreateSheet) {
            CreateQuestSheet { name in
                questManager.createQuest(name: name)
                showingCreateSheet = false
            }
            .presentationDetents([.medium])
        }
    }
}

struct QuestListRow: View {
    let quest: Quest
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text(quest.name).font(.headline)
                Text("Influence \(quest.influence) • Fear \(quest.fear)")
                    .font(.caption).foregroundStyle(CCTheme.parchment.opacity(0.9))
            }
            Spacer()
            if quest.activeJourney != nil {
                Text("Active")
                    .font(.caption2.weight(.bold)).padding(6)
                    .background(Capsule().fill(CCTheme.bloodRed.opacity(0.9)))
            }
        }
    }
}


struct CreateQuestSheet: View {
    var onCreate: (String) -> Void
    @Environment(\.dismiss) private var dismiss
    @State private var name: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                TextField("Quest name", text: $name)
                    .textFieldStyle(.roundedBorder)
                Text("Starts with Influence 5 and Fear 5.").font(.footnote).foregroundStyle(.secondary)
                Spacer()
            }
            .padding()
            .navigationTitle("New Quest")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name.trimmingCharacters(in: .whitespacesAndNewlines))
                    }
                    .disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .ccBackground()
        }
    }
}
