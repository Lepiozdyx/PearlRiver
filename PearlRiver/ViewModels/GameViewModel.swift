import SwiftUI
import SpriteKit

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var coinsCollected: Int = 0
    @Published var amuletsCollected: Int = 0
    @Published var timeRemaining: Double = GameConstants.gameDuration
    @Published var isPaused: Bool = false
    @Published var showGameOverOverlay: Bool = false
    @Published var showPuzzleGame: Bool = false
    
    // MARK: - Achievement Tracking Properties
    @Published var obstaclesHit: Int = 0
    @Published var perfectRun: Bool = true
    
    // MARK: - Private Properties
    private var gameScene: GameScene?
    private var gameTimer: Timer?
    
    // MARK: - Public Properties
    weak var appViewModel: AppViewModel?
    var currentLevel: Int = 1
    
    // MARK: - Initialization
    init() {
        setupTimers()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    func setupScene(size: CGSize) -> GameScene {
        let skinId = appViewModel?.gameState.currentSkinId ?? "king_default"
        let backgroundId = appViewModel?.gameState.currentBackgroundId ?? "medieval_castle"
        
        let scene = GameScene(size: size, level: currentLevel, backgroundId: backgroundId, skinId: skinId)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    func togglePause(_ paused: Bool) {
        // ИСПРАВЛЕНИЕ: Немедленное обновление на главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Не паузим если показаны оверлеи
            if paused && (self.showGameOverOverlay || self.showPuzzleGame) {
                return
            }
            
            self.isPaused = paused
            
            if paused {
                self.gameTimer?.invalidate()
                self.gameScene?.pauseGame()
            } else {
                self.startGameTimer()
                self.gameScene?.resumeGame()
            }
            
            print("GameViewModel: Game paused = \(self.isPaused)")
        }
    }
    
    func pauseGame() {
        print("GameViewModel: pauseGame() called")
        togglePause(true)
    }
    
    func resumeGame() {
        print("GameViewModel: resumeGame() called")
        togglePause(false)
    }
    
    func resetGame() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.showGameOverOverlay = false
            self.showPuzzleGame = false
            
            self.gameTimer?.invalidate()
            self.gameScene?.pauseGame()
            
            self.coinsCollected = 0
            self.amuletsCollected = 0
            self.timeRemaining = GameConstants.gameDuration
            self.isPaused = false
            
            self.obstaclesHit = 0
            self.perfectRun = true
            
            self.showGameOverOverlay = false
            self.showPuzzleGame = false
            
            self.setupTimers()
            self.gameScene?.resetGame()
            
            print("GameViewModel: Game reset completed")
        }
    }
    
    // MARK: - Puzzle Game Methods

    func startPuzzleGame() {
        guard !isPaused && !showGameOverOverlay else {
            print("GameViewModel: Cannot start puzzle - game is paused or game over")
            return
        }
        
        print("GameViewModel: Starting puzzle game")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // ИСПРАВЛЕНИЕ: Сначала паузим игру, потом показываем пазл
            self.togglePause(true)
            self.showPuzzleGame = true
            
            print("GameViewModel: Puzzle game started, isPaused: \(self.isPaused), showPuzzleGame: \(self.showPuzzleGame)")
        }
    }

    func completePuzzleGame(success: Bool) {
        print("GameViewModel: Completing puzzle game with success: \(success)")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.showPuzzleGame = false
            
            if success {
                self.amuletsCollected += GameConstants.puzzleReward
                self.appViewModel?.gameState.recordPuzzleCompleted()
                print("GameViewModel: Added \(GameConstants.puzzleReward) amulets, total: \(self.amuletsCollected)")
            }
            
            // ИСПРАВЛЕНИЕ: Автоматически возобновляем игру после завершения пазла
            self.togglePause(false)
            
            print("GameViewModel: Puzzle completed, resuming game. isPaused: \(self.isPaused)")
        }
    }
    
    // MARK: - Private Methods
    
    private func setupTimers() {
        gameTimer?.invalidate()
        startGameTimer()
    }
    
    private func startGameTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            self.timeRemaining -= 0.1
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            if self.timeRemaining <= 0 {
                self.gameOver(win: true)
            }
        }
    }
    
    private func gameOver(win: Bool) {
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if win {
                self.showGameOverOverlay = true
                self.appViewModel?.completeLevel(
                    coinsCollected: self.coinsCollected,
                    amuletsCollected: self.amuletsCollected,
                    perfectRun: self.perfectRun
                )
            }
        }
    }
    
    func cleanup() {
        gameTimer?.invalidate()
        gameScene?.pauseGame()
        isPaused = true
    }
}

// MARK: - GameSceneDelegate
extension GameViewModel: GameSceneDelegate {
    func didCollectCoin() {
        print("GameViewModel: didCollectCoin called")
        
        // ИСПРАВЛЕНИЕ: Немедленное обновление на главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.coinsCollected += 1
            print("GameViewModel: Coins collected updated to: \(self.coinsCollected)")
        }
    }
    
    func didCollectAmulet() {
        print("GameViewModel: didCollectAmulet called")
        
        // ИСПРАВЛЕНИЕ: Немедленный запуск пазла на главном потоке
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.startPuzzleGame()
        }
    }
    
    func didHitObstacle() {
        print("GameViewModel: didHitObstacle called")
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.obstaclesHit += 1
            self.perfectRun = false
            
            // Вычитаем 1 монету из общей казны согласно ТЗ
            if let appViewModel = self.appViewModel {
                if appViewModel.gameState.coins > 0 {
                    var gameState = appViewModel.gameState
                    gameState.addCoins(-1)
                    appViewModel.gameState = gameState
                    appViewModel.saveGameState()
                }
            }
            
            self.appViewModel?.gameState.recordObstacleHit()
            
            print("GameViewModel: Obstacle hit processed, obstacles hit: \(self.obstaclesHit)")
        }
    }
}
