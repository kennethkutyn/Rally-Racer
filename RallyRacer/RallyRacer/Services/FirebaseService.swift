import Foundation

/// Live Firebase Realtime Database connection via REST API.
/// Uses the same database URL and endpoints as the web version.
class FirebaseService {
    private let baseURL = "https://rally-racer-d5dab-default-rtdb.asia-southeast1.firebasedatabase.app"

    func loadLeaderboard() async -> [LeaderboardEntry] {
        guard let url = URL(string: "\(baseURL)/leaderboard.json?orderBy=\"score\"&limitToLast=10") else { return [] }
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            guard let dict = try JSONSerialization.jsonObject(with: data) as? [String: [String: Any]] else {
                return []
            }
            var entries: [LeaderboardEntry] = []
            for (key, value) in dict {
                guard let name = value["name"] as? String,
                      let score = value["score"] as? Int,
                      let ts = value["ts"] as? Double else { continue }
                entries.append(LeaderboardEntry(id: key, name: name, score: score, ts: ts))
            }
            entries.sort { $0.score > $1.score }
            return Array(entries.prefix(10))
        } catch {
            print("[Firebase] Leaderboard fetch failed: \(error)")
            return []
        }
    }

    func submitScore(name: String, score: Int) {
        guard let url = URL(string: "\(baseURL)/leaderboard.json") else { return }
        let entry: [String: Any] = [
            "name": String(name.prefix(16)),
            "score": score,
            "ts": Date().timeIntervalSince1970 * 1000
        ]
        guard let body = try? JSONSerialization.data(withJSONObject: entry) else { return }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = body
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")

        URLSession.shared.dataTask(with: request) { _, _, error in
            if let error = error {
                print("[Firebase] Score upload failed: \(error)")
            } else {
                #if DEBUG
                print("[Firebase] Score submitted: \(name) = \(score)")
                #endif
            }
        }.resume()
    }
}

struct LeaderboardEntry: Codable, Identifiable, Equatable {
    var id: String?
    var name: String
    var score: Int
    var ts: Double

    enum CodingKeys: String, CodingKey {
        case name, score, ts
    }
}
