import SwiftUI

struct StartScreen: View {
    @EnvironmentObject private var store: Store
    @State private var newName: String = ""
    @State private var showingCreate = false

    var body: some View {
        ZStack {
            ArcadeBackground()
            VStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Cursed City").font(.largeTitle.weight(.bold))
                    Text("Companion").font(.title3.weight(.semibold)).foregroundStyle(CCTheme.cursedGold)
                }
                .frame(maxWidth: .infinity, alignment: .leading)

                if store.quests.isEmpty {
                    Text("No quests yet. Start a new campaign.")
                        .foregroundStyle(CCTheme.parchment).opacity(0.9)
                        .ccPanel()
                }

                List {
                    Section {
                        ForEach(store.quests) { q in
                            NavigationLink(value: q.id) {
                                HStack {
                                    VStack(alignment: .leading) {
                                        Text(q.name).font(.headline)
                                        Text("Influence \(q.influence) • Fear \(q.fear)")
                                            .font(.caption).foregroundStyle(CCTheme.parchment.opacity(0.9))
                                    }
                                    Spacer()
                                    if q.activeJourney != nil {
                                        Text("Active").font(.caption2.weight(.bold)).padding(6)
                                            .background(Capsule().fill(CCTheme.bloodRed.opacity(0.9)))
                                    }
                                }
                            }
                        }
                        .onDelete { idx in
                            store.quests.remove(atOffsets: idx)
                        }
                    } header: { Text("Quests") }
                }
                .scrollContentBackground(.hidden)
                .frame(maxHeight: 400)

                Button {
                    showingCreate = true
                } label: {
                    Label("New Quest", systemImage: "plus.circle.fill")
                }
                .buttonStyle(CCPrimaryButton())

                Spacer()
            }
            .padding()
            .navigationDestination(for: UUID.self) { id in
                QuestDetailView(questId: id)
            }
        }
        .sheet(isPresented: $showingCreate) {
            CreateQuestSheet() { name in
                store.newQuest(name: name)
            }
            .presentationDetents([.medium, .large])
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
            }.padding()
            .navigationTitle("New Quest")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Create") {
                        onCreate(name.isEmpty ? "Ulfenkarn in Peril" : name)
                        dismiss()
                    }.disabled(name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
        }
    }
}
