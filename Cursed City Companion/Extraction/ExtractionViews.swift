import SwiftUI

struct LastExtractionBanner: View {
    let result: ExtractionEventResult?
    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "arrow.uturn.backward.circle.fill")
                .imageScale(.large)
                .foregroundStyle(CCTheme.cursedGold)
            VStack(alignment: .leading, spacing: 2) {
                if let r = result {
                    Text("Last Extraction: \(r.name)").font(.subheadline.weight(.semibold))
                    Text("Δ Influence \(r.applied.influence >= 0 ? "+" : "")\(r.applied.influence) • Δ Fear \(r.applied.fear >= 0 ? "+" : "")\(r.applied.fear)")
                        .font(.caption).foregroundStyle(CCTheme.parchment)
                } else {
                    Text("No extraction yet").font(.subheadline.weight(.semibold))
                    Text("This will show the last extraction result.").font(.caption).foregroundStyle(.secondary)
                }
            }
            Spacer()
        }.ccPanel()
    }
}

struct ExtractionPicker: View {
    let defs: [ExtractionEventDef]
    @Binding var selected: ExtractionEventDef?
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Extraction Event").font(.headline).foregroundStyle(CCTheme.cursedGold)
            Picker("Extraction", selection: Binding(
                get: { selected?.id ?? "" },
                set: { id in selected = defs.first(where: {$0.id == id}) }
            )) {
                Text("Choose…").tag("")
                ForEach(defs) { d in
                    Text(d.name).tag(d.id)
                }
            }
            .pickerStyle(.menu)
            if let s = selected {
                Text(s.description).font(.footnote).foregroundStyle(CCTheme.parchment).fixedSize(horizontal: false, vertical: true)
            }
        }.ccPanel()
    }
}
