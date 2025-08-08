//
//  InitiativeDropDelegate.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 08/08/2025.
//

import SwiftUI

struct InitiativeDropDelegate: DropDelegate {
    let item: InitiativeEntry
    @Binding var current: InitiativeEntry?
    let reorder: (InitiativeEntry, InitiativeEntry) -> Void

    func performDrop(info: DropInfo) -> Bool {
        self.current = nil
        return true
    }

    func dropEntered(info: DropInfo) {
        guard let current = current, current != item else { return }
        reorder(current, item)
    }
}
