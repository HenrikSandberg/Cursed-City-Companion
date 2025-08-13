import SwiftUI

struct EndJourneyView: View {
    @EnvironmentObject private var questManager: QuestManager
    let quest: Quest
    let onSaved: () -> Void
    
    @Environment(\.dismiss) private var dismiss

    @State private var wasSuccessful: Bool = true
    @State private var extraction: ExtractionEventDef?
    @State private var survival: [UUID: Bool] = [:]
    @State private var notes: String = ""
    
    private var activeJourney: ActiveJourney? {
        quest.activeJourney
    }
    
    private var extractionEvents: [ExtractionEventDef] {
        ExtractionRegistry.load()
    }

    var body: some View {
        // This guard ensures that the view has a valid active journey to work with.
        // If not, it shows an error and dismisses, preventing crashes.
        guard let activeJourney = activeJourney else {
            return AnyView(
                Text("Error: Active Journey not found.")
                    .onAppear { dismiss() }
            )
        }

        return AnyView(
            ScrollView {
                VStack(spacing: 16) {
                    outcomeSection
                    consequencesPreviewSection
                    ExtractionPicker(defs: extractionEvents, selected: $extraction)
                    survivalSection(participants: activeJourney.participants)
                    notesSection
                    
                    Button {
                        saveAndDismiss()
                    } label: { Label("Save Journey", systemImage: "checkmark.circle.fill") }
                    .buttonStyle(CCPrimaryButton())
                    .disabled(extraction == nil)

                    Spacer(minLength: 30)
                }
                .padding()
            }
            .navigationTitle("End Journey")
            .ccBackground()
            .ccToolbar()
            .onAppear {
                for id in activeJourney.participants {
                    survival[id] = true
                }
                if extraction == nil {
                    extraction = extractionEvents.first
                }
            }
        )
    }
    
    private var outcomeSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Outcome").font(.headline).foregroundStyle(CCTheme.cursedGold)
            Picker("Result", selection: $wasSuccessful) {
                Text("Success").tag(true)
                Text("Failed").tag(false)
            }
            .pickerStyle(.segmented)
        }.ccPanel()
    }
    
    private var consequencesPreviewSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            let previewDelta = wasSuccessful ? extraction?.onSuccess : extraction?.onFailure
            let projectedInfluence = quest.influence + (previewDelta?.influence ?? 0)
            let projectedFear = quest.fear + (previewDelta?.fear ?? 0)
            
            Text("Consequences Preview").font(.headline).foregroundStyle(CCTheme.cursedGold)
            HStack(spacing: 16) {
                Label("Influence: \(projectedInfluence)", systemImage: "flame")
                Label("Fear: \(projectedFear)", systemImage: "exclamationmark.triangle")
            }.font(.subheadline)
            Text("This reflects the selected Extraction Event and journey outcome.")
                .font(.footnote).foregroundStyle(.secondary)
        }
        .ccPanel()
    }

    private func survivalSection(participants: [UUID]) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Survival").font(.headline).foregroundStyle(CCTheme.cursedGold)
            ForEach(participants, id: \.self) { heroId in
                if let hero = quest.heroes.first(where: { $0.id == heroId }) {
                    HeroRow(
                        name: hero.name,
                        aliveBinding: Binding(
                            get: { survival[heroId, default: true] },
                            set: { survival[heroId] = $0 }
                        )
                    )
                }
            }
        }.ccPanel()
    }
    
    private var notesSection: some View {
        VStack(alignment: .leading) {
            Text("Notes").font(.headline).foregroundStyle(CCTheme.cursedGold)
            TextEditor(text: $notes)
                .frame(height: 120)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
        }.ccPanel()
    }
    
    private func saveAndDismiss() {
        guard let extraction = extraction else { return }
        
        questManager.endJourney(
            questId: quest.id,
            wasSuccessful: wasSuccessful,
            survival: survival,
            extraction: extraction,
            notes: notes
        )
        
        dismiss()
        DispatchQueue.main.async {
            onSaved()
        }
    }
}

// HeroRow is a simple view and can remain here.
struct HeroRow: View {
    let name: String
    let aliveBinding: Binding<Bool>

    var body: some View {
        HStack(spacing: 12) {
            Image(name)
                .resizable().scaledToFill().frame(width: 36, height: 36)
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .overlay(RoundedRectangle(cornerRadius: 6).stroke(.secondary.opacity(0.3)))
                .accessibilityHidden(true)
            Toggle(isOn: aliveBinding) {
                Text(name)
            }
        }
    }
}
