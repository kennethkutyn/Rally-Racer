import Foundation

struct CarConfig: Codable, Equatable, Identifiable {
    var id: UUID = UUID()
    var name: String
    var body: String
    var cabin: String
    var wheels: String
    var lights: String
    var flame: String

    static let stockOrange = CarConfig(
        name: "Orange Flash",
        body: "#ff8800",
        cabin: "#cc6600",
        wheels: "#222222",
        lights: "#ffee88",
        flame: "#ff6600"
    )
}
