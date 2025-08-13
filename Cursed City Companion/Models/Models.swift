import Foundation
import Combine
import SwiftUI

// MARK: - Domain Models

struct Hero: Identifiable, Codable, Equatable, Hashable {
    let id: UUID
    var name: String
    var experience: Int
    var level: Int
    var alive: Bool
    var items: [String]
    var treasureCards: Int
    var notes: String

    init(id: UUID = UUID(), name: String, level: Int = 0, experience: Int = 0, alive: Bool = true, items: [String] = [], treasureCards: Int = 0, notes: String = "") {
        self.id = id; self.name = name; self.level = level; self.experience = experience; self.alive = alive; self.items = items; self.treasureCards = treasureCards; self.notes = notes
    }

    mutating func gainExperience(_ amount: Int) {
        guard alive else { return }
        experience += amount
        while experience >= 2 {
            experience -= 2
            level = min(level + 1, 4)
        }
    }
}

enum JourneyType: String, Codable, CaseIterable, Identifiable {
    case deliverance = "Deliverance"
    case hunt = "Hunt"
    case scavenge = "Scavenge"
    case decapitation = "Decapitation"
    var id: String { rawValue }

    /// Defines the base impact on Fear and Influence for each journey type, based on the rulebook.
    var baseConsequences: (onSuccess: ExtractionEventDef.Delta, onFailure: ExtractionEventDef.Delta) {
        switch self {
        case .deliverance:
            // Rulebook: Success shrinks Fear by 2. After journey, grow Influence by 1.
            return (onSuccess: .init(influence: +1, fear: -2), onFailure: .init(influence: +1, fear: 0))
        case .hunt:
            // Rulebook: Success shrinks Influence by 2. After journey, grow Fear by 1.
            return (onSuccess: .init(influence: -2, fear: +1), onFailure: .init(influence: 0, fear: +1))
        case .scavenge:
            // Rulebook: After journey, grow Fear and Influence by 1.
            return (onSuccess: .init(influence: +1, fear: +1), onFailure: .init(influence: +1, fear: +1))
        case .decapitation:
            // Rulebook: Failure grows Fear and Influence. Success is a major blow to Radukar.
            return (onSuccess: .init(influence: -2, fear: -2), onFailure: .init(influence: +1, fear: +1))
        }
    }
}

struct InitiativeEntry: Identifiable, Codable, Equatable {
    let id: UUID; var heroId: UUID?; var isEnemy: Bool; var label: String
    init(id: UUID = UUID(), heroId: UUID? = nil, isEnemy: Bool = false, label: String) {
        self.id = id; self.heroId = heroId; self.isEnemy = isEnemy; self.label = label
    }
}

struct Turn: Identifiable, Codable, Equatable {
    let id: UUID; var entries: [InitiativeEntry]
    init(id: UUID = UUID(), entries: [InitiativeEntry]) { self.id = id; self.entries = entries }
}

struct ActiveJourney: Identifiable, Codable, Equatable, Hashable {
    let id: UUID; var type: JourneyType; var level: Int; var enemyGroups: Int; var participants: [UUID]; var turns: [Turn]; var startedAt: Date
    init(id: UUID = UUID(), type: JourneyType, level: Int, enemyGroups: Int, participants: [UUID], turns: [Turn], startedAt: Date = Date()) {
        self.id = id; self.type = type; self.level = level; self.enemyGroups = enemyGroups; self.participants = participants; self.turns = turns; self.startedAt = startedAt
    }
    func hash(into hasher: inout Hasher) { hasher.combine(id) }
    static func == (lhs: ActiveJourney, rhs: ActiveJourney) -> Bool { lhs.id == rhs.id }
}

struct CompletedJourney: Identifiable, Codable, Equatable, Hashable {
    let id: UUID; var type: JourneyType; var level: Int; var enemyGroups: Int; var participants: [UUID]; var startedAt: Date; var endedAt: Date; var wasSuccessful: Bool; var extractionResult: ExtractionEventResult?; var notes: String?
}

struct DecapitationDefinition: Identifiable, Hashable, Codable {
    var id: String; var displayName: String; var iconAsset: String; var requiredPartyLevel: Int
}

struct DecapitationState: Codable, Equatable, Hashable {
    var activeID: String? = nil; var completedIDs: Set<String> = []
}

