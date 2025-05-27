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
    
    func togglePause(_ paused: Bool, forPuzzle: Bool = false) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Не паузим если показаны оверлеи, КРОМЕ случая когда паузим для пазла
            if paused && !forPuzzle && (self.showGameOverOverlay || self.showPuzzleGame) {
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
        }
    }
    
    func pauseGame() {
        togglePause(true)
    }
    
    func resumeGame() {
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
        }
    }
    
    // MARK: - Puzzle Game Methods

    func startPuzzleGame() {
        guard !isPaused && !showGameOverOverlay else {
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            // Юзаем forPuzzle: true чтобы принудительно паузить
            self.togglePause(true, forPuzzle: true)
            self.showPuzzleGame = true
        }
    }

    func completePuzzleGame(success: Bool) {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.showPuzzleGame = false
            
            if success {
                self.amuletsCollected += GameConstants.puzzleReward
                self.appViewModel?.gameState.recordPuzzleCompleted()
            }
            
            self.togglePause(false)
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
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.coinsCollected += GameConstants.coinValue
        }
    }
    
    func didCollectAmulet() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.startPuzzleGame()
        }
    }
    
    func didHitObstacle() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.obstaclesHit += 1
            self.perfectRun = false
            
            if self.coinsCollected > 0 {
                self.coinsCollected -= 1
            }
            
            self.appViewModel?.gameState.recordObstacleHit()
        }
    }
}
