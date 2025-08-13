import SwiftUI

struct HeroDetailView: View {
    @EnvironmentObject private var questManager: QuestManager
    // The view receives the IDs it needs to find the correct data.
    let questId: UUID
    let heroId: UUID

    // It maintains its own local state for editing.
    @State private var hero: Hero?

    var body: some View {
        // We only show the form if the hero state has been loaded.
        if let heroBinding = Binding($hero) {
            Form {
                Section(header: Text("Stats")) {
                    Stepper("Level \(heroBinding.wrappedValue.level)", value: heroBinding.level, in: 1...4)
                    Stepper("Experience \(heroBinding.wrappedValue.experience)", value: heroBinding.experience, in: 0...999)
                    Toggle("Alive", isOn: heroBinding.alive)
                    Stepper("Treasure Cards \(heroBinding.wrappedValue.treasureCards)", value: heroBinding.treasureCards, in: 0...20)
                }
                
                Section(header: Text("Items")) {
                    ForEach(heroBinding.wrappedValue.items, id: \.self) { item in
                        Text(item)
                    }
                    .onDelete { indexSet in
                        heroBinding.wrappedValue.items.remove(atOffsets: indexSet)
                    }
                }
                
                Section(header: Text("Notes")) {
                    TextEditor(text: heroBinding.notes)
                        .frame(minHeight: 120)
                }
            }
            .navigationTitle(heroBinding.wrappedValue.name)
            .onDisappear {
                // When the view disappears, save the changes back to the manager.
                if let updatedHero = hero {
                    questManager.updateHero(questId: questId, hero: updatedHero)
                }
            }
        } else {
            // While loading, or if the hero isn't found, show a progress view.
            ProgressView()
                .onAppear {
                    // When the view appears, find the correct hero from the manager
                    // and set the local state.
                    if let quest = questManager.quests.first(where: { $0.id == questId }) {
                        self.hero = quest.heroes.first { $0.id == heroId }
                    }
                }
        }
    }
}
