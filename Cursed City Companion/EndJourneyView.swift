//
//  EndJourneyView.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import SwiftUI


struct EndJourneyView: View {
    @EnvironmentObject var viewModel: CampaignViewModel
    @Environment(\.presentationMode) var presentationMode
    @State private var journeyStatus: Journey.Status = .completed

    var body: some View {
        NavigationView {
            Form {
                Section(header: Text("Resultat av reisen")) {
                    Picker("Status", selection: $journeyStatus) {
                        Text("Success").tag(Journey.Status.completed)
                        Text("Failure").tag(Journey.Status.failed)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    
                    // Viser konsekvensen basert på valgt status
                    let outcome = journeyStatus == .completed ? viewModel.activeJourney?.type.successOutcome : viewModel.activeJourney?.type.failureOutcome
                    if let outcome = outcome {
                        Text(outcome.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Fear: \(outcome.fearChange > 0 ? "+" : "")\(outcome.fearChange), Influence: \(outcome.influenceChange > 0 ? "+" : "")\(outcome.influenceChange)")
                            .font(.subheadline)
                    }
                }
                
                Button("Confirm and End Journey") {
                    viewModel.endJourney(status: journeyStatus)
                    presentationMode.wrappedValue.dismiss()
                }
                .foregroundColor(.red)
            }
            .navigationTitle("End Journey")
            .navigationBarItems(leading: Button("Cancel") { presentationMode.wrappedValue.dismiss() })
        }
    }
}
