//
//  QuestDetailView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct QuestDetailView: View {
    @ObservedObject var store = DataStore.shared
    let questID: UUID
    @State private var showNewJourney = false

    var questIndex: Int? {
        store.quests.firstIndex(where: { $0.id == questID })
    }

    var body: some View {
        Group {
            if let qi = questIndex {
                let q = store.quests[qi]
                VStack(spacing: 12) {
                    // Top counters
                    HStack {
                        counterView(title: "Fear", value: q.fear, color: .red)
                        counterView(title: "Influence", value: q.influence, color: .blue)
                        counterView(title: "Decapitations", value: q.decapitationTokens, color: .secondary)
                    }
                    .padding(.horizontal)

                    // Heroes
                    Section(header: Text("Heroes")) {
                        ScrollView(.horizontal, showsIndicators: false) {
                            HStack {
                                ForEach(q.heroes) { hero in
                                    NavigationLink(destination: HeroDetailView(heroID: hero.id, questID: q.id)) {
                                        VStack {
                                            Text(hero.name).bold()
                                            Text("Lvl \(hero.level)").font(.caption)
                                            Text(hero.alive ? "Alive" : "Dead").font(.caption2).foregroundColor(hero.alive ? .green : .red)
                                        }
                                        .frame(width: 150, height: 80)
                                        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
                                    }
                                }
                            }.padding(.horizontal)
                        }
                    }

                    // Active journeys & history
                    List {
                        Section(header: Text("Active Journeys")) {
                            ForEach(q.activeJourneys) { j in
                                NavigationLink(destination: JourneyView(questID: q.id, journeyID: j.id)) {
                                    HStack {
                                        Text(j.type.rawValue.capitalized)
                                        Spacer()
                                        Text("Lvl \(j.level)")
                                    }
                                }
                            }
                        }

                        Section(header: Text("History")) {
                            ForEach(q.history) { rec in
                                VStack(alignment: .leading) {
                                    Text(rec.journey.type.rawValue.capitalized + " (Lvl \(rec.journey.level))")
                                    HStack {
                                        Text(rec.success ? "Success" : "Failed")
                                            .font(.caption).foregroundColor(rec.success ? .green : .red)
                                        Spacer()
                                        Text("Ended \(shortDate(rec.endedAt))").font(.caption2)
                                    }
                                }
                            }
                        }
                    }
                }
                .navigationTitle(q.title)
                .toolbar {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Menu {
                            Button("New Journey") { showNewJourney = true }
                            Button("Edit Heroes") { /* hero editor */ }
                        } label: {
                            Image(systemName: "plus.circle")
                        }
                    }
                }
                .sheet(isPresented: $showNewJourney) {
                    NewJourneyView(questID: q.id)
                }
            } else {
                Text("Quest not found")
            }
        }
    }

    func counterView(title: String, value: Int, color: Color) -> some View {
        VStack {
            Text(title).font(.caption)
            Text("\(value)").font(.largeTitle).bold().foregroundColor(color)
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.systemBackground)).shadow(radius: 1))
    }

    func shortDate(_ d: Date) -> String {
        let f = DateFormatter(); f.dateStyle = .short; return f.string(from: d)
    }

    func openNewJourney(for quest: Quest) {
        // create a new Journey with default initiative from heroes
        var entries: [InitiativeEntry] = []
        for (i, hero) in quest.heroes.enumerated() {
            if hero.alive {
                entries.append(InitiativeEntry(name: hero.name, isHero: true, orderIndex: i))
            }
        }
        // add default enemy groups markers
        let journey = Journey(type: .hunt, level: 1, selectedHeroIDs: quest.heroes.filter { $0.alive }.map { $0.id }, enemyGroups: 1, initiative: entries)
        DataStore.shared.addJourney(journey, to: quest.id)
    }
}
