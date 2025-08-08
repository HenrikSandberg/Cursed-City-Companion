//
//  StartJourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import SwiftUI


struct StartJourneyView: View {
    @EnvironmentObject var viewModel: CampaignViewModel
    @Environment(\.presentationMode) var presentationMode
    
    let journeyToStart: Journey
    @State private var selectedHeroes: [Hero] = []

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Velg helter (maks 4)")) {
                    List(viewModel.data.heroes.filter { $0.isAlive }) { hero in
                        Button(action: {
                            if let index = selectedHeroes.firstIndex(where: { $0.id == hero.id }) {
                                selectedHeroes.remove(at: index)
                            } else if selectedHeroes.count < 4 {
                                selectedHeroes.append(hero)
                            }
                        }) {
                            HStack {
                                Text(hero.name)
                                if selectedHeroes.contains(where: { $0.id == hero.id }) {
                                    Spacer()
                                    Image(systemName: "checkmark")
                                }
                            }
                        }
                    }
                }
                
                Button("Start Journey") {
                    viewModel.startJourney(journey: journeyToStart, participatingHeroes: selectedHeroes)
                    presentationMode.wrappedValue.dismiss()
                }
                .disabled(selectedHeroes.isEmpty)
            }
            .navigationTitle("Start: \(journeyToStart.name)")
        }
    }
}
