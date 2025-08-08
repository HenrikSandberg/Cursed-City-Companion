//
//  CampaignDashboardView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import SwiftUI

struct StatusHeaderView: View {
    let fear: Int
    let influence: Int

    var body: some View {
        ZStack {
            // Programmatisk gradient som erstatter bildet.
            // Den går fra en mørk rød til sort, for å matche Warhammer-temaet.
            LinearGradient(
                gradient: Gradient(colors: [Color.red.opacity(0.6), Color.black]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea(edges: .top)

            HStack(spacing: 40) {
                StatusView(title: "FEAR", value: fear)
                StatusView(title: "INFLUENCE", value: influence)
            }
            .padding(.vertical, 40)
        }
        .frame(height: 200)
        .clipped()
    }
}

struct StatusView: View {
    let title: String
    let value: Int
    
    var body: some View {
        VStack {
            Text(title)
                .font(.custom("Papyrus", size: 28))
                .foregroundColor(.white.opacity(0.8))
            
            Text("\(value)")
                .font(.system(size: 80, weight: .bold, design: .serif))
                .foregroundColor(value > 7 ? .red : .white) // Blir rød når verdien er høy
                .shadow(color: .black.opacity(0.5), radius: 5, x: 0, y: 5)
        }
    }
}

struct DecapitationTrackerView: View {
    let journeys: [Journey]
    let completedCount: Int

    var body: some View {
        HStack {
            ForEach(0..<journeys.count, id: \.self) { index in
                VStack {
                    ZStack {
                        // Bruk SF Symbols som plassholdere inntil du har egne bilder
                        Image(systemName: "x.squareroot")
                            .font(.system(size: 40))
                            .foregroundColor(.gray)
                        
                        // Viser et "fullført"-stempel
                        if index < completedCount {
                            Image(systemName: "checkmark.seal.fill")
                                .font(.system(size: 50))
                                .foregroundColor(.red.opacity(0.8))
                        }
                    }
                    .frame(width: 70, height: 70)
                    
                    Text(journeys[index].name)
                        .font(.caption2)
                        .lineLimit(2)
                        .multilineTextAlignment(.center)
                        .frame(height: 30)
                }
                
                if index < journeys.count - 1 {
                    Spacer()
                }
            }
        }
    }
}

struct HeroPortraitView: View {
    let hero: Hero
    
    var body: some View {
        VStack {
            Image(hero.portetName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .shadow(color: .red.opacity(0.5), radius: 8, x: 0, y: 4)
                .grayscale(hero.isAlive ? 0 : 0.5)

            Text(hero.name)
                .font(.headline)
                .foregroundColor(hero.isAlive ? .white : .gray) // Grå tekst hvis død
                .multilineTextAlignment(.center)
            
            Text("Level \(hero.level)")
                .font(.subheadline)
                .foregroundColor(.gray)
        }
    }
}


struct CampaignDashboardView: View {
    @EnvironmentObject var viewModel: CampaignViewModel

    // Definerer en grid layout for heltene
    private let heroGridColumns = [GridItem(.adaptive(minimum: 160))]

    var body: some View {
        ZStack {
            // Svart bakgrunnsfarge for hele skjermen
            Color.black.ignoresSafeArea()

            ScrollView {
                VStack(spacing: 0) {
                    // 1. TOPP-SEKSJON: Fear og Influence
                    StatusHeaderView(
                        fear: viewModel.data.fearLevel,
                        influence: viewModel.data.influenceLevel
                    )

                    // 2. MIDT-SEKSJON: Decapitation-oppdrag
                    VStack {
                        Text("Decapitation Missions")
                            .font(.custom("Papyrus", size: 22))
                            .foregroundColor(.white)
                            .padding(.top)
                        
                        DecapitationTrackerView(
                            journeys: viewModel.decapitationJourneys,
                            completedCount: viewModel.data.successfulDecapitations // <--- FIX: Verdien var glemt her
                        )
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                    .background(Color.black.opacity(0.5)) // Lett gjennomsiktig bakgrunn
                    
                    Divider().background(Color.red.opacity(0.5)).frame(height: 2)


                    // 3. BÅNN-SEKSJON: Heltegalleri
                    Text("The Survivors of Ulfenkarn")
                        .font(.custom("Papyrus", size: 24))
                        .foregroundColor(.white)
                        .padding()
                    
                    LazyVGrid(columns: heroGridColumns, spacing: 20) {
                        ForEach(viewModel.data.heroes) { hero in
                            NavigationLink(destination: HeroesView().environmentObject(viewModel)) {
                                HeroPortraitView(hero: hero)
                            }
                        }
                    }
                    .padding()
                }
                NavigationLink(destination: JourneysView().environmentObject(viewModel)) {
                     Label("Start New Journey", systemImage: "dices.fill")
                }
                .buttonStyle(CursedCityButtonStyle())
                .padding()
                .background(Color.black.opacity(0.7))
            }
        }
        .navigationBarHidden(true) // Skjuler standard navigasjonsbar for et renere utseende
    }
}

struct CursedCityButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.title2.weight(.bold))
            .padding()
            .frame(maxWidth: .infinity)
            .foregroundColor(.white)
            .background(Color.red.opacity(0.7))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.red, lineWidth: 2)
            )
            .shadow(color: .red.opacity(0.5), radius: 5, x: 0, y: 5)
            .scaleEffect(configuration.isPressed ? 0.97 : 1.0)
            .animation(.easeOut(duration: 0.15), value: configuration.isPressed)
    }
}

struct CampaignDashboardView_Previews: PreviewProvider {
    static var previews: some View {
        NavigationView {
            CampaignDashboardView()
                .environmentObject(CampaignViewModel())
        }
        .previewDevice("iPad (9th generation)")
        .previewInterfaceOrientation(.portrait)
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
