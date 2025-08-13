import Foundation

/// Handles encoding and decoding the quest data to a JSON file.
final class PersistenceManager {
    
    private let fileURL: URL

    init() {
        do {
            let directory = try FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            self.fileURL = directory.appendingPathComponent("cursed_city_quests.json")
        } catch {
            fatalError("Unable to get document directory: \(error)")
        }
    }

    /// Loads all quests from the JSON file.
    /// - Returns: An array of `Quest` objects. Returns an empty array if the file doesn't exist or fails to decode.
    func loadQuests() -> [Quest] {
        guard let data = try? Data(contentsOf: fileURL) else {
            return []
        }
        
        do {
            let quests = try JSONDecoder().decode([Quest].self, from: data)
            return quests
        } catch {
            print("Error decoding quests: \(error)")
            // Consider handling data corruption, e.g., by backing up the file and returning an empty array.
            return []
        }
    }

    /// Saves the entire list of quests to the JSON file.
    /// - Parameter quests: The array of `Quest` objects to save.
    func saveQuests(_ quests: [Quest]) {
        do {
            let data = try JSONEncoder().encode(quests)
            try data.write(to: fileURL, options: [.atomic, .completeFileProtection])
        } catch {
            print("Error saving quests: \(error)")
        }
    }
}
