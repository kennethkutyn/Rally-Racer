import SwiftUI

struct DeathScreenView: View {
    @EnvironmentObject var appState: AppState
    @State private var playerName: String = ""
    @State private var hasSubmitted: Bool = false
    @FocusState private var nameFieldFocused: Bool

    private var isTopScore: Bool {
        appState.isTopScore(appState.lastScore)
    }

    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            // Red-tinted overlay
            RadialGradient(
                colors: [
                    Color(hex: "#640a0a").opacity(0.88),
                    Color(hex: "#0a0514").opacity(0.95)
                ],
                center: .center,
                startRadius: 0,
                endRadius: 600
            )
            .ignoresSafeArea()

            if isWide {
                iPadLayout
            } else {
                iPhoneLayout
            }
        }
    }

    // MARK: - iPad layout (vertical, generous spacing)
    private var iPadLayout: some View {
        ScrollView {
            VStack(spacing: 0) {
                Spacer(minLength: 20)
                titleSection
                scoreSection
                namePrompt
                leaderboardSection
                actionButtonsRow
                    .padding(.top, 20)
                Spacer(minLength: 20)
            }
            .padding(.horizontal, 30)
        }
    }

    // MARK: - iPhone layout (side by side: leaderboard left, buttons right)
    private var iPhoneLayout: some View {
        VStack(spacing: 4) {
            // Top: title + score (compact)
            titleSection
            scoreSection

            // Name prompt if applicable
            namePrompt

            // Bottom: leaderboard left, buttons right
            if hasSubmitted || !isTopScore || appState.lastScore == 0 {
                HStack(alignment: .top, spacing: 12) {
                    // Left: scrollable leaderboard
                    VStack(spacing: 4) {
                        Text("LEADERBOARD")
                            .font(.custom("RussoOne-Regular", size: 13))
                            .foregroundColor(Color(hex: "#ffcc00"))

                        ScrollView {
                            LeaderboardTable(entries: appState.leaderboard, highlightScore: appState.lastScore)
                        }
                    }

                    // Right: action buttons stacked vertically
                    VStack(spacing: 10) {
                        Spacer()
                        compactButton(title: "RACE\nAGAIN", gradient: [Color(hex: "#ffcc00"), Color(hex: "#ff8800")], textColor: Color(hex: "#111111")) {
                            appState.analytics.trackButtonClick("race_again", page: "death_screen")
                            appState.startGame()
                        }
                        compactButton(title: "GARAGE", gradient: [Color(hex: "#4488ff"), Color(hex: "#2255cc")], textColor: .white) {
                            appState.analytics.trackButtonClick("garage", page: "death_screen")
                            appState.navigateTo(.garage)
                        }
                        Spacer()
                    }
                    .frame(width: 100)
                }
                .padding(.top, 4)
            } else {
                // Before submit: just show buttons
                actionButtonsRow
                    .padding(.top, 10)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Shared sections

    private var titleSection: some View {
        VStack(spacing: 0) {
            Text("Wrecked!")
                .font(.custom("BungeeShade-Regular", size: isWide ? 64 : 30))
                .foregroundColor(Color(hex: "#ff4444"))
                .shadow(color: .black, radius: 0, x: 3, y: 3)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            divider
        }
    }

    private var scoreSection: some View {
        VStack(spacing: 2) {
            Text("Score: \(formattedScore)")
                .font(.custom("RussoOne-Regular", size: isWide ? 28 : 18))
                .foregroundColor(.white)

            if appState.isNewRecord {
                Text("NEW RECORD!")
                    .font(.custom("RussoOne-Regular", size: isWide ? 22 : 15))
                    .foregroundColor(Color(hex: "#ffcc00"))
                    .shadow(color: Color(hex: "#ff6600"), radius: 10)
            } else {
                Text("Best: \(formattedHighScore)")
                    .font(.custom("RussoOne-Regular", size: isWide ? 18 : 13))
                    .foregroundColor(Color.white.opacity(0.7))
            }
        }
    }

    @ViewBuilder
    private var namePrompt: some View {
        if isTopScore && !hasSubmitted && appState.lastScore > 0 {
            VStack(spacing: 6) {
                Text("Top 10! Enter your name:")
                    .font(.custom("RussoOne-Regular", size: isWide ? 16 : 13))
                    .foregroundColor(Color(hex: "#ffcc00"))

                HStack(spacing: 8) {
                    TextField("Your name", text: $playerName)
                        .textFieldStyle(.plain)
                        .font(.custom("RussoOne-Regular", size: isWide ? 16 : 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.white.opacity(0.25), lineWidth: 1)
                        )
                        .frame(maxWidth: 200)
                        .focused($nameFieldFocused)
                        .onSubmit { submitScore() }
                        .autocorrectionDisabled()
                        .textInputAutocapitalization(.words)

                    Button(action: submitScore) {
                        Text("SUBMIT")
                            .font(.custom("RussoOne-Regular", size: 13))
                            .foregroundColor(Color(hex: "#111111"))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(
                                LinearGradient(colors: [Color(hex: "#ffcc00"), Color(hex: "#ff8800")], startPoint: .top, endPoint: .bottom)
                            )
                            .cornerRadius(8)
                    }
                }
            }
            .padding(.top, 6)
            .onAppear { nameFieldFocused = true }
        }
    }

    @ViewBuilder
    private var leaderboardSection: some View {
        if hasSubmitted || !isTopScore || appState.lastScore == 0 {
            VStack(spacing: 6) {
                Text("LEADERBOARD")
                    .font(.custom("RussoOne-Regular", size: isWide ? 18 : 14))
                    .foregroundColor(Color(hex: "#ffcc00"))
                    .padding(.top, 10)

                LeaderboardTable(entries: appState.leaderboard, highlightScore: appState.lastScore)
            }
        }
    }

    private var actionButtonsRow: some View {
        HStack(spacing: 16) {
            MenuButton(title: "RACE AGAIN", gradient: [Color(hex: "#ffcc00"), Color(hex: "#ff8800")], textColor: Color(hex: "#111111")) {
                appState.analytics.trackButtonClick("race_again", page: "death_screen")
                appState.startGame()
            }

            MenuButton(title: "GARAGE", gradient: [Color(hex: "#4488ff"), Color(hex: "#2255cc")], textColor: .white) {
                appState.analytics.trackButtonClick("garage", page: "death_screen")
                appState.navigateTo(.garage)
            }
        }
    }

    private func compactButton(title: String, gradient: [Color], textColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            Text(title)
                .font(.custom("RussoOne-Regular", size: 13))
                .foregroundColor(textColor)
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, minHeight: 44)
                .padding(.vertical, 6)
                .background(
                    LinearGradient(colors: gradient, startPoint: .top, endPoint: .bottom)
                )
                .overlay(ShineView())
                .cornerRadius(10)
        }
    }

    private var divider: some View {
        RoundedRectangle(cornerRadius: 2)
            .fill(
                LinearGradient(
                    colors: [.clear, Color(hex: "#ff6600"), Color(hex: "#ffcc00"), Color(hex: "#ff6600"), .clear],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .frame(width: 200, height: 3)
            .padding(.vertical, isWide ? 16 : 6)
    }

    private func submitScore() {
        let name = playerName.trimmingCharacters(in: .whitespacesAndNewlines)
        let finalName = name.isEmpty ? "Anonymous" : name
        appState.submitScore(name: finalName, score: appState.lastScore)
        hasSubmitted = true
        nameFieldFocused = false
    }

    private var formattedScore: String {
        NumberFormatter.localizedString(from: NSNumber(value: appState.lastScore), number: .decimal)
    }

    private var formattedHighScore: String {
        NumberFormatter.localizedString(from: NSNumber(value: appState.highScore), number: .decimal)
    }
}
