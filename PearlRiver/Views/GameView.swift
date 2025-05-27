import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteKitGameView(size: geometry.size)
                    .environmentObject(appViewModel)
                    .ignoresSafeArea()
                
                if let gameViewModel = appViewModel.gameViewModel {
                    gameUIOverlay(gameViewModel: gameViewModel, geometry: geometry)
                }
            }
        }
    }
    
    // MARK: - Game UI Overlay
    @ViewBuilder
    private func gameUIOverlay(gameViewModel: GameViewModel, geometry: GeometryProxy) -> some View {
        VStack {
            // Top UI
            HStack {
                Button {
                    svm.play()
                    gameViewModel.pauseGame()
                } label: {
                    CircleButtonView(icon: "pause.fill", height: 55) {}
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: 8) {
                    ScoreboardView(
                        amount: gameViewModel.amuletsCollected,
                        width: 125,
                        height: 45,
                        isCoins: false
                    )
                    
                    ScoreboardView(
                        amount: gameViewModel.coinsCollected,
                        width: 125,
                        height: 45
                    )
                }
            }
            .padding()
            
            Spacer()
        }
        
        // Pause Overlay
        if gameViewModel.isPaused && !gameViewModel.showGameOverOverlay && !gameViewModel.showPuzzleGame {
            PauseView()
                .environmentObject(appViewModel)
                .transition(.opacity)
                .zIndex(150)
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
            .transition(.opacity)
            .zIndex(180)
        }
        
        // Puzzle Game Overlay
        if gameViewModel.showPuzzleGame {
            PuzzleGameView { success in
                gameViewModel.completePuzzleGame(success: success)
            }
            .transition(.scale.combined(with: .opacity))
            .zIndex(200)
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
        
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        if appViewModel.gameViewModel == nil {
            appViewModel.gameViewModel = GameViewModel()
            appViewModel.gameViewModel?.appViewModel = appViewModel
            appViewModel.gameViewModel?.currentLevel = appViewModel.gameLevel
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
