import SwiftUI
import SpriteKit
import Combine

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
    private var cancellables = Set<AnyCancellable>()
    
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
        if paused && (showGameOverOverlay || showPuzzleGame) {
            return
        }
        
        isPaused = paused
        
        if paused {
            gameTimer?.invalidate()
            gameScene?.pauseGame()
        } else {
            startGameTimer()
            gameScene?.resumeGame()
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func pauseGame() {
        togglePause(true)
    }
    
    func resumeGame() {
        togglePause(false)
    }
    
    func resetGame() {
        self.showGameOverOverlay = false
        self.showPuzzleGame = false
        
        self.objectWillChange.send()
        
        gameTimer?.invalidate()
        gameScene?.pauseGame()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
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
            
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Puzzle Game Methods

    func startPuzzleGame() {
        guard !isPaused && !showGameOverOverlay else { return }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.pauseGame()
            self.showPuzzleGame = true
            self.objectWillChange.send()
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
            
            self.resumeGame()
            self.objectWillChange.send()
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
            
            self.objectWillChange.send()
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
        coinsCollected += 1
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didCollectAmulet() {
        appViewModel?.gameViewModel?.showPuzzleGame = true
        pauseGame()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didHitObstacle() {
        obstaclesHit += 1
        perfectRun = false
        
        // Вычитаем 1 монету из общей казны согласно ТЗ
        if let appViewModel = appViewModel {
            if appViewModel.gameState.coins > 0 {
                var gameState = appViewModel.gameState
                gameState.addCoins(-1)
                appViewModel.gameState = gameState
                appViewModel.saveGameState()
            }
        }
        
        appViewModel?.gameState.recordObstacleHit()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
