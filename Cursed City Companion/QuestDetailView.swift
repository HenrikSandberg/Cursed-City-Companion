import SwiftUI

struct QuestDetailView: View {
    @Binding var quest: Quest
    
    @State private var showingNewJourneySheet = false

    var body: some View {
        ZStack {
            Color.darkstone.edgesIgnoringSafeArea(.all)
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Quest Scores
                    HStack {
                        ScoreView(title: "Influence", score: quest.influence, color: .bloodRed)
                        Spacer()
                        ScoreView(title: "Fear", score: quest.fear, color: .vampireViolet)
                    }
                    .padding(.horizontal)

                    // Last Extraction Event
                    if let lastEvent = quest.lastExtractionEvent {
                        LastExtractionEventView(event: lastEvent)
                            .padding(.horizontal)
                    }

                    // Decapitation Progress
                    DecapitationProgressView(progress: quest.decapitationProgress)
                        .padding(.horizontal)

                    // Heroes
                    Text("Heroes")
                        .font(.title2)
                        .foregroundColor(.cursedGold)
                        .padding(.horizontal)
                    
                    ForEach($quest.heroes) { $hero in
                        NavigationLink(destination: HeroDetailView(hero: $hero)) {
                            HeroRow(hero: hero)
                        }
                    }
                    .padding(.horizontal)
                    
                    // Journeys
                    Text("Completed Journeys")
                        .font(.title2)
                        .foregroundColor(.cursedGold)
                        .padding(.horizontal)
                    
                    if quest.completedJourneys.isEmpty {
                        Text("No journeys completed yet.")
                            .foregroundColor(.parchment)
                            .padding(.horizontal)
                    } else {
                        ForEach(quest.completedJourneys) { journey in
                            NavigationLink(destination: CompletedJourneyDetailView(journey: journey, allHeroes: quest.heroes)) {
                                JourneyRow(journey: journey)
                            }
                        }
                        .padding(.horizontal)
                    }
                    // Active Journey / Start New Journey Buttons
                    if quest.activeJourney != nil {
                        NavigationLink(destination: ActiveJourneyView(quest: $quest)) {
                            Text("Continue Active Journey")
                                .font(.headline)
                                .padding()
                                .background(Color.green)
                                .foregroundColor(.white)
                                .cornerRadius(10)
                                .frame(maxWidth: .infinity)
                        }
                    } else {
                        Button("Start New Journey") {
                            showingNewJourneySheet = true
                        }
                        .font(.headline)
                        .padding()
                        .background(Color.cursedGold)
                        .foregroundColor(.darkstone)
                        .cornerRadius(10)
                        .frame(maxWidth: .infinity)
                    }
                }
            }
        }
        .navigationTitle(quest.name)
        .sheet(isPresented: $showingNewJourneySheet) {
            NewJourneyView(heroes: quest.heroes) { newJourney in
                quest.activeJourney = newJourney
                showingNewJourneySheet = false
            }
        }
    }
}

struct LastExtractionEventView: View {
    let event: ExtractionEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text("Last Extraction Event")
                .font(.headline)
                .foregroundColor(.cursedGold)
            Text(event.rawValue)
                .font(.subheadline).bold()
                .foregroundColor(.parchment)
            Text(event.description)
                .font(.caption)
                .foregroundColor(.gray)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.cursedGold, lineWidth: 1)
        )
    }
}

// --- Other subviews (ScoreView, HeroRow, etc.) remain the same ---
struct ScoreView: View {
    var title: String
    var score: Int
    var color: Color

    var body: some View {
        VStack {
            Text(title)
                .font(.headline)
                .foregroundColor(.cursedGold)
            Text("\(score)")
                .font(.largeTitle)
                .fontWeight(.bold)
                .foregroundColor(color)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct DecapitationProgressView: View {
    var progress: DecapitationProgress
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Decapitation Progress")
                .font(.title2)
                .foregroundColor(.cursedGold)
            
            Text("Fell Guardian: \(progress.fellGuardian ? "Done" : "Pending")")
                .foregroundColor(.parchment)
            Text("Captain of the Damned: \(progress.captainOfTheDamned ? "Done" : "Pending")")
                .foregroundColor(.parchment)
        }
        .padding()
        .background(Color.black.opacity(0.3))
        .cornerRadius(10)
    }
}

struct HeroRow: View {
    var hero: Hero
    
    var body: some View {
        HStack {
            Image(hero.imageName)
                .resizable()
                .frame(width: 50, height: 50)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(hero.name)
                    .font(.headline)
                    .foregroundColor(.parchment)
                Text("Level \(hero.level)")
                    .foregroundColor(.gray)
            }
            Spacer()
            Text(hero.isAlive ? "Alive" : "Dead")
                .foregroundColor(hero.isAlive ? .green : .red)
        }
        .padding()
        .background(Color.vampireViolet.opacity(0.5))
        .cornerRadius(10)
    }
}

struct JourneyRow: View {
    var journey: Journey
    
    var body: some View {
         VStack(alignment: .leading) {
            Text("\(journey.journeyType.rawValue) - Level \(journey.level)")
                .font(.headline)
                .foregroundColor(.parchment)
            
            if let mapName = journey.mapName {
                Text(mapName)
                    .font(.caption)
                    .foregroundColor(.gray)
            }
            
            Text("Success: \(journey.wasSuccessful ? "Yes" : "No")")
                .foregroundColor(journey.wasSuccessful ? .green : .red)
        }
        .padding()
        .background(Color.vampireViolet.opacity(0.5))
        .cornerRadius(10)
    }
}


#if DEBUG
struct QuestDetailView_Previews: PreviewProvider {
    struct PreviewWrapper: View {
        @State var quest: Quest
        
        init() {
            var mockQuest = Quest(name: "Preview Quest", influence: 7, fear: 4)
            mockQuest.completedJourneys.append(Journey(journeyType: .hunt, level: 1, wasSuccessful: true, participatingHeroes: [], enemyGroups: 3))
            mockQuest.heroes[2].isAlive = false
            mockQuest.heroes[1].level = 1
            mockQuest.lastExtractionEvent = .moraleBoost
            _quest = State(initialValue: mockQuest)
        }
        
        var body: some View {
            QuestDetailView(quest: $quest)
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
