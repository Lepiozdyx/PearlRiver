import SwiftUI

struct GameUIOverlayView: View {
    
    @ObservedObject var gameViewModel: GameViewModel
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    CircleButtonView(icon: "pause.fill", height: 55) {
                        svm.play()
                        gameViewModel.pauseGame()
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
            
            if gameViewModel.isPaused && !gameViewModel.showGameOverOverlay && !gameViewModel.showPuzzleGame {
                PauseView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                    .zIndex(150)
            }
            
            if gameViewModel.showGameOverOverlay {
                GameOverView(
                    coinsEarned: gameViewModel.coinsCollected,
                    amuletsEarned: gameViewModel.amuletsCollected,
                    currentLevel: gameViewModel.currentLevel,
                    isLastLevel: gameViewModel.currentLevel >= GameConstants.maxLevels
                )
                .environmentObject(appViewModel)
                .transition(.opacity)
                .zIndex(180)
            }
            
            if gameViewModel.showPuzzleGame {
                PuzzleGameView { success in
                    gameViewModel.completePuzzleGame(success: success)
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(200)
            }
        }
    }
}
