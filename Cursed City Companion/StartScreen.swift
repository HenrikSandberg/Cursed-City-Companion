import SwiftUI

struct StartScreen: View {
    // This is now the single source of truth for the quests array.
    @State private var quests: [Quest] = []
    @State private var showingCreateQuestSheet = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.darkstone.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Text("Cursed City Companion")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.cursedGold)
                        .padding()
                    
                    if quests.isEmpty {
                        Spacer()
                        Text("No active quests.")
                            .foregroundColor(.parchment)
                        Spacer()
                    } else {
                        List {
                            // The ForEach now iterates over the binding ($quests)
                            // to pass a binding of each quest to the detail view.
                            ForEach($quests) { $quest in
                                NavigationLink(destination: QuestDetailView(quest: $quest)) {
                                    Text(quest.name)
                                        .foregroundColor(.parchment)
                                }
                            }
                            .onDelete(perform: deleteQuest)
                            .listRowBackground(Color.vampireViolet.opacity(0.5))
                        }
                    }

                    Button(action: {
                        showingCreateQuestSheet = true
                    }) {
                        Text("Create New Quest")
                            .font(.headline)
                            .padding()
                            .background(Color.cursedGold)
                            .foregroundColor(.darkstone)
                            .cornerRadius(10)
                    }
                    .padding()
                }
                .navigationTitle("Active Quests")
                .navigationBarHidden(true)
            }
            .onAppear(perform: loadQuests)
            .sheet(isPresented: $showingCreateQuestSheet) {
                CreateQuestView { newQuest in
                    addQuest(newQuest)
                    showingCreateQuestSheet = false
                }
            }
            // This modifier automatically saves the quests array whenever it changes.
            .onChange(of: quests) { oldQuests, newQuests in
                PersistenceManager.shared.saveQuests(newQuests)
            }
        }
        .accentColor(.cursedGold)
        .navigationViewStyle(.stack) // Ensures single-column navigation on iPad
    }

    private func loadQuests() {
        quests = PersistenceManager.shared.getQuests()
    }

    private func addQuest(_ quest: Quest) {
        // Simply append to the local array; onChange will handle saving.
        quests.append(quest)
    }
    
    private func deleteQuest(at offsets: IndexSet) {
        // Simply remove from the local array; onChange will handle saving.
        quests.remove(atOffsets: offsets)
    }
}

struct CreateQuestView: View {
    @State private var questName: String = ""
    var onCommit: (Quest) -> Void
    @Environment(\.presentationMode) var presentationMode

    var body: some View {
        NavigationView {
            VStack {
                TextField("Enter Quest Name", text: $questName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                Button("Create") {
                    let newQuest = Quest(name: questName.isEmpty ? "New Ulfenkarn Quest" : questName)
                    onCommit(newQuest)
                }
                .disabled(questName.isEmpty)
                .padding()
            }
            .navigationTitle("New Quest")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            }
        }
    }
}

#if DEBUG
struct StartScreen_Previews: PreviewProvider {
    static var previews: some View {
        StartScreen()
            .preferredColorScheme(.dark)
    }
}
#endif

