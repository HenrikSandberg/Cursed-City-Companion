import SwiftUI

struct DecapitationIconView: View {
    struct State {
        var locked: Bool
        var completed: Bool
        var active: Bool
        var reason: String?
    }

    let def: DecapitationDefinition
    let state: State
    let tap: (() -> Void)?

    var body: some View {
        VStack(spacing: 6) {
            ZStack {
                Image(def.iconAsset)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 64, height: 64)
                    .saturation(state.locked ? 0 : 1)
                    .brightness(state.locked ? -0.15 : 0)
                    .overlay(activeRing)
                    .overlay(xOutOverlay)
                    .overlay(lockOverlay, alignment: .topTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Color.clear.contentShape(Rectangle())
            }
            .onTapGesture { if !state.locked { tap?() } }

            Text(def.displayName)
                .font(.caption.weight(.semibold))
                .foregroundStyle(CCTheme.parchment)
                .multilineTextAlignment(.center)
                .frame(width: 80)
        }
        .help(state.locked ? (state.reason ?? "Locked") : def.displayName)
        .padding(.horizontal, 4)
    }

    private var activeRing: some View {
        Group {
            if state.active {
                RoundedRectangle(cornerRadius: 12).stroke(CCTheme.teal, lineWidth: 3).shadow(radius: 3)
            }
        }
    }
    private var lockOverlay: some View {
        Group {
            if state.locked {
                Image(systemName: "lock.fill")
                    .foregroundStyle(CCTheme.cursedGold)
                    .padding(6).background(.ultraThinMaterial, in: Circle()).padding(4)
            }
        }
    }
    private var xOutOverlay: some View {
        Group {
            if state.completed {
                GeometryReader { geo in
                    Path { p in
                        p.move(to: .zero); p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                        p.move(to: CGPoint(x: geo.size.width, y: 0)); p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    }
                    .stroke(CCTheme.bloodRed, style: .init(lineWidth: 4, lineCap: .round))
                }
            }
        }
    }
}

struct DecapitationRow: View {
    @Binding var state: DecapitationState
    let heroes: [Hero]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Decapitation").font(.headline).foregroundStyle(CCTheme.cursedGold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(DecapitationRegistry.all) { d in
                        let eligible = isEligible(d)
                        DecapitationIconView(def: d, state: .init(
                            locked: !eligible.allowed, completed: state.completedIDs.contains(d.id),
                            active: state.activeID == d.id, reason: eligible.reason
                        ), tap: { state.activeID = d.id })
                    }
                }.padding(.vertical, 4)
            }
        }.ccPanel()
    }

    private func isEligible(_ def: DecapitationDefinition) -> (allowed: Bool, reason: String?) {
        guard heroes.count == 4 else { return (false, "Requires 4 heroes") }
        let ok = heroes.allSatisfy { $0.level == def.requiredPartyLevel && $0.alive }
        return (ok, ok ? nil : "All 4 heroes must be Level \(def.requiredPartyLevel)")
    }
}
