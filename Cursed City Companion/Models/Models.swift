import Combine
import Foundation

// MARK: - Domain Models

struct Hero: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var level: Int
    var experience: Int
    var alive: Bool
    var items: [String]
    var treasureCards: Int
    var notes: String

    init(id: UUID = UUID(),
         name: String,
         level: Int = 1,
         experience: Int = 0,
         alive: Bool = true,
         items: [String] = [],
         treasureCards: Int = 0,
         notes: String = "") {
        self.id = id
        self.name = name
        self.level = level
        self.experience = experience
        self.alive = alive
        self.items = items
        self.treasureCards = treasureCards
        self.notes = notes
    }
}

enum JourneyType: String, Codable, CaseIterable, Identifiable {
    case deliverance = "Deliverance"
    case hunt = "Hunt"
    case scavenge = "Scavenge"
    case decapitation = "Decapitation"
    var id: String { rawValue }
}

struct InitiativeEntry: Identifiable, Codable, Equatable {
    let id: UUID
    var heroId: UUID?
    var isEnemy: Bool
    var label: String

    init(id: UUID = UUID(), heroId: UUID? = nil, isEnemy: Bool = false, label: String) {
        self.id = id
        self.heroId = heroId
        self.isEnemy = isEnemy
        self.label = label
    }
}

struct Turn: Identifiable, Codable, Equatable {
    let id: UUID
    var entries: [InitiativeEntry]
    init(id: UUID = UUID(), entries: [InitiativeEntry]) {
        self.id = id
        self.entries = entries
    }
}

struct ActiveJourney: Identifiable, Codable, Equatable {
    let id: UUID
    var type: JourneyType
    var level: Int
    var enemyGroups: Int
    var participants: [UUID]          // hero IDs
    var turns: [Turn]
    var startedAt: Date

    init(id: UUID = UUID(), type: JourneyType, level: Int, enemyGroups: Int,
         participants: [UUID], turns: [Turn], startedAt: Date = Date()) {
        self.id = id
        self.type = type
        self.level = level
        self.enemyGroups = enemyGroups
        self.participants = participants
        self.turns = turns
        self.startedAt = startedAt
    }
}

struct CompletedJourney: Identifiable, Codable, Equatable {
    let id: UUID
    var type: JourneyType
    var level: Int
    var enemyGroups: Int
    var participants: [UUID]
    var startedAt: Date
    var endedAt: Date
    var wasSuccessful: Bool
    var extractionResult: ExtractionEventResult?
    var notes: String?
}

struct DecapitationDefinition: Identifiable, Hashable, Codable {
    var id: String
    var displayName: String
    var iconAsset: String
    var requiredPartyLevel: Int
}

struct DecapitationState: Codable, Equatable {
    var activeID: String? = nil
    var completedIDs: Set<String> = []
}

struct ExtractionEventDef: Identifiable, Codable, Equatable {
    var id: String
    var name: String
    var description: String
    var onSuccess: Delta
    var onFailure: Delta

    struct Delta: Codable, Equatable {
        var influence: Int
        var fear: Int
    }
}

struct ExtractionEventResult: Codable, Equatable {
    var id: String
    var name: String
    var applied: ExtractionEventDef.Delta
    var at: Date
    var journeyId: UUID
}

struct Quest: Identifiable, Codable, Equatable {
    let id: UUID
    var name: String
    var influence: Int
    var fear: Int
    var heroes: [Hero]
    var decapitationState: DecapitationState
    var activeJourney: ActiveJourney?
    var completedJourneys: [CompletedJourney]
    var lastExtraction: ExtractionEventResult?
    var partyLevelCap: Int

    init(id: UUID = UUID(), name: String, influence: Int, fear: Int, heroes: [Hero], decapitationState: DecapitationState = .init(), activeJourney: ActiveJourney? = nil, completedJourneys: [CompletedJourney] = [], lastExtraction: ExtractionEventResult? = nil, partyLevelCap: Int = 1) {
        self.id = id; self.name = name; self.influence = influence; self.fear = fear; self.heroes = heroes; self.decapitationState = decapitationState; self.activeJourney = activeJourney; self.completedJourneys = completedJourneys; self.lastExtraction = lastExtraction; self.partyLevelCap = partyLevelCap
    }
}

// MARK: - Registries / Presets

