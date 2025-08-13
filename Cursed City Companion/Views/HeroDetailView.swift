import SwiftUI

struct HeroDetailView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID
    let heroId: UUID

    var body: some View {
        if let qIndex = store.quests.firstIndex(where: {$0.id == questId}),
           let hIndex = store.quests[qIndex].heroes.firstIndex(where: {$0.id == heroId}) {
            let heroBinding = Binding<Hero>(
                get: { store.quests[qIndex].heroes[hIndex] },
                set: { newValue in
                    var q = store.quests[qIndex]
                    q.heroes[hIndex] = newValue
                    store.quests[qIndex] = q
                }
            )
            Form {
                Section(header: Text("Stats")) {
                    Stepper("Level \(heroBinding.wrappedValue.level)", value: Binding(
                        get: { heroBinding.wrappedValue.level },
                        set: { heroBinding.wrappedValue.level = $0 }
                    ), in: 1...4)
                    Stepper("Experience \(heroBinding.wrappedValue.experience)", value: Binding(
                        get: { heroBinding.wrappedValue.experience },
                        set: { heroBinding.wrappedValue.experience = $0 }
                    ), in: 0...999)
                    Toggle("Alive", isOn: Binding(get: { heroBinding.wrappedValue.alive }, set: { heroBinding.wrappedValue.alive = $0 }))
                    Stepper("Treasure \(heroBinding.wrappedValue.treasureCards)", value: Binding(get: { heroBinding.wrappedValue.treasureCards }, set: { heroBinding.wrappedValue.treasureCards = $0 }), in: 0...20)
                }
                Section(header: Text("Items")) {
                    ForEach(Array(heroBinding.wrappedValue.items.enumerated()), id: \.offset) { i, item in
                        Text(item)
                    }.onDelete { idx in
                        var val = heroBinding.wrappedValue
                        val.items.remove(atOffsets: idx)
                        heroBinding.wrappedValue = val
                    }
                    Button {
                        var val = heroBinding.wrappedValue
                        val.items.append("New Item")
                        heroBinding.wrappedValue = val
                    } label: { Label("Add Item", systemImage: "plus") }
                }
                Section(header: Text("Notes")) {
                    TextEditor(text: Binding(get: { heroBinding.wrappedValue.notes }, set: { heroBinding.wrappedValue.notes = $0 }))
                        .frame(height: 120)
                }
            }
            .navigationTitle(heroBinding.wrappedValue.name)
        } else {
            Text("Hero not found")
        }
    }
}
