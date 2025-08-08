//
//  StartView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import SwiftUI
import Foundation

struct StartView: View {
    @ObservedObject var store = DataStore.shared
    @State private var newTitle = ""

    var body: some View {
        NavigationView {
            List {
                Section(header: Text("Active Quests")) {
                    ForEach(store.quests) { q in
                        NavigationLink(destination: QuestDetailView(questID: q.id)) {
                            HStack {
                                VStack(alignment: .leading) {
                                    Text(q.title).font(.headline)
                                    Text("Fear: \(q.fear)  •  Influence: \(q.influence)")
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                                Spacer()
                                if !q.activeJourneys.isEmpty {
                                    Text("\(q.activeJourneys.count) journeys").font(.caption2).padding(6).background(Capsule().fill(Color.secondary.opacity(0.1)))
                                }
                            }
                        }
                    }
                    .onDelete(perform: delete)
                }

                Section(header: Text("Create Quest")) {
                    HStack {
                        TextField("Quest title", text: $newTitle)
                        Button("Create") {
                            let q = DataStore.shared.createQuest(title: newTitle.isEmpty ? "New Quest" : newTitle)
                            newTitle = ""
                            // navigate to it — simplified: set selection
                            DataStore.shared.selectedQuestID = q.id
                        }
                        .disabled(newTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .listStyle(InsetGroupedListStyle())
            .navigationTitle("Cursed City Tracker")
            .toolbar {
                EditButton()
            }

            Text("Select or create a quest")
                .foregroundColor(.secondary)
        }
    }

    func delete(at offsets: IndexSet) {
        for idx in offsets {
            let id = store.quests[idx].id
            store.deleteQuest(id)
        }
    }
}

