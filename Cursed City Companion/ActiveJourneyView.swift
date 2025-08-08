//
//  ActiveJourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//


import SwiftUI

struct ActiveJourneyView: View {
    @Binding var quest: Quest
    @State private var showingEndJourney = false

    var body: some View {
        ZStack {
            Color.darkstone.edgesIgnoringSafeArea(.all)
            
            // Ensure we have an active journey to work with
            if let journeyBinding = Binding($quest.activeJourney) {
                let journey = journeyBinding.wrappedValue
                
                VStack {
                    Text("\(journey.journeyType.rawValue) - Turn \(journey.turn)")
                        .font(.largeTitle)
                        .foregroundColor(.cursedGold)
                        .padding()
                    
                    List {
                        ForEach(journeyBinding.initiativeOrder) { participant in
                            InitiativeRow(participant: participant.wrappedValue, heroes: $quest.heroes)
                        }
                        .onMove(perform: { indices, newOffset in
                            moveInitiative(from: indices, to: newOffset)
                        })
                        .listRowBackground(Color.vampireViolet.opacity(0.5))
                    }
                    
                    HStack {
                        Button("Next Turn") {
                            nextTurn()
                        }
                        .padding()
                        .background(Color.cursedGold)
                        .foregroundColor(.darkstone)
                        .cornerRadius(10)
                        
                        Spacer()
                        
                        Button("End Journey") {
                            showingEndJourney = true
                        }
                        .padding()
                        .background(Color.bloodRed)
                        .foregroundColor(.parchment)
                        .cornerRadius(10)
                    }
                    .padding()
                }
                .navigationTitle("Active Journey")
                .navigationBarTitleDisplayMode(.inline)
                .sheet(isPresented: $showingEndJourney) {
                    // Pass the binding to the active journey (as Binding<Journey?>)
                    EndJourneyView(quest: $quest, journey: $quest.activeJourney)
                }
            } else {
                Text("No Active Journey")
                    .foregroundColor(.parchment)
            }
        }
    }
    
    private func moveInitiative(from source: IndexSet, to destination: Int) {
        quest.activeJourney?.initiativeOrder.move(fromOffsets: source, toOffset: destination)
    }
    
    private func nextTurn() {
        guard quest.activeJourney != nil else { return }
        quest.activeJourney?.turn += 1
        quest.activeJourney?.initiativeOrder.shuffle()
    }
}

struct InitiativeRow: View {
    let participant: InitiativeParticipant
    @Binding var heroes: [Hero]
    
    var body: some View {
        HStack {
            Text(participant.name)
                .foregroundColor(.parchment)
            
            Spacer()
            
            if participant.isHero, let heroID = participant.heroID {
                if let heroIndex = heroes.firstIndex(where: { $0.id == heroID }) {
                    Toggle("Out?", isOn: $heroes[heroIndex].isOutOfAction)
                        .labelsHidden()
                        .tint(.bloodRed)
                }
            }
        }
    }
}

#if DEBUG
struct ActiveJourneyView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var quest: Quest
        
        init() {
            var tempQuest = Quest(name: "Preview Quest")
            let heroIDs = [tempQuest.heroes[0].id, tempQuest.heroes[1].id]
            var journey = Journey(journeyType: .hunt, level: 1, wasSuccessful: false, participatingHeroes: heroIDs, enemyGroups: 2)
            journey.initiativeOrder = [
                InitiativeParticipant(name: tempQuest.heroes[0].name, isHero: true, heroID: tempQuest.heroes[0].id),
                InitiativeParticipant(name: "Enemy Group 1", isHero: false),
                InitiativeParticipant(name: tempQuest.heroes[1].name, isHero: true, heroID: tempQuest.heroes[1].id),
                InitiativeParticipant(name: "Enemy Group 2", isHero: false)
            ]
            tempQuest.activeJourney = journey
            _quest = State(initialValue: tempQuest)
        }
        
        var body: some View {
            ActiveJourneyView(quest: $quest)
        }
    }
    
    static var previews: some View {
        NavigationView {
            PreviewWrapper()
        }
        .preferredColorScheme(.dark)
    }
}
#endif