struct ExtractionEventDef: Identifiable, Codable, Equatable, Hashable {
    var id: String; var name: String; var description: String; var onSuccess: Delta; var onFailure: Delta
    struct Delta: Codable, Equatable, Hashable { var influence: Int; var fear: Int }
}

struct ExtractionEventResult: Codable, Equatable, Hashable {
    var id: String; var name: String; var applied: ExtractionEventDef.Delta; var at: Date; var journeyId: UUID
}

struct Quest: Identifiable, Codable, Equatable, Hashable {
    let id: UUID; var name: String; var influence: Int; var fear: Int; var heroes: [Hero]; var decapitationState: DecapitationState; var activeJourney: ActiveJourney?; var completedJourneys: [CompletedJourney]; var lastExtraction: ExtractionEventResult?; var partyLevelCap: Int
    init(id: UUID = UUID(), name: String, influence: Int = 5, fear: Int = 5, heroes: [Hero], decapitationState: DecapitationState = .init(), activeJourney: ActiveJourney? = nil, completedJourneys: [CompletedJourney] = [], lastExtraction: ExtractionEventResult? = nil, partyLevelCap: Int = 1) {
        self.id = id; self.name = name; self.influence = influence; self.fear = fear; self.heroes = heroes; self.decapitationState = decapitationState; self.activeJourney = activeJourney; self.completedJourneys = completedJourneys; self.lastExtraction = lastExtraction; self.partyLevelCap = partyLevelCap
    }
    mutating func updatePartyLevelCap() {
        let completed = decapitationState.completedIDs
        if completed.isSuperset(of: ["whispers_in_the_dark", "family_ties"]) { partyLevelCap = 4 }
        else if completed.isSuperset(of: ["captain_of_the_damned", "shuffling_horrors"]) { partyLevelCap = 3 }
        else if completed.contains("fell_guardian") { partyLevelCap = 2 }
        else { partyLevelCap = 1 }
    }
}

// MARK: - Registries / Presets

enum HeroPresets {
    static let all: [Hero] = [
        Hero(name: "Jelsen Darrock", items: ["Stake-launcher", "Longsword"]),
        Hero(name: "Qulathis the Exile", items: ["Aelven Bow", "Spear"]),
        Hero(name: "Dagnai Holdenstock", items: ["Aethermatic Pistol", "Cutlass"]),
        Hero(name: "Emelda Braskov", items: ["Knight's Blade", "Shield"]),
        Hero(name: "Octren Glimscry", items: ["Staff of Power", "Spellbook"]),
        Hero(name: "Brutogg Corpse-Eater", items: ["Ogor Blades"]),
        Hero(name: "Cleona Zeitengale", items: ["Blessed Blade", "Relic"]),
        Hero(name: "Glaurio ven Alten III", items: ["Duelling Blades"]),
    ]
}

enum DecapitationRegistry {
    static let all: [DecapitationDefinition] = [
        .init(id: "fell_guardian", displayName: "The Fell Guardian", iconAsset: "decap_fell_guardian", requiredPartyLevel: 1),
        .init(id: "captain_of_the_damned", displayName: "Captain of the Damned", iconAsset: "decap_halgrim", requiredPartyLevel: 2),
        .init(id: "shuffling_horrors", displayName: "Shuffling Horrors", iconAsset: "decap_gorslav", requiredPartyLevel: 2),
        .init(id: "whispers_in_the_dark", displayName: "Whispers in the Dark", iconAsset: "decap_torgilius", requiredPartyLevel: 3),
        .init(id: "family_ties", displayName: "Family Ties", iconAsset: "decap_bloodborn", requiredPartyLevel: 3),
        .init(id: "final_assault", displayName: "The Final Assault", iconAsset: "decap_radukar", requiredPartyLevel: 4),
    ]
}

