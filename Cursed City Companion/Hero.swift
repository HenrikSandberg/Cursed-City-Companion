//
//  Hero.swift
//  Cursed City Companion
//
//  Created by Henrik Anthony Odden Sandberg on 27/07/2025.
//

import Foundation

struct Hero: Identifiable, Codable, Hashable {
    let id: UUID
    var name: String
    var isAlive: Bool = true
    var hearoType: String?
    
    var level: Int = 1
    var isNovice: Bool = false
    
    var portetName: String
    var modelImage: String?
    var description: String?

    // En liste over alle tilgjengelige helter i spillet.
    static func allHeroes() -> [Hero] {
        return [
            Hero(id: UUID(), name: "Emelda Braskov", portetName: "portrait-emelda-braskov"),
            Hero(id: UUID(), name: "Jelsen Darrock", portetName: "portrait-jelsen-darrock"),
            Hero(id: UUID(), name: "Dagnai Holdenstock", portetName: "portrait-dagnai-holdenstock"),
            Hero(id: UUID(), name: "Qulathis the Exile", portetName: "portait-qulathis-the-exile"),
            Hero(id: UUID(), name: "Glaurio ven Alten III", portetName: "portrait-glaurio-ven-alten"),
            Hero(id: UUID(), name: "Octren Glimscry", portetName: "portait-octren-glimscry"),
            Hero(id: UUID(), name: "Cleona Zeitengale", portetName: "portait-cleona-zeitengale"),
            Hero(id: UUID(), name: "Brutogg Corpse-Eater", portetName: "portait-brutogg-corpse-eater")
        ]
    }
}
