import SwiftUI

// This subview is purely presentational and remains unchanged.
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
                    .resizable().scaledToFit().frame(width: 64, height: 64)
                    .saturation(state.locked ? 0 : 1)
                    .brightness(state.locked ? -0.15 : 0)
                    .overlay(activeRing).overlay(xOutOverlay)
                    .overlay(lockOverlay, alignment: .topTrailing)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                Color.clear.contentShape(Rectangle())
            }
            .onTapGesture { if !state.locked { tap?() } }

            Text(def.displayName).font(.caption.weight(.semibold))
                .foregroundStyle(CCTheme.parchment)
                .multilineTextAlignment(.center).frame(width: 80)
        }
        .help(state.locked ? (state.reason ?? "Locked") : def.displayName)
        .padding(.horizontal, 4)
    }

    private var activeRing: some View {
        Group { if state.active { RoundedRectangle(cornerRadius: 12).stroke(CCTheme.teal, lineWidth: 3).shadow(radius: 3) } }
    }
    private var lockOverlay: some View {
        Group { if state.locked { Image(systemName: "lock.fill").foregroundStyle(CCTheme.cursedGold).padding(6).background(.ultraThinMaterial, in: Circle()).padding(4) } }
    }
    private var xOutOverlay: some View {
        Group {
            if state.completed {
                GeometryReader { geo in
                    Path { p in
                        p.move(to: .zero); p.addLine(to: CGPoint(x: geo.size.width, y: geo.size.height))
                        p.move(to: CGPoint(x: geo.size.width, y: 0)); p.addLine(to: CGPoint(x: 0, y: geo.size.height))
                    }.stroke(CCTheme.bloodRed, style: .init(lineWidth: 4, lineCap: .round))
                }
            }
        }
    }
}


struct DecapitationRow: View {
    @EnvironmentObject private var questManager: QuestManager
    let quest: Quest

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Decapitation").font(.headline).foregroundStyle(CCTheme.cursedGold)
            ScrollView(.horizontal, showsIndicators: false) {
                HStack {
                    ForEach(DecapitationRegistry.all) { def in
                        let eligibility = isEligible(def)
                        let isCompleted = quest.decapitationState.completedIDs.contains(def.id)
                        let isActive = quest.decapitationState.activeID == def.id
                        
                        DecapitationIconView(
                            def: def,
                            state: .init(
                                locked: !eligibility.allowed && !isCompleted,
                                completed: isCompleted,
                                active: isActive,
                                reason: eligibility.reason
                            ),
                            tap: {
                                // The tap action now calls the manager to update the state.
                                // If the icon is already active, tapping again deselects it.
                                let newTargetID = isActive ? nil : def.id
                                questManager.setDecapitationTarget(questId: quest.id, targetId: newTargetID)
                            }
                        )
                    }
                }.padding(.vertical, 4)
            }
        }.ccPanel()
    }

    /// Checks if a decapitation mission is available based on game rules.
    /// Rulebook p.27: "players must pick heroes that have reached the prerequisite level".
    private func isEligible(_ def: DecapitationDefinition) -> (allowed: Bool, reason: String?) {
        // First, check if the party's overall progress allows this level of mission.
        guard def.requiredPartyLevel <= quest.partyLevelCap else {
            return (false, "Party level cap is \(quest.partyLevelCap). Requires level \(def.requiredPartyLevel).")
        }
        
        // Then, check if there are any living heroes who actually meet the level requirement.
        let heroesAtRequiredLevel = quest.heroes.filter { $0.alive && $0.level >= def.requiredPartyLevel }
        if heroesAtRequiredLevel.isEmpty {
            return (false, "No living heroes have reached level \(def.requiredPartyLevel).")
        }
        
        return (true, nil)
    }
}