enum ExtractionRegistry {
    static func load() -> [ExtractionEventDef] {
        return [
            ExtractionEventDef(id: "quiet_night", name: "Quiet Night", description: "The Adamant slips away under the cover of darkness, unnoticed by the city's sentinels.", onSuccess: .init(influence: +1, fear: -1), onFailure: .init(influence: 0, fear: 0)),
            ExtractionEventDef(id: "word_spreads", name: "Word Spreads", description: "As you depart, whispers of your deeds give the citizens a glimmer of hope.", onSuccess: .init(influence: +2, fear: 0), onFailure: .init(influence: 0, fear: +1)),
            ExtractionEventDef(id: "ambush", name: "Ambush!", description: "Vargskyr and bats swarm the extraction point! You fight them off, but it's a close call.", onSuccess: .init(influence: 0, fear: +1), onFailure: .init(influence: -1, fear: +2)),
            ExtractionEventDef(id: "ulfenwatch_patrol", name: "Ulfenwatch Patrol", description: "A patrol of the skeletal Ulfenwatch marches past the rendezvous, forcing you to wait for a better opportunity.", onSuccess: .init(influence: 0, fear: 0), onFailure: .init(influence: -1, fear: +1)),
            ExtractionEventDef(id: "ghastly_omen", name: "Ghastly Omen", description: "A deathly chill hangs in the air, and the howls of the damned echo across the rooftops as you escape.", onSuccess: .init(influence: 0, fear: +1), onFailure: .init(influence: -1, fear: +1)),
            ExtractionEventDef(id: "desperate_citizens", name: "Desperate Citizens", description: "A crowd of hopefuls nearly compromises your position, begging to be taken aboard the Adamant.", onSuccess: .init(influence: +1, fear: 0), onFailure: .init(influence: 0, fear: +1)),
            ExtractionEventDef(id: "unexpected_ally", name: "Unexpected Ally", description: "A lone city guard, still loyal to the old ways, creates a diversion that allows for a clean getaway.", onSuccess: .init(influence: +2, fear: -1), onFailure: .init(influence: -1, fear: 0)),
            ExtractionEventDef(id: "verminous_horde", name: "Verminous Horde", description: "The ground itself seems to writhe as a tide of Corpse Rats swarms the landing zone.", onSuccess: .init(influence: 0, fear: +1), onFailure: .init(influence: 0, fear: +2)),
            ExtractionEventDef(id: "aethercraft_trouble", name: "Aethercraft Trouble", description: "The Adamant's engines sputter, making for a dangerously slow and noisy ascent from the cursed city.", onSuccess: .init(influence: 0, fear: 0), onFailure: .init(influence: -1, fear: +1)),
            ExtractionEventDef(id: "scavenged_parts", name: "Scavenged Parts", description: "Among the refuse, you find components that help Kolgo Nugsson tune the Adamant's endrins.", onSuccess: .init(influence: +1, fear: 0), onFailure: .init(influence: 0, fear: 0)),
            ExtractionEventDef(id: "cursed_relic", name: "Cursed Relic", description: "You escape with a powerful artifact, but its malevolent aura seems to draw the city's darkness closer.", onSuccess: .init(influence: 0, fear: +2), onFailure: .init(influence: -1, fear: +2)),
        ]
    }
}

// MARK: - Quest Manager (Single Source of Truth)

@MainActor
final class QuestManager: ObservableObject {

    @Published private(set) var quests: [Quest] = []
    private let persistenceManager = PersistenceManager()

    init() { self.quests = persistenceManager.loadQuests() }
    private func save() { persistenceManager.saveQuests(quests) }

    func createQuest(name: String) {
        quests.append(Quest(name: name, heroes: HeroPresets.all))
        save()
    }

    func deleteQuest(at offsets: IndexSet) {
        quests.remove(atOffsets: offsets)
        save()
    }
    
