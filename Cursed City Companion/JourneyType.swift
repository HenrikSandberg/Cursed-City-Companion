//
//  JourneyType.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//


struct JourneyType: Codable, Hashable {
    static func == (lhs: JourneyType, rhs: JourneyType) -> Bool {
        return lhs.name == rhs.name
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(name)
    }
    
    var name: String
    var successOutcome: JourneyOutcome
    var failureOutcome: JourneyOutcome
    var isDecapitation: Bool = false // For å spore Decapitation-oppdrag

    // Eksempler på reisetyper
    static let hunt = JourneyType(
        name: "Hunt",
        successOutcome: .init(description: "The beast is slain. The city breathes a sigh of relief.", fearChange: -1, influenceChange: 2),
        failureOutcome: .init(description: "The prey escapes, growing stronger.", fearChange: 1, influenceChange: -1)
    )
    static let scavenge = JourneyType(
        name: "Scavenge",
        successOutcome: .init(description: "Valuable resources recovered.", fearChange: 0, influenceChange: 1),
        failureOutcome: .init(description: "The search was fruitless.", fearChange: 0, influenceChange: -1)
    )
    static let decapitation = JourneyType(
        name: "Decapitation",
        successOutcome: .init(description: "A vampire lord is vanquished!", fearChange: -2, influenceChange: 3),
        failureOutcome: .init(description: "The target escaped, and now they know you are coming.", fearChange: 2, influenceChange: -2),
        isDecapitation: true
    )
}
