import SwiftUI

struct EndJourneyView: View {
    @Binding var quest: Quest
    @Binding var journey: Journey?
    @Environment(\.presentationMode) var presentationMode

    @State private var wasSuccessful: Bool = false
    @State private var realmstoneGained: Int = 0
    @State private var selectedEvent: ExtractionEvent = .cleanEscape
    @State private var heroesOutOfActionIDs: Set<UUID> = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Journey Outcome")) {
                    Toggle("Was the journey successful?", isOn: $wasSuccessful)
                    Stepper("Realmstone Gained: \(realmstoneGained)", value: $realmstoneGained, in: 0...100)
                }
                
                Section(header: Text("Extraction Event")) {
                    Picker("Select Event", selection: $selectedEvent) {
                        ForEach(ExtractionEvent.allCases) { event in
                            Text(event.rawValue).tag(event)
                        }
                    }
                    Text(selectedEvent.description)
                        .font(.caption)
                        .foregroundColor(.gray)
                }
                
                Section(header: Text("Heroes Taken Out of Action")) {
                    let participatingHeroes = quest.heroes.filter {
                        journey?.participatingHeroes.contains($0.id) ?? false
                    }
                    if participatingHeroes.isEmpty {
                        Text("No heroes participated.")
                    } else {
                        ForEach(participatingHeroes) { hero in
                            MultipleSelectionRow(title: hero.name, isSelected: heroesOutOfActionIDs.contains(hero.id)) {
                                if heroesOutOfActionIDs.contains(hero.id) {
                                    heroesOutOfActionIDs.remove(hero.id)
                                } else {
                                    heroesOutOfActionIDs.insert(hero.id)
                                }
                            }
                        }
                    }
                }
                
                Section(header: Text("Consequences")) {
                    Text("Fear Change: \(fearChangeDescription)")
                        .foregroundColor(fearChange > 0 ? .red : (fearChange < 0 ? .green : .primary))
                    Text("Influence Change: \(influenceChangeDescription)")
                        .foregroundColor(influenceChange > 0 ? .red : (influenceChange < 0 ? .green : .primary))
                }
                
                Section(header: Text("Hero Advancement")) {
                    // ... (This section remains unchanged)
                }
                
                Button("Finalize Journey") {
                    finalizeJourney()
                    presentationMode.wrappedValue.dismiss()
                }
            }
            .navigationTitle("End of Journey")
        }
    }
    
    // MARK: - Computed Properties for UI Preview
    
    private var fearChange: Int {
        guard let currentJourney = journey else { return 0 }
        var change = 0
        switch currentJourney.journeyType {
        case .hunt: change = 1
        case .scavenge: change = 1
        case .deliverance: change = wasSuccessful ? -2 : 0
        case .decapitation: change = wasSuccessful ? -1 : 1
        }
        if selectedEvent == .moraleBoost {
            change -= 1
        }
        return change
    }
    
    private var influenceChange: Int {
        guard let currentJourney = journey else { return 0 }
        var change = 0
        switch currentJourney.journeyType {
        case .hunt: change = wasSuccessful ? -2 : 0
        case .scavenge: change = 1
        case .deliverance: change = 1
        case .decapitation: change = wasSuccessful ? -1 : 1
        }
        if selectedEvent == .opportunisticSalvo {
            change -= 1
        }
        return change
    }
    
    private var fearChangeDescription: String {
        fearChange > 0 ? "+\(fearChange)" : "\(fearChange)"
    }
    
    private var influenceChangeDescription: String {
        influenceChange > 0 ? "+\(influenceChange)" : "\(influenceChange)"
    }
    
    // ... (Hero advancement computed properties remain unchanged)
    
    // MARK: - Finalization Logic
    
    private func finalizeJourney() {
        guard var completedJourney = journey else { return }
        
        // 1. Update the journey with final details
        completedJourney.wasSuccessful = wasSuccessful
        completedJourney.extractionEvent = selectedEvent
        completedJourney.heroesTakenOutOfAction = Array(heroesOutOfActionIDs)
        
        // 2. Apply consequences and experience
        applyConsequencesAndExperience(for: completedJourney)
        applyExtractionEventEffects()
        
        // 3. Update the quest object
        quest.realmstone += realmstoneGained
        quest.completedJourneys.append(completedJourney)
        quest.lastExtractionEvent = selectedEvent
        
        // 4. Reset hero 'out of action' status for the next journey
        for i in quest.heroes.indices {
            quest.heroes[i].isOutOfAction = false
        }
        
        // 5. Clear the active journey
        journey = nil
    }
    
    private func applyConsequencesAndExperience(for journey: Journey) {
        // --- Update Fear & Influence from Journey Type ---
        var fearDelta = 0
        var influenceDelta = 0
        
        switch journey.journeyType {
        case .hunt:
            fearDelta = 1
            if wasSuccessful { influenceDelta = -2 }
        case .scavenge:
            fearDelta = 1
            influenceDelta = 1
        case .deliverance:
            if wasSuccessful { fearDelta = -2 }
            influenceDelta = 1
        case .decapitation:
            if wasSuccessful {
                fearDelta = -1
                influenceDelta = -1
            } else {
                fearDelta = 1
                influenceDelta = 1
            }
        }
        quest.fear = min(10, max(0, quest.fear + fearDelta))
        quest.influence = min(10, max(0, quest.influence + influenceDelta))

        // --- Update Hero Experience ---
        if wasSuccessful {
            for heroID in journey.participatingHeroes {
                if let heroIndex = quest.heroes.firstIndex(where: { $0.id == heroID }) {
                    if quest.heroes[heroIndex].level < journey.level {
                        quest.heroes[heroIndex].experience += 1
                        if quest.heroes[heroIndex].experience >= 2 {
                            quest.heroes[heroIndex].level += 1
                            quest.heroes[heroIndex].experience = 0
                        }
                    }
                }
            }
        }
    }
    
    private func applyExtractionEventEffects() {
        // Apply immediate effects from the selected event
        switch selectedEvent {
        case .opportunisticSalvo:
            quest.influence = max(5, quest.influence - 1)
        case .moraleBoost:
            quest.fear = max(5, quest.fear - 1)
        case .itemsLost:
            for i in quest.heroes.indices {
                quest.heroes[i].treasureCards.removeAll()
            }
        default:
            break
        }
    }
}

// MARK: - Shared Row for Multiselection
struct MultipleSelectionRow: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                Text(title)
                if isSelected {
                    Spacer()
                    Image(systemName: "checkmark")
                }
            }
        }
    }
}
