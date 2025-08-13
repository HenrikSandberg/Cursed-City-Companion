import SwiftUI

// MARK: - Navigation Payloads
// We define specific types for navigation to avoid conflicts when multiple
// destinations expect a UUID. This makes navigation strongly typed and safe.
struct HeroNavigation: Hashable {
    let questId: UUID
    let heroId: UUID
}

struct QuestDetailView: View {
    @EnvironmentObject private var questManager: QuestManager
    // The view now only needs the ID of the quest it should display.
    let questId: UUID

    @State private var showingNewJourney = false

    // A computed property to get the most up-to-date quest object from the manager.
    // This is the key to fixing the crash. It always fetches fresh data.
    private var quest: Quest? {
        questManager.quests.first { $0.id == questId }
    }

    var body: some View {
        if let quest = quest {
            ZStack {
                ArcadeBackground()
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack(spacing: 12) {
                            ScoreView(title: "Influence", score: quest.influence, color: CCTheme.bloodRed)
                            ScoreView(title: "Fear", score: quest.fear, color: CCTheme.vampireViolet)
                        }
                        DecapitationRow(quest: quest)
                        LastExtractionBanner(result: quest.lastExtraction)
                        HeroesListView(quest: quest)
                        
                        if let activeJourney = quest.activeJourney {
                           ActiveJourneyBanner(quest: quest, journey: activeJourney)
                        }
                        
                        CompletedJourneysListView(quest: quest)
                        Spacer(minLength: 40)
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    newJourneyButton(quest: quest)
                }
                .sheet(isPresented: $showingNewJourney) {
                    NewJourneyView(quest: quest, onStarted: {
                        showingNewJourney = false
                    })
                    .presentationDetents([.medium, .large])
                }
                .navigationTitle(quest.name)
                // Navigation destinations for different types of data.
                .navigationDestination(for: HeroNavigation.self) { nav in
                    HeroDetailView(questId: nav.questId, heroId: nav.heroId)
                }
                .navigationDestination(for: ActiveJourney.self) { journey in
                    // We pass the questId to ensure the next view also gets fresh data.
                    ActiveJourneyView(questId: quest.id)
                }
                .navigationDestination(for: CompletedJourney.self) { journey in
                    CompletedJourneyDetailView(journey: journey, quest: quest)
                }
                .ccToolbar()
            }
        } else {
            // Display a loading view while the quest data is being loaded.
            ProgressView()
        }
    }
    
    private func newJourneyButton(quest: Quest) -> some View {
        HStack {
            Button {
                showingNewJourney = true
            } label: {
                Label("New Journey", systemImage: "flag.checkered")
                    .font(.headline).padding().frame(maxWidth: .infinity)
            }
            .buttonStyle(CCPrimaryButton())
            .disabled(quest.activeJourney != nil)
        }
        .padding().background(.ultraThinMaterial)
    }
}

// MARK: - Subviews for QuestDetailView

struct HeroesListView: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Heroes").font(.headline).foregroundStyle(CCTheme.cursedGold)
            ForEach(quest.heroes) { hero in
                // Navigate using the specific HeroNavigation type.
                NavigationLink(value: HeroNavigation(questId: quest.id, heroId: hero.id)) {
                    HeroListRow(hero: hero)
                }
                Divider().background(CCTheme.cursedGold.opacity(0.3))
            }
        }.ccPanel()
    }
}

struct HeroListRow: View {
    let hero: Hero
    var body: some View {
        HStack(spacing: 12) {
            Image(hero.name).resizable().scaledToFill().frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
            VStack(alignment: .leading) {
                Text(hero.name).font(.headline)
                Text(hero.alive ? "Alive" : "Fallen").font(.caption)
                    .foregroundColor(hero.alive ? CCTheme.parchment : CCTheme.bloodRed)
            }
            Spacer()
            Text("Lv \(hero.level) • \(hero.experience) XP").font(.callout).foregroundStyle(CCTheme.parchment)
        }.padding(.vertical, 6)
    }
}

struct ActiveJourneyBanner: View {
    let quest: Quest
    let journey: ActiveJourney
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Active Journey").font(.headline).foregroundStyle(CCTheme.cursedGold)
            // Navigate using the ActiveJourney object itself (it's Hashable).
            NavigationLink(value: journey) {
                VStack(alignment: .leading, spacing: 6) {
                    Text("\(journey.type.rawValue) • Level \(journey.level)").font(.headline)
                    Text("Participants: \(journey.participants.count) • Enemy groups: \(journey.enemyGroups)")
                        .font(.callout).foregroundStyle(CCTheme.parchment.opacity(0.9))
                }
            }
        }.ccPanel()
    }
}

struct CompletedJourneysListView: View {
    let quest: Quest
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Previous Journeys").font(.headline).foregroundStyle(CCTheme.cursedGold)
            if quest.completedJourneys.isEmpty {
                Text("No journeys yet.").foregroundStyle(CCTheme.parchment.opacity(0.8))
            } else {
                ForEach(quest.completedJourneys) { journey in
                    // Navigate using the CompletedJourney object (it's Hashable).
                    NavigationLink(value: journey) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text("\(journey.type.rawValue) • Level \(journey.level)").font(.headline)
                            HStack {
                                Text(journey.startedAt, style: .date)
                                Text("• \(journey.wasSuccessful ? "Success" : "Failed")")
                            }.foregroundStyle(CCTheme.parchment.opacity(0.9)).font(.callout)
                        }
                    }
                    Divider().background(CCTheme.cursedGold.opacity(0.3))
                }
            }
        }.ccPanel()
    }
}
