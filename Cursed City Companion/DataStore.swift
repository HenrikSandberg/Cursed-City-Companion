//
//  DataStore.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import Foundation
import Combine

final class DataStore: ObservableObject {
    static let shared = DataStore()
    
    @Published var gameData: GameData?
    @Published private(set) var quests: [Quest] = []
    @Published var selectedQuestID: UUID?

    private let fileName = "cursedcity_store.json"
    private var storeURL: URL {
        let fm = FileManager.default
        let folder = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
        return folder.appendingPathComponent(fileName)
    }

    private var cancellables = Set<AnyCancellable>()

    private init() {
        loadGameData()
        load()
        // auto-save when quests change
        $quests
            .debounce(for: .seconds(0.5), scheduler: RunLoop.main)
            .sink { [weak self] _ in self?.save() }
            .store(in: &cancellables)
    }

    // MARK: - CRUD

    func createQuest(title: String, heroes: [Hero] = []) -> Quest {
        let fearStart = gameData?.counters.fear.start ?? 5
        let influenceStart = gameData?.counters.influence.start ?? 6
        var q = Quest(title: title, fear: fearStart, influence: influenceStart, decapitationTokens: 0, heroes: heroes)
        quests.append(q)
        selectedQuestID = q.id
        return q
    }

    func updateQuest(_ quest: Quest) {
        guard let idx = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        quests[idx] = quest
    }

    func deleteQuest(_ id: UUID) {
        quests.removeAll { $0.id == id }
        if selectedQuestID == id { selectedQuestID = quests.first?.id }
    }

    // journeys
    func addJourney(_ journey: Journey, to questID: UUID) {
        guard let qidx = quests.firstIndex(where: { $0.id == questID }) else { return }
        quests[qidx].activeJourneys.append(journey)
    }

    func finishJourney(_ record: JourneyRecord, for questID: UUID) {
        guard let qidx = quests.firstIndex(where: { $0.id == questID }) else { return }
        // remove journey from active list
        quests[qidx].activeJourneys.removeAll { $0.id == record.journey.id }
        // append record to history
        quests[qidx].history.insert(record, at: 0)
        // apply consequences to top-level fear/influence
        quests[qidx].fear = max(0, quests[qidx].fear + record.consequences.fearDelta)
        quests[qidx].influence = max(0, quests[qidx].influence + record.consequences.influenceDelta)
        // update heroes (levels, alive, realmstone)
        for heroId in record.journey.selectedHeroIDs {
            if let hIdx = quests[qidx].heroes.firstIndex(where: { $0.id == heroId }) {
                if !record.survivors.contains(heroId) {
                    quests[qidx].heroes[hIdx].alive = false
                }
                // realmstone gained applied globally? depends on rules; we keep it simple
                quests[qidx].heroes[hIdx].realmstone += record.consequences.realmstoneGained
            }
        }
    }

    // MARK: - load/save
    private func save() {
        do {
            let data = try JSONEncoder().encode(quests)
            try FileManager.default.createDirectory(at: storeURL.deletingLastPathComponent(), withIntermediateDirectories: true)
            try data.write(to: storeURL, options: .atomic)
        } catch {
            print("Save error:", error)
        }
    }
    
    private func loadGameData() {
        guard let url = Bundle.main.url(forResource: "GameData", withExtension: "json") else {
            print("GameData.json not found in bundle")
            return
        }
        do {
            let data = try Data(contentsOf: url)
            let decoded = try JSONDecoder().decode(GameData.self, from: data)
            gameData = decoded
        } catch {
            print("Error loading GameData.json: \(error)")
        }
    }

    private func load() {
        do {
            let data = try Data(contentsOf: storeURL)
            quests = try JSONDecoder().decode([Quest].self, from: data)
        } catch {
            // no file yet or decode error -> seed sample if empty
            quests = sampleData()
            save()
        }
    }

    private func sampleData() -> [Quest] {
        let heroes = [
            Hero(name: "Glaurio ven Alten", level: 1, items: ["Noblesse"], treasureCards: [], realmstone: 0),
            Hero(name: "Emelda Braskov", level: 1, items: ["Blade"], treasureCards: [], realmstone: 0),
            Hero(name: "Qulathis the Exile", level: 1, items: [], treasureCards: [], realmstone: 0),
            Hero(name: "Cleona Zeitengale", level: 1, items: [], treasureCards: [], realmstone: 0)
        ]
        let q = Quest(title: "Ulfenkarn — Campaign", fear: 5, influence: 6, decapitationTokens: 0, heroes: heroes)
        return [q]
    }
}
