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
                
                // ИСПРАВЛЕНИЕ: Используем @ObservedObject для gameViewModel
                if let gameViewModel = appViewModel.gameViewModel {
                    GameUIOverlayView(gameViewModel: gameViewModel, geometry: geometry)
                        .environmentObject(appViewModel)
                }
            }
        }
    }
}

// MARK: - Отдельный View для UI оверлея с правильным наблюдением
struct GameUIOverlayView: View {
    @ObservedObject var gameViewModel: GameViewModel
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    let geometry: GeometryProxy
    
    var body: some View {
        ZStack {
            // Top UI
            VStack {
                HStack {
                    CircleButtonView(icon: "pause.fill", height: 55) {
                        svm.play()
                        print("GameView: Pause button tapped")
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
            
            // ИСПРАВЛЕНИЕ: Оверлеи в отдельном ZStack с правильным наблюдением
            if gameViewModel.isPaused && !gameViewModel.showGameOverOverlay && !gameViewModel.showPuzzleGame {
                PauseView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                    .zIndex(150)
                    .onAppear {
                        print("GameView: PauseView appeared!")
                    }
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
                    print("GameView: Puzzle completed with success: \(success)")
                    gameViewModel.completePuzzleGame(success: success)
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(200)
            }
        }
        .onChange(of: gameViewModel.isPaused) { isPaused in
            print("GameView: isPaused changed to: \(isPaused)")
        }
        .onChange(of: gameViewModel.showPuzzleGame) { showPuzzle in
            print("GameView: showPuzzleGame changed to: \(showPuzzle)")
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
        // ИСПРАВЛЕНИЕ: Добавлена проверка что gameViewModel существует перед созданием сцены
        if appViewModel.gameViewModel == nil {
            print("SpriteKitGameView: Creating new GameViewModel")
            appViewModel.gameViewModel = GameViewModel()
            appViewModel.gameViewModel?.appViewModel = appViewModel
            appViewModel.gameViewModel?.currentLevel = appViewModel.gameLevel
        }
        
        if view.scene == nil, let gameViewModel = appViewModel.gameViewModel {
            print("SpriteKitGameView: Creating new scene")
            let scene = gameViewModel.setupScene(size: size)
            view.presentScene(scene)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
