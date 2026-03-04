import SwiftUI

struct LeaderboardView: View {
    @EnvironmentObject var appState: AppState

    private var isWide: Bool {
        UIDevice.current.userInterfaceIdiom == .pad
    }

    var body: some View {
        ZStack {
            RadialGradient(
                colors: [
                    Color(hex: "#501444").opacity(0.85),
                    Color(hex: "#0a0514").opacity(0.95)
                ],
                center: UnitPoint(x: 0.6, y: 0.4),
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
        .onAppear {
            appState.analytics.trackPageView("leaderboard")
            Task { await appState.refreshLeaderboard() }
        }
    }

    // MARK: - iPad layout (vertical, generous spacing)
    private var iPadLayout: some View {
        VStack(spacing: 0) {
            Spacer()

            titleSection

            if appState.leaderboard.isEmpty && !appState.leaderboardLoaded {
                ProgressView()
                    .tint(.white)
                    .padding()
            } else {
                LeaderboardTable(entries: appState.leaderboard, highlightScore: nil)
            }

            backButton(fontSize: 18, hPad: 36, vPad: 12)
                .padding(.top, 20)

            Spacer()
        }
        .padding(.horizontal, 30)
    }

    // MARK: - iPhone layout (back button on the left, leaderboard on the right)
    private var iPhoneLayout: some View {
        HStack(alignment: .center, spacing: 20) {
            // Left: back button
            backButton(fontSize: 15, hPad: 24, vPad: 12)
                .padding(.leading, 4)

            // Right: title + leaderboard
            VStack(spacing: 4) {
                Text("Leaderboard")
                    .font(.custom("BungeeShade-Regular", size: 22))
                    .foregroundColor(Color(hex: "#ff4444"))
                    .shadow(color: .black, radius: 0, x: 2, y: 2)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)

                divider

                if appState.leaderboard.isEmpty && !appState.leaderboardLoaded {
                    ProgressView()
                        .tint(.white)
                        .padding()
                } else {
                    ScrollView {
                        LeaderboardTable(entries: appState.leaderboard, highlightScore: nil)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
    }

    // MARK: - Shared components

    private var titleSection: some View {
        VStack(spacing: 0) {
            Text("Global Leaderboard")
                .font(.custom("BungeeShade-Regular", size: isWide ? 48 : 30))
                .foregroundColor(Color(hex: "#ff4444"))
                .shadow(color: .black, radius: 0, x: 3, y: 3)
                .lineLimit(1)
                .minimumScaleFactor(0.5)

            divider
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

    private func backButton(fontSize: CGFloat, hPad: CGFloat, vPad: CGFloat) -> some View {
        Button {
            appState.analytics.trackButtonClick("back", page: "leaderboard")
            appState.navigateTo(.menu)
        } label: {
            Text("BACK")
                .font(.custom("RussoOne-Regular", size: fontSize))
                .foregroundColor(.white)
                .padding(.horizontal, hPad)
                .padding(.vertical, vPad)
                .background(
                    LinearGradient(colors: [Color(hex: "#666666"), Color(hex: "#444444")], startPoint: .top, endPoint: .bottom)
                )
                .clipShape(Capsule())
        }
    }
}

struct LeaderboardTable: View {
    let entries: [LeaderboardEntry]
    let highlightScore: Int?

    var body: some View {
        VStack(spacing: 4) {
            ForEach(Array(entries.prefix(10).enumerated()), id: \.offset) { index, entry in
                HStack {
                    Text("\(index + 1).")
                        .font(.custom("RussoOne-Regular", size: 16))
                        .foregroundColor(rankColor(index))
                        .frame(width: 36, alignment: .trailing)

                    Text(entry.name)
                        .font(.custom("RussoOne-Regular", size: 16))
                        .foregroundColor(rowColor(index, entry: entry))
                        .lineLimit(1)

                    Spacer()

                    Text(NumberFormatter.localizedString(from: NSNumber(value: entry.score), number: .decimal))
                        .font(.custom("RussoOne-Regular", size: 16))
                        .foregroundColor(rowColor(index, entry: entry))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 6)
                .background(Color.white.opacity(index % 2 == 0 ? 0.05 : 0))
                .cornerRadius(4)
            }
        }
        .frame(maxWidth: 500)
    }

    private func rankColor(_ index: Int) -> Color {
        switch index {
        case 0: return Color(hex: "#ffcc00") // gold
        case 1: return Color(hex: "#cccccc") // silver
        default: return Color.white.opacity(0.6)
        }
    }

    private func rowColor(_ index: Int, entry: LeaderboardEntry) -> Color {
        if let hs = highlightScore, entry.score == hs {
            return Color(hex: "#ffcc00")
        }
        return index == 0 ? Color(hex: "#ffcc00") : .white
    }
}
