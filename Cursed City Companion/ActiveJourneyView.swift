//
//  ActiveJourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//
import SwiftUI

struct ActiveJourneyView: View {
    @EnvironmentObject var viewModel: CampaignViewModel
    @State private var newEnemyName: String = ""
    @State private var newEnemyCount: Int = 1
    @State private var showEndJourneySheet = false

    var body: some View {
        List {
            // Seksjon for aktiveringsrekkefølge
            Section(header: Text("Activation Order")) {
                ForEach(viewModel.activationOrder) { activation in
                    HStack {
                        Image(systemName: activation.isHero ? "person.fill" : "shield.lefthalf.filled")
                            .foregroundColor(activation.isHero ? .blue : .red)
                        Text(activation.name)
                    }
                }
                .onMove(perform: viewModel.moveActivation) // Tillater manuell rekkefølgeendring
            }
            
            // Seksjon for fiender
            Section(header: Text("Enemies on this Journey")) {
                ForEach($viewModel.journeyEnemies) { $enemy in
                    Stepper("\(enemy.count)x \(enemy.name)", value: $enemy.count, in: 0...20)
                }
                .onDelete { indexSet in
                    viewModel.journeyEnemies.remove(atOffsets: indexSet)
                }
                
                HStack {
                    TextField("New Enemy Type", text: $newEnemyName)
                    Button(action: {
                        if !newEnemyName.isEmpty {
                            viewModel.journeyEnemies.append(EnemyGroup(id: UUID(), name: newEnemyName, count: 1))
                            newEnemyName = ""
                        }
                    }) { Image(systemName: "plus.circle.fill") }
                }
            }

            // Seksjon for å styre runden
            Section(header: Text("Round Controls")) {
                Stepper("Enemy Activations: \(viewModel.enemyActivationsPerRound)", value: $viewModel.enemyActivationsPerRound, in: 1...10)
                Button("Prepare Next Round (Shuffle)") {
                    viewModel.prepareForNewRound()
                }
            }

            // Seksjon for å avslutte reisen
            Section {
                Button("End Journey...") { showEndJourneySheet = true }.foregroundColor(.blue)
            }
        }
        .listStyle(InsetGroupedListStyle())
        .navigationTitle(viewModel.activeJourney?.name ?? "Active Journey")
        .navigationBarItems(trailing: EditButton()) // Legger til Edit-knapp for å flytte rader
        .sheet(isPresented: $showEndJourneySheet) {
            EndJourneyView().environmentObject(viewModel)
        }
    }
}
