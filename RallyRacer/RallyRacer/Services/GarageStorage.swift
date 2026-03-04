import Foundation

class GarageStorage {
    private let garageKey = "rallyGarage"
    private let activeCarKey = "rallyActiveCar"
    private let highScoreKey = "rallyHighScore"
    private let leaderboardCacheKey = "rallyLeaderboard"

    func loadGarage() -> [CarConfig] {
        guard let data = UserDefaults.standard.data(forKey: garageKey) else { return [] }
        return (try? JSONDecoder().decode([CarConfig].self, from: data)) ?? []
    }

    func saveGarage(_ garage: [CarConfig]) {
        if let data = try? JSONEncoder().encode(garage) {
            UserDefaults.standard.set(data, forKey: garageKey)
        }
    }

    func loadActiveCar() -> CarConfig {
        guard let data = UserDefaults.standard.data(forKey: activeCarKey),
              let config = try? JSONDecoder().decode(CarConfig.self, from: data) else {
            return .stockOrange
        }
        return config
    }

    func saveActiveCar(_ config: CarConfig) {
        if let data = try? JSONEncoder().encode(config) {
            UserDefaults.standard.set(data, forKey: activeCarKey)
        }
    }

    func loadHighScore() -> Int {
        UserDefaults.standard.integer(forKey: highScoreKey)
    }

    func saveHighScore(_ score: Int) {
        UserDefaults.standard.set(score, forKey: highScoreKey)
    }

    func loadCachedLeaderboard() -> [LeaderboardEntry] {
        guard let data = UserDefaults.standard.data(forKey: leaderboardCacheKey) else { return [] }
        return (try? JSONDecoder().decode([LeaderboardEntry].self, from: data)) ?? []
    }

    func saveCachedLeaderboard(_ entries: [LeaderboardEntry]) {
        if let data = try? JSONEncoder().encode(entries) {
            UserDefaults.standard.set(data, forKey: leaderboardCacheKey)
        }
    }
}
