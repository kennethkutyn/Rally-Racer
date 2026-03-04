import SwiftUI

struct MainMenuView: View {
    @EnvironmentObject var appState: AppState
    @State private var titleScale: CGFloat = 1.0

    var body: some View {
        ZStack {
            // Radial gradient background
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

            VStack(spacing: 0) {
                Spacer()

                // Title
                Text("Rally Racer")
                    .font(.custom("BungeeShade-Regular", size: titleFontSize))
                    .foregroundColor(Color(hex: "#ff4444"))
                    .shadow(color: .black, radius: 0, x: 4, y: 4)
                    .shadow(color: Color(hex: "#ff3c14").opacity(0.5), radius: 40)
                    .lineLimit(1)
                    .minimumScaleFactor(0.5)
                    .scaleEffect(titleScale)
                    .onAppear {
                        withAnimation(.easeInOut(duration: 2).repeatForever(autoreverses: true)) {
                            titleScale = 1.03
                        }
                    }

                // Subtitle
                Text("SIDE-SCROLL CHAMPIONSHIP")
                    .font(.custom("RussoOne-Regular", size: subtitleFontSize))
                    .foregroundColor(Color(hex: "#ffcc00"))
                    .shadow(color: .black, radius: 0, x: 2, y: 2)
                    .tracking(4)
                    .padding(.top, 8)

                // Divider
                RoundedRectangle(cornerRadius: 2)
                    .fill(
                        LinearGradient(
                            colors: [.clear, Color(hex: "#ff6600"), Color(hex: "#ffcc00"), Color(hex: "#ff6600"), .clear],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .frame(width: 200, height: 3)
                    .padding(.vertical, 24)

                // Controls hint
                /*HStack(spacing: 24) {
                    ControlHint(keys: "Joystick", label: "Steer")
                    ControlHint(keys: "Right", label: "Gas")
                    ControlHint(keys: "Left", label: "Brake")
                    ControlHint(keys: "Button", label: "Boost")
                }
                .padding(.bottom, 20)*/

                // Buttons
                HStack(spacing: 16) {
                    MenuButton(title: "PLAY NOW", gradient: [Color(hex: "#ffcc00"), Color(hex: "#ff8800")], textColor: Color(hex: "#111111")) {
                        appState.analytics.trackButtonClick("play_now", page: "menu")
                        appState.startGame()
                    }

                    MenuButton(title: "GARAGE", gradient: [Color(hex: "#4488ff"), Color(hex: "#2255cc")], textColor: .white) {
                        appState.analytics.trackButtonClick("garage", page: "menu")
                        appState.analytics.trackPageView("garage")
                        appState.navigateTo(.garage)
                    }

                    MenuButton(title: "LEADERBOARD", gradient: [Color(hex: "#cc44ff"), Color(hex: "#8822cc")], textColor: .white) {
                        appState.analytics.trackButtonClick("leaderboard", page: "menu")
                        appState.navigateTo(.leaderboard)
                    }
                }

                Spacer()
            }
            .padding(.horizontal, 40)
        }
        .onAppear {
            appState.analytics.trackPageView("menu")
        }
    }

    private var titleFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 80 : 48
    }

    private var subtitleFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 28 : 16
    }
}

struct ControlHint: View {
    let keys: String
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            Text(keys)
                .font(.custom("RussoOne-Regular", size: 12))
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .cornerRadius(6)
                .foregroundColor(.white)

            Text(label.uppercased())
                .font(.system(size: 10))
                .foregroundColor(Color(hex: "#aaaaaa"))
                .tracking(1)
        }
    }
}

struct MenuButton: View {
    let title: String
    let gradient: [Color]
    let textColor: Color
    let action: () -> Void

    @State private var shineOffset: CGFloat = 0

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.custom("RussoOne-Regular", size: buttonFontSize))
                .foregroundColor(textColor)
                .tracking(3)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(
                    LinearGradient(colors: gradient, startPoint: .top, endPoint: .bottom)
                )
                .overlay(
                    GeometryReader { geo in
                        let w = geo.size.width
                        Rectangle()
                            .fill(
                                LinearGradient(
                                    colors: [.clear, Color.white.opacity(0.25), .clear],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: w * 0.4, height: geo.size.height * 3)
                            .rotationEffect(.degrees(-20))
                            .offset(x: w * (shineOffset * 1.8 - 0.6))
                    }
                    .clipped()
                )
                .clipShape(Capsule())
                .shadow(color: gradient.first?.opacity(0.4) ?? .clear, radius: 15, y: 4)
        }
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                shineOffset = 1
            }
        }
    }

    private var buttonFontSize: CGFloat {
        UIDevice.current.userInterfaceIdiom == .pad ? 22 : 16
    }
}

// MARK: - Reusable shine overlay for non-capsule buttons
struct ShineView: View {
    @State private var offset: CGFloat = 0

    var body: some View {
        GeometryReader { geo in
            let w = geo.size.width
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.clear, Color.white.opacity(0.25), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(width: w * 0.4, height: geo.size.height * 3)
                .rotationEffect(.degrees(-20))
                .offset(x: w * (offset * 1.8 - 0.6))
        }
        .clipped()
        .allowsHitTesting(false)
        .onAppear {
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                offset = 1
            }
        }
    }
}