    func startJourney(questId: UUID, type: JourneyType, level: Int, enemyGroups: Int, participants: Set<UUID>) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        let participantHeroes = quests[index].heroes.filter { participants.contains($0.id) }
        let entries: [InitiativeEntry] = participantHeroes.map { InitiativeEntry(heroId: $0.id, label: $0.name) } + (0..<enemyGroups).map { i in InitiativeEntry(isEnemy: true, label: "Enemy Group \(i+1)") }
        let turn = Turn(entries: entries.shuffled())
        quests[index].activeJourney = ActiveJourney(type: type, level: level, enemyGroups: enemyGroups, participants: Array(participants), turns: [turn])
        save()
    }
    
    func endJourney(questId: UUID, wasSuccessful: Bool, survival: [UUID: Bool], extraction: ExtractionEventDef, notes: String) {
        guard let index = quests.firstIndex(where: { $0.id == questId }), let activeJourney = quests[index].activeJourney else { return }
        var quest = quests[index]

        // Combine deltas from the journey type and the extraction event.
        let journeyConsequences = activeJourney.type.baseConsequences
        let journeyDelta = wasSuccessful ? journeyConsequences.onSuccess : journeyConsequences.onFailure
        let extractionDelta = wasSuccessful ? extraction.onSuccess : extraction.onFailure
        let totalAppliedDelta = ExtractionEventDef.Delta(influence: journeyDelta.influence + extractionDelta.influence, fear: journeyDelta.fear + extractionDelta.fear)

        quest.influence = max(0, quest.influence + totalAppliedDelta.influence)
        quest.fear = max(0, quest.fear + totalAppliedDelta.fear)

        for (heroId, isAlive) in survival where !isAlive {
            if let heroIndex = quest.heroes.firstIndex(where: { $0.id == heroId }) { quest.heroes[heroIndex].alive = false }
        }

        if wasSuccessful {
            let partyLevels = quest.heroes.filter { activeJourney.participants.contains($0.id) }.map { $0.level }
            for heroId in activeJourney.participants {
                if let heroIndex = quest.heroes.firstIndex(where: { $0.id == heroId }) {
                    guard canHeroGainExperience(hero: quest.heroes[heroIndex], decapitationState: quest.decapitationState) else { continue }
                    var xpGains = 1
                    if let myLevel = partyLevels.first(where: { _ in quest.heroes[heroIndex].id == heroId }), partyLevels.contains(where: { $0 > myLevel }) { xpGains += 1 }
                    quest.heroes[heroIndex].gainExperience(xpGains)
                }
            }
        }

        let completedJourney = CompletedJourney(id: activeJourney.id, type: activeJourney.type, level: activeJourney.level, enemyGroups: activeJourney.enemyGroups, participants: activeJourney.participants, startedAt: activeJourney.startedAt, endedAt: Date(), wasSuccessful: wasSuccessful, extractionResult: .init(id: extraction.id, name: extraction.name, applied: totalAppliedDelta, at: Date(), journeyId: activeJourney.id), notes: notes.isEmpty ? nil : notes)
        quest.completedJourneys.insert(completedJourney, at: 0)
        quest.lastExtraction = completedJourney.extractionResult

        if activeJourney.type == .decapitation, wasSuccessful, let decapId = quest.decapitationState.activeID {
            quest.decapitationState.completedIDs.insert(decapId)
            quest.decapitationState.activeID = nil
            quest.updatePartyLevelCap()
        }

        quest.activeJourney = nil
        quests[index] = quest
        save()
    }
    
    private func canHeroGainExperience(hero: Hero, decapitationState: DecapitationState) -> Bool {
        let completed = decapitationState.completedIDs
        if hero.level >= 4 && !completed.contains("final_assault") { return false }
        if hero.level >= 3 && !(completed.isSuperset(of: ["whispers_in_the_dark", "family_ties"])) { return false }
        if hero.level >= 2 && !(completed.isSuperset(of: ["captain_of_the_damned", "shuffling_horrors"])) { return false }
        if hero.level >= 1 && !completed.contains("fell_guardian") { return false }
        return true
    }
    
    func addNewTurn(questId: UUID) {
        guard let index = quests.firstIndex(where: { $0.id == questId }), let lastTurn = quests[index].activeJourney?.turns.last else { return }
        quests[index].activeJourney?.turns.append(Turn(entries: lastTurn.entries))
        save()
    }

    func updateInitiative(questId: UUID, turnId: UUID, newEntries: [InitiativeEntry]) {
        guard let qIndex = quests.firstIndex(where: { $0.id == questId }), var journey = quests[qIndex].activeJourney, let tIndex = journey.turns.firstIndex(where: { $0.id == turnId }) else { return }
        journey.turns[tIndex].entries = newEntries
        quests[qIndex].activeJourney = journey
        save()
    }
    
    func updateHero(questId: UUID, hero: Hero) {
        guard let qIndex = quests.firstIndex(where: { $0.id == questId }), let hIndex = quests[qIndex].heroes.firstIndex(where: { $0.id == hero.id }) else { return }
        quests[qIndex].heroes[hIndex] = hero
        save()
    }
    
    func setDecapitationTarget(questId: UUID, targetId: String?) {
        guard let index = quests.firstIndex(where: { $0.id == questId }) else { return }
        quests[index].decapitationState.activeID = targetId
        save()
    }
}
