import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // SpriteKit Scene
                SpriteKitGameView(size: geometry.size)
                    .environmentObject(appViewModel)
                    .ignoresSafeArea()
                
                // Game UI Overlay
                if let gameViewModel = appViewModel.gameViewModel {
                    VStack {
                        // Top bar with pause button and scores
                        HStack(alignment: .top) {
                            // Pause button
                            CircleButtonView(icon: "pause.fill", height: 55) {
                                svm.play()
                                appViewModel.pauseGame()
                            }
                            
                            Spacer()
                            
                            // Scores
                            VStack(alignment: .trailing, spacing: 8) {
                                // Amulets collected
                                ScoreboardView(
                                    amount: gameViewModel.amuletsCollected,
                                    width: 125,
                                    height: 45,
                                    isCoins: false
                                )
                                
                                // Coins collected
                                ScoreboardView(
                                    amount: gameViewModel.coinsCollected,
                                    width: 125,
                                    height: 45
                                )
                            }
                            .opacity(0.7)
                        }
                        .padding()
                        
                        Spacer()
                    }
                    
                    // Pause Overlay
                    if gameViewModel.isPaused && !gameViewModel.showGameOverOverlay {
                        PauseView()
                            .environmentObject(appViewModel)
                            .transition(.opacity)
                            .animation(.easeInOut(duration: 0.3), value: gameViewModel.isPaused)
                            .zIndex(90)
                    }
                    
                    // Game Over Overlay
                    if gameViewModel.showGameOverOverlay {
                        GameOverView(
                            coinsEarned: gameViewModel.coinsCollected * GameConstants.coinValue,
                            amuletsEarned: gameViewModel.amuletsCollected,
                            currentLevel: gameViewModel.currentLevel,
                            isLastLevel: gameViewModel.currentLevel >= GameConstants.maxLevels
                        )
                        .environmentObject(appViewModel)
                        .transition(.scale.combined(with: .opacity))
                        .animation(.easeInOut(duration: 0.5), value: gameViewModel.showGameOverOverlay)
                        .zIndex(100)
                    }
                }
            }
        }
        .onDisappear {
            // Pause game when leaving the view
            if let gameVM = appViewModel.gameViewModel {
                gameVM.pauseGame()
            }
        }
    }
}

// MARK: - SpriteKitGameView

struct SpriteKitGameView: UIViewRepresentable {
    @EnvironmentObject private var appViewModel: AppViewModel
    let size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = false
        view.showsNodeCount = false
        view.ignoresSiblingOrder = true
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        if appViewModel.gameViewModel == nil {
            appViewModel.gameViewModel = GameViewModel()
            appViewModel.gameViewModel?.appViewModel = appViewModel
        }
        
        if view.scene == nil {
            let scene = appViewModel.gameViewModel?.setupScene(size: size)
            view.presentScene(scene)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
