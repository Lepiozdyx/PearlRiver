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
        setupGameTimer()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Public Methods
    
    func setupScene(size: CGSize) -> GameScene {
        if let appVM = appViewModel {
            currentLevel = appVM.gameLevel
        }
        
        let backgroundId = appViewModel?.gameState.currentBackgroundId ?? "medieval_castle"
        let skinId = appViewModel?.gameState.currentSkinId ?? "king_default"
        
        let scene = GameScene(size: size, level: currentLevel, backgroundId: backgroundId, skinId: skinId)
        scene.scaleMode = .aspectFill
        scene.gameDelegate = self
        gameScene = scene
        return scene
    }
    
    func startGame() {
        resetGameState()
        setupGameTimer()
        gameScene?.startGame()
    }
    
    func togglePause(_ paused: Bool) {
        if paused && showGameOverOverlay {
            return
        }
        
        isPaused = paused
        
        if paused {
            gameTimer?.invalidate()
            gameScene?.pauseGame()
        } else {
            setupGameTimer()
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
        cleanup()
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.resetGameState()
            self.gameScene?.resetGame()
            self.objectWillChange.send()
        }
    }
    
    // MARK: - Puzzle Game Methods
    
    func startPuzzleGame() {
        pauseGame()
        showPuzzleGame = true
    }
    
    func completePuzzleGame(success: Bool) {
        showPuzzleGame = false
        
        if success {
            amuletsCollected += GameConstants.puzzleReward
            appViewModel?.gameState.recordPuzzleCompleted()
        }
        
        resumeGame()
    }
    
    // MARK: - Private Methods
    
    private func resetGameState() {
        coinsCollected = 0
        amuletsCollected = 0
        timeRemaining = GameConstants.gameDuration
        obstaclesHit = 0
        perfectRun = true
        isPaused = false
        showGameOverOverlay = false
        showPuzzleGame = false
    }
    
    private func setupGameTimer() {
        gameTimer?.invalidate()
        
        gameTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self, !self.isPaused else { return }
            
            self.timeRemaining -= 0.1
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            if self.timeRemaining <= 0 {
                self.gameOver()
            }
        }
    }
    
    private func gameOver() {
        cleanup()
        
        // Обновляем статистику в AppViewModel
        if let appViewModel = appViewModel {
            // Добавляем собранные ресурсы
            appViewModel.gameState.addCoins(coinsCollected * GameConstants.coinValue)
            appViewModel.gameState.addAmulets(amuletsCollected)
            
            // Записываем завершение уровня
            appViewModel.gameState.completeLevel(currentLevel)
            
            // Записываем достижения
            if perfectRun {
                appViewModel.gameState.recordPerfectRun()
            }
            
            // Сохраняем состояние
            appViewModel.saveGameState()
            
            // Проверяем достижения
            checkAchievements()
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.showGameOverOverlay = true
            self.objectWillChange.send()
        }
    }
    
    private func checkAchievements() {
        guard let appViewModel = appViewModel else { return }
        let gameState = appViewModel.gameState
        
        // Проверяем каждое достижение
        for achievement in Achievement.allAchievements {
            if !gameState.completedAchievements.contains(achievement.id) {
                if achievement.requirement.isSatisfied(by: gameState) {
                    var updatedGameState = gameState
                    updatedGameState.completeAchievement(achievement.id)
                    appViewModel.gameState = updatedGameState
                }
            }
        }
    }
    
    private func cleanup() {
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
        // Запускаем бонусную игру-пазл
        startPuzzleGame()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func didHitObstacle() {
        obstaclesHit += 1
        perfectRun = false
        
        // Вычитаем 1 монету из общей казны (не из собранных в этом раунде)
        if let appViewModel = appViewModel {
            if appViewModel.gameState.coins > 0 {
                var gameState = appViewModel.gameState
                gameState.addCoins(-1)
                appViewModel.gameState = gameState
                appViewModel.saveGameState()
            }
        }
        
        // Записываем статистику
        appViewModel?.gameState.recordObstacleHit()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
}
