import Foundation

// A simplified manager for loading and saving the entire quest list.
class PersistenceManager {
    static let shared = PersistenceManager()
    private let questsKey = "CursedCityQuests"

    private init() {}

    // Fetches the array of quests from UserDefaults.
    func getQuests() -> [Quest] {
        guard let data = UserDefaults.standard.data(forKey: questsKey) else { return [] }
        do {
            let quests = try JSONDecoder().decode([Quest].self, from: data)
            return quests
        } catch {
            print("Error decoding quests: \(error)")
            return []
        }
    }

    // Saves the entire array of quests to UserDefaults.
    func saveQuests(_ quests: [Quest]) {
        do {
            let data = try JSONEncoder().encode(quests)
            UserDefaults.standard.set(data, forKey: questsKey)
        } catch {
            print("Error encoding quests: \(error)")
        }
    }
}
