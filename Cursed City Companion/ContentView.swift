import SwiftUI
import Combine

// MARK: - SwiftUI Views (Skjermbilder)
struct ContentView: View {
    @StateObject private var viewModel = CampaignViewModel()

    var body: some View {
        NavigationView {
            if viewModel.activeJourney != nil {
                ActiveJourneyView()
                    .environmentObject(viewModel)
            } else {
                // Riktig måte: Ingen argumenter i parantesen
                CampaignDashboardView()
                    .environmentObject(viewModel) // Denne linjen gjør jobben
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

@main
struct CursedCityCompanionApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}