enum HeroPresets {
    static let all: [Hero] = [
        Hero(name: "Jelsen Darrock",      items: ["Stake-launcher", "Longsword"]),
        Hero(name: "Qulathis the Exile",  items: ["Aelven Bow", "Spear"]),
        Hero(name: "Dagnai Holdenstock",  items: ["Aethermatic Pistol", "Cutlass"]),
        Hero(name: "Emelda Braskov",      items: ["Knight's Blade", "Shield"]),
        Hero(name: "Octren Glimscry",     items: ["Staff of Power", "Spellbook"]),
        Hero(name: "Brutogg Corpse-Eater",items: ["Ogor Blades"]),
        Hero(name: "Cleona Zeitengale",   items: ["Blessed Blade", "Relic"]),
        Hero(name: "Glaurio ven Alten III", items: ["Duelling Blades"]),
    ]
}

enum DecapitationRegistry {
    static let all: [DecapitationDefinition] = [
        .init(id: "fell_guardian",          displayName: "The Fell Guardian",      iconAsset: "decap_fell_guardian", requiredPartyLevel: 1),
        .init(id: "captain_of_the_damned",  displayName: "Captain of the Damned",  iconAsset: "decap_halgrim",       requiredPartyLevel: 2),
        .init(id: "shuffling_horrors",      displayName: "Shuffling Horrors",      iconAsset: "decap_gorslav",       requiredPartyLevel: 2),
        .init(id: "whispers_in_the_dark",   displayName: "Whispers in the Dark",   iconAsset: "decap_torgilius",     requiredPartyLevel: 3),
        .init(id: "family_ties",            displayName: "Family Ties",            iconAsset: "decap_bloodborn",     requiredPartyLevel: 3),
        .init(id: "final_assault",          displayName: "The Final Assault",      iconAsset: "decap_radukar",       requiredPartyLevel: 4),
    ]
}

enum ExtractionRegistry {
    static func load() -> [ExtractionEventDef] {
        if let url = Bundle.main.url(forResource: "extraction_events", withExtension: "json"),
           let data = try? Data(contentsOf: url),
           let list = try? JSONDecoder().decode([ExtractionEventDef].self, from: data) {
            return list
        }
        // Fallback sample set so the app runs without a file.
        return [
            ExtractionEventDef(id: "quiet_night", name: "Quiet Night", description: "The streets fall silent.",
                               onSuccess: .init(influence: +1, fear: -1),
                               onFailure: .init(influence: 0, fear: 0)),
            ExtractionEventDef(id: "word_spreads", name: "Word Spreads", description: "Tales of heroism spread.",
                               onSuccess: .init(influence: +2, fear: 0),
                               onFailure: .init(influence: 0, fear: +1)),
            ExtractionEventDef(id: "ambush", name: "Ambush", description: "Nightguard stalk the lanes.",
                               onSuccess: .init(influence: 0, fear: +1),
                               onFailure: .init(influence: -1, fear: +1)),
        ]
    }
}

// MARK: - Store & Persistence

final class Store: ObservableObject {

    @Published var quests: [Quest] = [] {
        didSet { Persistence.save(quests) }
    }

    init() {
        quests = Persistence.load()
    }

    /// New quests start with Influence 5 and Fear 5
    func newQuest(name: String) {
        let q = Quest(name: name, influence: 5, fear: 5, heroes: HeroPresets.all)
        quests.append(q)
    }

    func update(_ quest: Quest) {
        guard let i = quests.firstIndex(where: { $0.id == quest.id }) else { return }
        quests[i] = quest
    }

    /// Helper to mutate nested state and publish the change.
    func withQuest(_ id: UUID, mutate: (inout Quest) -> Void) {
        guard let i = quests.firstIndex(where: { $0.id == id }) else { return }
        var q = quests[i]
        mutate(&q)
        quests[i] = q
    }
}

/// Tiny JSON persistence used by `Store`.
enum Persistence {
    private static let fileName = "quests.json"

    private static func url() -> URL {
        let dir = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return dir.appendingPathComponent(fileName)
    }

    static func load() -> [Quest] {
        let url = url()
        guard let data = try? Data(contentsOf: url) else { return [] }
        return (try? JSONDecoder().decode([Quest].self, from: data)) ?? []
    }

    static func save(_ quests: [Quest]) {
        let url = url()
        guard let data = try? JSONEncoder().encode(quests) else { return }
        try? data.write(to: url)
    }
}
