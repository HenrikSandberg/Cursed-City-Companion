//
//  InitiativeRow.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import SwiftUI


struct InitiativeRow: View {
    let entry: InitiativeEntry
    let isCurrent: Bool

    var body: some View {
        HStack {
            Circle()
                .fill(entry.isHero ? Color.trackerGreen : Color.red)
                .frame(width: 40, height: 40)
                .overlay(Text(entry.name.prefix(1)).foregroundColor(.white).bold())
            Text(entry.name).bold()
            Spacer()
            if isCurrent {
                Text("Current").font(.caption).foregroundColor(.secondary)
            }
        }
        .padding()
        .background(RoundedRectangle(cornerRadius: 8).fill(Color(.secondarySystemBackground)))
        .shadow(radius: isCurrent ? 4 : 0)
    }
}
