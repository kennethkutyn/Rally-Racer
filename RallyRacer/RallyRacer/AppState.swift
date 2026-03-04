import SwiftUI
import SpriteKit
import Combine

enum Screen: Equatable {
    case menu
    case playing
    case dead
    case garage
    case leaderboard
}

@MainActor
class AppState: ObservableObject {
    @Published var currentScreen: Screen = .menu
    @Published var carConfig: CarConfig
    @Published var garage: [CarConfig]
    @Published var highScore: Int
    @Published var lastScore: Int = 0
    @Published var isNewRecord: Bool = false
    @Published var leaderboard: [LeaderboardEntry] = []
    @Published var leaderboardLoaded: Bool = false

    let storage = GarageStorage()
    let firebase = FirebaseService()
    let analytics = AnalyticsService.shared

    weak var gameScene: GameScene?

    init() {
        var loaded = storage.loadGarage()
        if loaded.isEmpty {
            loaded = [CarConfig.stockOrange]
            storage.saveGarage(loaded)
        }
        self.garage = loaded
        self.carConfig = storage.loadActiveCar()
        self.highScore = storage.loadHighScore()

        Task { await refreshLeaderboard() }
    }

    func navigateTo(_ screen: Screen) {
        currentScreen = screen
    }

    func startGame() {
        analytics.track("race_start", properties: ["car": carConfig.name])
        analytics.trackPageView("race")
        currentScreen = .playing
        gameScene?.startGame(carConfig: carConfig)
    }

    func endGame(score: Int) {
        let newRecord = score > highScore && score > 0
        if newRecord {
            highScore = score
            storage.saveHighScore(score)
        }
        lastScore = score
        isNewRecord = newRecord
        analytics.track("race_end", properties: [
            "score": score,
            "is_new_record": newRecord
        ])
        analytics.trackPageView("death_screen")

        Task { await refreshLeaderboard() }

        DispatchQueue.main.asyncAfter(deadline: .now() + GameConstants.deathDelaySeconds) { [weak self] in
            self?.currentScreen = .dead
        }
    }

    func isTopScore(_ score: Int) -> Bool {
        leaderboard.count < 10 || score > (leaderboard.last?.score ?? 0)
    }

    func submitScore(name: String, score: Int) {
        let trimmed = String(name.prefix(16))
        analytics.trackButtonClick("submit_score", page: "death_screen")
        analytics.track("score_submitted", properties: ["name": trimmed, "score": score])
        if trimmed != "Anonymous" {
            analytics.setUserId(trimmed)
        }

        let entry = LeaderboardEntry(name: trimmed, score: score, ts: Date().timeIntervalSince1970 * 1000)
        leaderboard.append(entry)
        leaderboard.sort { $0.score > $1.score }
        if leaderboard.count > 10 { leaderboard = Array(leaderboard.prefix(10)) }
        storage.saveCachedLeaderboard(leaderboard)

        firebase.submitScore(name: trimmed, score: score)
    }

    func refreshLeaderboard() async {
        let entries = await firebase.loadLeaderboard()
        if !entries.isEmpty {
            leaderboard = entries
            storage.saveCachedLeaderboard(entries)
        } else {
            leaderboard = storage.loadCachedLeaderboard()
        }
        leaderboardLoaded = true
    }

    func saveCarConfig() {
        storage.saveActiveCar(carConfig)
    }

    func saveGarageList() {
        storage.saveGarage(garage)
        storage.saveActiveCar(carConfig)
    }
}
