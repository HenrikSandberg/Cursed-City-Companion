import SwiftUI

struct QuestDetailView: View {
    @EnvironmentObject private var store: Store
    let questId: UUID

    @State private var showingNewJourney = false

    var body: some View {
        ZStack {
            ArcadeBackground()
            if let questIndex = store.quests.firstIndex(where: {$0.id == questId}) {
                let questBinding = Binding<Quest>(
                    get: { store.quests[questIndex] },
                    set: { store.quests[questIndex] = $0 }
                )
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Scores
                        HStack(spacing: 12) {
                            ScoreView(title: "Influence", score: questBinding.wrappedValue.influence, color: CCTheme.bloodRed)
                            ScoreView(title: "Fear", score: questBinding.wrappedValue.fear, color: CCTheme.vampireViolet)
                        }

                        // Decapitation row
                        DecapitationRow(state: questBinding.decapitationState, heroes: questBinding.wrappedValue.heroes)

                        // Last extraction
                        LastExtractionBanner(result: questBinding.wrappedValue.lastExtraction)

                        // Heroes
                        VStack(alignment: .leading, spacing: 8) {
                            Text("Heroes").font(.headline).foregroundStyle(CCTheme.cursedGold)
                            ForEach(questBinding.wrappedValue.heroes) { hero in
                                NavigationLink {
                                    HeroDetailView(questId: questBinding.wrappedValue.id, heroId: hero.id)
                                } label: {
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text(hero.name).font(.headline)
                                            Text(hero.alive ? "Alive" : "Fallen")
                                                .font(.caption)
                                                .foregroundColor(hero.alive ? CCTheme.parchment : CCTheme.bloodRed)
                                        }
                                        Spacer()
                                        Text("Lv \(hero.level) • \(hero.experience) XP")
                                            .font(.callout).foregroundStyle(CCTheme.parchment)
                                    }.padding(.vertical, 6)
                                }
                                Divider()
                            }
                        }.ccPanel()

                        // Active Journey
                        if let active = questBinding.wrappedValue.activeJourney {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Active Journey").font(.headline).foregroundStyle(CCTheme.cursedGold)
                                NavigationLink {
                                    ActiveJourneyView(questId: questBinding.wrappedValue.id)
                                } label: {
                                    VStack(alignment: .leading, spacing: 6) {
                                        Text("\(active.type.rawValue) • Level \(active.level)").font(.headline)
                                        Text("Participants: \(active.participants.count) • Enemy groups: \(active.enemyGroups)")
                                            .font(.callout).foregroundStyle(CCTheme.parchment.opacity(0.9))
                                    }
                                }
                            }.ccPanel()
                        }

                        // Completed journeys
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Previous Journeys").font(.headline).foregroundStyle(CCTheme.cursedGold)
                            if store.quests[questIndex].completedJourneys.isEmpty {
                                Text("No journeys yet.").foregroundStyle(CCTheme.parchment.opacity(0.8))
                            } else {
                                ForEach(store.quests[questIndex].completedJourneys) { j in
                                    NavigationLink {
                                        CompletedJourneyDetailView(questId: questBinding.wrappedValue.id, journeyId: j.id)
                                    } label: {
                                        VStack(alignment: .leading, spacing: 4) {
                                            Text("\(j.type.rawValue) • Level \(j.level)").font(.headline)
                                            HStack {
                                                Text(j.startedAt, style: .date)
                                                Text("• \(j.wasSuccessful ? "Success" : "Failed")")
                                            }.foregroundStyle(CCTheme.parchment.opacity(0.9)).font(.callout)
                                        }
                                    }
                                    Divider()
                                }
                            }
                        }.ccPanel()

                        Spacer(minLength: 40)
                    }
                    .padding()
                }
                .safeAreaInset(edge: .bottom) {
                    HStack {
                        Button {
                            showingNewJourney = true
                        } label: {
                            Label("New Journey", systemImage: "flag.checkered")
                                .font(.headline)
                                .padding()
                                .frame(maxWidth: .infinity)
                        }
                        .buttonStyle(CCPrimaryButton())
                    }
                    .padding()
                    .background(.ultraThinMaterial)
                }
                .sheet(isPresented: $showingNewJourney) {
                    NewJourneyView(questId: questBinding.wrappedValue.id)
                        .presentationDetents([.medium, .large])
                }
                .navigationTitle(store.quests[questIndex].name)
                .ccToolbar()
            } else {
                Text("Quest not found").foregroundStyle(.red)
            }
        }
    }
}
