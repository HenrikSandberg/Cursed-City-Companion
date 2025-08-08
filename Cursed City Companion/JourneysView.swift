//
//  JourneysView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import SwiftUI


struct JourneysView: View {
    @EnvironmentObject var viewModel: CampaignViewModel
    @State private var journeyToStart: Journey?

    var body: some View {
        List {
            Section(header: Text("Tilgjengelige reiser")) {
                ForEach(viewModel.data.journeys.filter { $0.status == .notStarted }) { journey in
                    Button(action: { self.journeyToStart = journey }) {
                        HStack {
                            Text(journey.name).foregroundColor(.primary)
                            Spacer()
                            Text(journey.type.name).font(.caption).foregroundColor(.secondary)
                        }
                    }
                }
            }
            
            Section(header: Text("Fullførte/Feilede reiser")) {
                ForEach(viewModel.data.journeys.filter { $0.status != .notStarted }) { journey in
                     VStack(alignment: .leading) {
                        Text(journey.name).strikethrough()
                        Text("Status: \(journey.status.rawValue)").font(.caption)
                    }
                }
            }
        }
        .navigationTitle("Journeys")
        .sheet(item: $journeyToStart) { journey in
            StartJourneyView(journeyToStart: journey).environmentObject(viewModel)
        }
    }
}
