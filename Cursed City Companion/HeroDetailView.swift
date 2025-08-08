//
//  HeroDetailView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct HeroDetailView: View {
    @ObservedObject var store = DataStore.shared
    let heroID: UUID
    let questID: UUID

    var body: some View {
        if let questIdx = store.quests.firstIndex(where: { $0.id == questID }),
           let heroIdx = store.quests[questIdx].heroes.firstIndex(where: { $0.id == heroID }) {
            let heroBinding = Binding(get: {
                store.quests[questIdx].heroes[heroIdx]
            }, set: { newHero in
                var q = store.quests[questIdx]
                q.heroes[heroIdx] = newHero
                store.updateQuest(q)
            })

            HeroDetailInnerView(hero: heroBinding)
        } else {
            Text("Hero not found")
        }
    }
}

struct HeroDetailInnerView: View {
    @Binding var hero: Hero
    @State private var newItem = ""
    @State private var newTreasure = ""

    var body: some View {
        Form {
            Section(header: Text(hero.name).font(.headline)) {
                HStack {
                    Text("Level")
                    Spacer()
                    Stepper("\(hero.level)", value: $hero.level, in: 0...10)
                }
                Toggle("Alive", isOn: $hero.alive)
                HStack {
                    Text("Realmstone")
                    Spacer()
                    Text("\(hero.realmstone)")
                }
            }
            Section(header: Text("Items")) {
                ForEach(hero.items, id: \.self) { item in
                    Text(item)
                }.onDelete { idx in
                    hero.items.remove(atOffsets: idx)
                }
                HStack {
                    TextField("Add item", text: $newItem)
                    Button("Add") {
                        if !newItem.isEmpty { hero.items.append(newItem); newItem = "" }
                    }
                }
            }
            Section(header: Text("Treasure Cards")) {
                ForEach(hero.treasureCards, id: \.self) { t in Text(t) }.onDelete { idx in hero.treasureCards.remove(atOffsets: idx) }
                HStack {
                    TextField("Treasure", text: $newTreasure)
                    Button("Add") { if !newTreasure.isEmpty { hero.treasureCards.append(newTreasure); newTreasure = "" } }
                }
            }
        }
        .navigationTitle(hero.name)
    }
}
