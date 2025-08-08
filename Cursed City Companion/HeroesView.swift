//
//  HeroesView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//
import SwiftUI


struct HeroesView: View {
    @EnvironmentObject var viewModel: CampaignViewModel

    var body: some View {
        List {
            ForEach($viewModel.data.heroes) { $hero in
                VStack(alignment: .leading) {
                    HStack {
                        Toggle(isOn: $hero.isAlive) {
                            Text(hero.name).font(.headline)
                        }
                        .tint(.green)
                    }
                    Stepper("Level: \(hero.level)", value: $hero.level, in: 1...4)
                    Toggle("Is Novice?", isOn: $hero.isNovice)
                }
                .padding(.vertical, 4)
            }
        }
        .navigationTitle("Heroes Roster")
    }
}
