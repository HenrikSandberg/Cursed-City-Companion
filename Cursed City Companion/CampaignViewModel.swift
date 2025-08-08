//
//  CampaignViewModel.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import Combine
import SwiftUI


// MARK: - ViewModel
// Lagt til flere Decapitation journeys for visning
class CampaignViewModel: ObservableObject {
    @Published var data: CampaignData { didSet { PersistenceManager.saveCampaign(data: data) } }
    @Published var activeJourney: Journey?
    @Published var heroesOnJourney: [Hero] = []
    @Published var journeyEnemies: [EnemyGroup] = []
    @Published var activationOrder: [Activation] = []
    @Published var enemyActivationsPerRound: Int = 1
    
    var decapitationJourneys: [Journey] {
        data.journeys.filter { $0.type.isDecapitation }
    }

    init() {
        if let loadedData = PersistenceManager.loadCampaign() {
            self.data = loadedData
        } else {
            self.data = CampaignData(
                fearLevel: 3,
                influenceLevel: 5,
                heroes: Hero.allHeroes(),
                journeys: [
                    // Legger til nok Decapitation-oppdrag for visning
                    Journey(id: UUID(), name: "Slay the Vyrkos Blood-born", type: .decapitation),
                    Journey(id: UUID(), name: "Purge the Vampire Nest", type: .decapitation),
                    Journey(id: UUID(), name: "Destroy the Corpse-Cart", type: .decapitation),
                    Journey(id: UUID(), name: "End the Watch-Captain", type: .decapitation),
                    Journey(id: UUID(), name: "Confront Radukar's Lieutenant", type: .decapitation),
                    Journey(id: UUID(), name: "A Simple Hunt", type: .hunt)
                ],
                defeatedBosses: [],
                successfulDecapitations: 1 // Forhåndsinnstilt for visuelt eksempel
            )
        }
    }
    func startJourney(journey: Journey, participatingHeroes: [Hero]) {
        self.activeJourney = journey
        self.heroesOnJourney = participatingHeroes
        self.journeyEnemies = []
        prepareForNewRound()
    }
    func endJourney(status: Journey.Status) {
        guard let activeJourney = activeJourney else { return }
        if let index = data.journeys.firstIndex(where: { $0.id == activeJourney.id }) {
            data.journeys[index].status = status
            data.journeys[index].encounteredEnemies = self.journeyEnemies
            let outcome = status == .completed ? activeJourney.type.successOutcome : activeJourney.type.failureOutcome
            data.fearLevel = max(0, data.fearLevel + outcome.fearChange)
            data.influenceLevel = max(0, data.influenceLevel + outcome.influenceChange)
            if activeJourney.type.isDecapitation && status == .completed {
                data.successfulDecapitations += 1
            }
        }
        self.activeJourney = nil
        self.heroesOnJourney = []
        self.journeyEnemies = []
        self.activationOrder = []
    }
    func prepareForNewRound() {
        var newOrder: [Activation] = heroesOnJourney.map { Activation(name: $0.name, isHero: true) }
        for _ in 0..<enemyActivationsPerRound {
            newOrder.append(Activation(name: "Hostile Activation", isHero: false))
        }
        self.activationOrder = newOrder.shuffled()
    }
    func moveActivation(from source: IndexSet, to destination: Int) {
        activationOrder.move(fromOffsets: source, toOffset: destination)
    }
}
