import SwiftUI
import SpriteKit

struct ContentView: View {
    @StateObject private var appState = AppState()
    @State private var gameScene: GameScene?

    var body: some View {
        ZStack {
            // Game scene (always rendered underneath)
            GameContainerView(appState: appState, gameScene: $gameScene)
                .ignoresSafeArea()

            // Overlay screens
            switch appState.currentScreen {
            case .menu:
                MainMenuView()
                    .environmentObject(appState)
                    .transition(.opacity)

            case .playing:
                // No overlay — game is visible
                EmptyView()

            case .dead:
                DeathScreenView()
                    .environmentObject(appState)
                    .transition(.opacity)

            case .garage:
                GarageView()
                    .environmentObject(appState)
                    .transition(.opacity)

            case .leaderboard:
                LeaderboardView()
                    .environmentObject(appState)
                    .transition(.opacity)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.currentScreen)
        .preferredColorScheme(.dark)
        .statusBarHidden()
    }
}

struct GameContainerView: UIViewRepresentable {
    let appState: AppState
    @Binding var gameScene: GameScene?

    func makeUIView(context: Context) -> SKView {
        let skView = SKView()
        skView.ignoresSiblingOrder = true
        #if DEBUG
        skView.showsFPS = true
        skView.showsNodeCount = true
        #endif

        let scene = GameScene(size: UIScreen.main.bounds.size)
        scene.scaleMode = .resizeFill
        scene.appState = appState

        DispatchQueue.main.async {
            appState.gameScene = scene
            gameScene = scene
        }

        skView.presentScene(scene)
        return skView
    }

    func updateUIView(_ uiView: SKView, context: Context) {
        // Scene persists — no re-creation needed
    }
}
