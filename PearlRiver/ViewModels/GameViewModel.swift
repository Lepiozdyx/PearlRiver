import SwiftUI
import Combine

class GameViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var isPaused: Bool = false
    @Published var showVictoryOverlay: Bool = false
    @Published var showDefeatOverlay: Bool = false
    @Published var coinsCollected: Int = 0
    @Published var amuletsCollected: Int = 0
    @Published var obstaclesHit: Int = 0
    @Published var timeRemaining: TimeInterval = GameConstants.gameDuration
    
    // MARK: - Properties
    let currentLevel: Int
    weak var appViewModel: AppViewModel?
    var gameScene: GameScene?
    
    // MARK: - Private Properties
    private var gameTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    private var isGameOver: Bool = false
    
    // Свойство для отслеживания идеального прохождения
    var isPerfectRun: Bool {
        return obstaclesHit == 0
    }
    
    // MARK: - Initialization
    init(level: Int, appViewModel: AppViewModel) {
        self.currentLevel = level
        self.appViewModel = appViewModel
        startGame()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Game Control
    func startGame() {
        isPaused = false
        isGameOver = false
        showVictoryOverlay = false
        showDefeatOverlay = false
        coinsCollected = 0
        amuletsCollected = 0
        obstaclesHit = 0
        timeRemaining = GameConstants.gameDuration
        
        startGameTimer()
    }
    
    func pauseGame() {
        isPaused = true
        gameTimer?.invalidate()
        gameScene?.pauseGame()
    }
    
    func resumeGame() {
        isPaused = false
        startGameTimer()
        gameScene?.resumeGame()
    }
    
    func restartLevel() {
        cleanup()
        startGame()
        gameScene?.resetGame()
    }
    
    // MARK: - Scene Setup
    func setupScene(size: CGSize) -> GameScene {
        let backgroundId = appViewModel?.gameState.currentBackgroundId ?? "medieval_castle"
        let skinId = appViewModel?.gameState.currentSkinId ?? "king_default"
        
        let scene = GameScene(
            size: size,
            level: currentLevel,
            backgroundId: backgroundId,
            skinId: skinId
        )
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    // MARK: - Timer
    private func startGameTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused, !self.isGameOver else { return }
            
            self.timeRemaining -= 0.1
            
            if self.timeRemaining <= 0 {
                self.gameOver(victory: true)
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    // MARK: - Game Events
    func collectCoin() {
        coinsCollected += 1
        appViewModel?.collectCoin()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func collectAmulet() {
        amuletsCollected += 1
        // Запускаем бонусную игру
        pauseGame()
        appViewModel?.startPuzzleBonus()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func hitObstacle() {
        obstaclesHit += 1
        appViewModel?.hitObstacle()
        
        // Проверяем, есть ли еще монеты
        if appViewModel?.gameState.coins ?? 0 <= 0 {
            gameOver(victory: false)
        }
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    // MARK: - Game Over
    private func gameOver(victory: Bool) {
        isGameOver = true
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            if victory {
                self.showVictoryOverlay = true
                let totalCoins = self.coinsCollected * GameConstants.coinValue
                let totalAmulets = self.amuletsCollected // Амулеты уже учтены через бонусную игру
                
                self.appViewModel?.completeLevel(
                    self.currentLevel,
                    coinsEarned: totalCoins,
                    amuletsEarned: totalAmulets,
                    perfectRun: self.isPerfectRun
                )
            } else {
                self.showDefeatOverlay = true
            }
            
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Navigation
    func goToMenu() {
        cleanup()
        appViewModel?.goToMenu()
    }
    
    func goToNextLevel() {
        cleanup()
        if currentLevel < GameConstants.maxLevels {
            appViewModel?.startGame(level: currentLevel + 1)
        } else {
            appViewModel?.goToMenu()
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        gameTimer?.invalidate()
        gameTimer = nil
        gameScene?.pauseGame()
    }
}

// MARK: - GameSceneDelegate
extension GameViewModel: GameSceneDelegate {
    func didCollectCoin() {
        collectCoin()
    }
    
    func didCollectAmulet() {
        collectAmulet()
    }
    
    func didHitObstacle() {
        hitObstacle()
    }
}
