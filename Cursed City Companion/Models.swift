import Foundation
import SwiftUI

// MARK: - Core Data Models

struct Quest: Codable, Identifiable, Equatable {
    static func == (lhs: Quest, rhs: Quest) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.influence == rhs.influence &&
        lhs.fear == rhs.fear &&
        lhs.heroes == rhs.heroes &&
        lhs.completedJourneys == rhs.completedJourneys &&
        lhs.activeJourney == rhs.activeJourney &&
        lhs.realmstone == rhs.realmstone &&
        lhs.lastExtractionEvent == rhs.lastExtractionEvent
    }
    
    var id = UUID()
    var name: String
    var influence: Int = 5
    var fear: Int = 5
    var decapitationProgress: DecapitationProgress = DecapitationProgress()
    var heroes: [Hero] = Hero.defaultHeroes
    var completedJourneys: [Journey] = []
    var activeJourney: Journey?
    var realmstone: Int = 0
    var lastExtractionEvent: ExtractionEvent?
}

struct DecapitationProgress: Codable, Equatable {
    var fellGuardian: Bool = false
    var captainOfTheDamned: Bool = false
    var shufflingHorrors: Bool = false
    var whispersInTheDark: Bool = false
    var familyTies: Bool = false
    var finalAssault: Bool = false
}

struct Hero: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var level: Int = 0
    var experience: Int = 0 // 0 = none, 1 = novice, 2 = level up
    var isAlive: Bool = true
    var isOutOfAction: Bool = false
    var items: [Item] = []
    var treasureCards: [String] = [] // Storing treasure card names
    var description: String
    var imageName: String
    
    static var defaultHeroes: [Hero] {
        [
            Hero(name: "Emelda Braskov", description: "A determined warrior of a fallen noble house.", imageName: "portrait-emelda-braskov"),
            Hero(name: "Jelsen Darrock", description: "A grim and relentless vampire hunter.", imageName: "portrait-jelsen-darrock"),
            Hero(name: "Dagnai Holdenstock", description: "A shrewd Kharadron Overlord with an eye for profit.", imageName: "portrait-dagnai-holdenstock"),
            Hero(name: "Glaurio ven Alten III", description: "The last scion of a disgraced noble family, seeking to restore his honor.", imageName: "portrait-glaurio-ven-alten"),
            Hero(name: "Qulathis the Exile", description: "A Kurnothi hunter on a quest for vengeance.", imageName: "portrait-qulathis-the-exile"),
            Hero(name: "Cleona Zeitengale", description: "A devout priestess of the Cult of the Comet.", imageName: "portrait-cleona-zeitengale"),
            Hero(name: "Octren Glimscry", description: "A mysterious scholar of the Pact Mortalis.", imageName: "portrait-octren-glimscry"),
            Hero(name: "Brutogg Corpse-eater", description: "An ogor mercenary with an insatiable appetite.", imageName: "portrait-brutogg-corpse-eater")
        ]
    }
}

struct Item: Codable, Identifiable, Equatable {
    var id = UUID()
    var name: String
    var description: String
}

struct Journey: Codable, Identifiable, Equatable {
    var id = UUID()
    var journeyType: JourneyType
    var level: Int
    var mapName: String?
    var turn: Int = 1
    var wasSuccessful: Bool = false
    var extractionEvent: ExtractionEvent?
    var heroesTakenOutOfAction: [UUID] = [] // New property
    var survivalDetermined: Bool = false
    var consequencesResolved: Bool = false
    var participatingHeroes: [UUID]
    var enemyGroups: Int
    var initiativeOrder: [InitiativeParticipant] = []
}

enum HuntMap: String, Codable, CaseIterable, Identifiable {
    case alleyways = "Alleyways"
    case barracks = "Barracks"
    case barrowLane = "Barrow Lane"
    case punishmentRow = "Punishment Row"
    case squareOfBones = "Square of Bones"
    case theBloodways = "The Bloodways"
    case theForsakenCrypts = "The Forsaken Crypts"
    case theHuntingGrounds = "The Hunting Grounds"
    var id: String { self.rawValue }
}

enum ScavengeMap: String, Codable, CaseIterable, Identifiable {
    case abandonedMarketplace = "Abandoned Marketplace"
    case wraithsEnd = "Wraith's End"
    case gravelightBoulevard = "Gravelight Boulevard"
    case venAltenEstate = "Ven Alten Estate"
    case abattoirAlley = "Abattoir Alley"
    case derelictMansion = "Derelict Mansion"
    case gheistlightSquare = "Gheistlight Square"
    case theBlackStreets = "The Black Streets"
    var id: String { self.rawValue }
}

enum JourneyType: String, Codable, CaseIterable, Equatable {
    case hunt = "Hunt"
    case scavenge = "Scavenge"
    case deliverance = "Deliverance"
    case decapitation = "Decapitation"
}

struct InitiativeParticipant: Codable, Identifiable, Hashable {
    var id = UUID()
    var name: String
    var isHero: Bool
    var heroID: UUID?
}

enum ExtractionEvent: String, Codable, CaseIterable, Identifiable {
    case adamantDamaged = "Adamant Damaged"
    case itemsLost = "Items Lost"
    case wolfOnTheHunt = "Wolf on the Hunt"
    case badlyHurt = "Badly Hurt"
    case carrionFlux = "Carrion Flux"
    case cleanEscape = "Clean Escape"
    case spareResources = "Spare Resources"
    case apothecary = "Apothecary's Aid"
    case opportunisticSalvo = "Opportunistic Salvo"
    case moraleBoost = "Morale Boost"
    case gratefulCitizen = "Grateful Citizen"
    case opportunisticMerchant = "Opportunistic Merchant"

    var id: String { self.rawValue }

    var description: String {
        switch self {
        case .adamantDamaged: return "The next journey will start at night."
        case .itemsLost: return "Each hero must discard all treasure cards."
        case .wolfOnTheHunt: return "Radukar will hunt the heroes in the next journey."
        case .badlyHurt: return "Each hero starts the next journey with 1 damage."
        case .carrionFlux: return "Each hero starts the next journey diseased."
        case .cleanEscape: return "No effect. A clean escape... for now!"
        case .spareResources: return "The cost of the first empowerment is reduced by 1."
        case .apothecary: return "Reroll survival checks and gain a Potion of Coagulated Vitality."
        case .opportunisticSalvo: return "Shrink influence by 1 (to a minimum of 5)."
        case .moraleBoost: return "Shrink fear by 1 (to a minimum of 5)."
        case .gratefulCitizen: return "Each hero starts the next journey with 1 inspiration point."
        case .opportunisticMerchant: return "Each hero may discard treasure cards to gain realmstone."
        }
    }
}


// MARK: - Color Palette
extension Color {
    static let cursedGold = Color(red: 0.8, green: 0.6, blue: 0.2)
    static let vampireViolet = Color(red: 0.4, green: 0.2, blue: 0.5)
    static let parchment = Color(red: 0.96, green: 0.94, blue: 0.88)
    static let darkstone = Color(red: 0.1, green: 0.1, blue: 0.15)
    static let bloodRed = Color(red: 0.6, green: 0.1, blue: 0.1)
}
