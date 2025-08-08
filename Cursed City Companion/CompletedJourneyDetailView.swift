//
//  CompletedJourneyDetailView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct CompletedJourneyDetailView: View {
    let journey: Journey
    let allHeroes: [Hero]

    var body: some View {
        ZStack {
            Color.darkstone.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    
                    // Basic Info
                    InfoRow(label: "Journey Type", value: journey.journeyType.rawValue)
                    if let map = journey.mapName {
                        InfoRow(label: "Map", value: map)
                    }
                    InfoRow(label: "Outcome", value: journey.wasSuccessful ? "Success" : "Failure", valueColor: journey.wasSuccessful ? .green : .red)
                    
                    // Extraction Event
                    if let event = journey.extractionEvent {
                        VStack(alignment: .leading) {
                            Text("Extraction Event")
                                .font(.headline)
                                .foregroundColor(.cursedGold)
                            Text(event.rawValue)
                                .foregroundColor(.parchment)
                            Text(event.description)
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 5)
                    }
                    
                    // Participating Heroes
                    SectionView(title: "Participating Heroes") {
                        ForEach(participatingHeroes) { hero in
                            Text(hero.name)
                                .foregroundColor(.parchment)
                        }
                    }
                    
                    // Heroes Taken Out of Action
                    SectionView(title: "Heroes Taken Out of Action") {
                        if heroesTakenOutOfAction.isEmpty {
                            Text("None")
                                .foregroundColor(.gray)
                        } else {
                            ForEach(heroesTakenOutOfAction) { hero in
                                Text(hero.name)
                                    .foregroundColor(.bloodRed)
                            }
                        }
                    }
                }
                .padding()
            }
        }
        .navigationTitle("Journey Summary")
    }
    
    // Helper computed properties to find hero names from IDs
    private var participatingHeroes: [Hero] {
        allHeroes.filter { journey.participatingHeroes.contains($0.id) }
    }
    
    private var heroesTakenOutOfAction: [Hero] {
        allHeroes.filter { journey.heroesTakenOutOfAction.contains($0.id) }
    }
}

// Helper view for consistent layout
struct InfoRow: View {
    let label: String
    let value: String
    var valueColor: Color = .parchment

    var body: some View {
        HStack {
            Text(label)
                .foregroundColor(.cursedGold)
            Spacer()
            Text(value)
                .foregroundColor(valueColor)
                .fontWeight(.bold)
        }
    }
}

// Helper for section layout
struct SectionView<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.title2)
                .foregroundColor(.cursedGold)
            Divider().background(Color.cursedGold)
            content
        }
    }
}


#if DEBUG
struct CompletedJourneyDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let heroes = Hero.defaultHeroes
        let journey = Journey(
            journeyType: .hunt,
            level: 1,
            mapName: "The Hunting Grounds",
            wasSuccessful: true,
            extractionEvent: .moraleBoost,
            heroesTakenOutOfAction: [heroes[1].id],
            participatingHeroes: [heroes[0].id, heroes[1].id, heroes[2].id],
            enemyGroups: 3
        )
        
        NavigationView {
            CompletedJourneyDetailView(journey: journey, allHeroes: heroes)
        }
        .preferredColorScheme(.dark)
    }
}
#endif
