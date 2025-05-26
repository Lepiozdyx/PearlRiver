import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var amulets: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var achievementViewModel: AchievementViewModel?
    
    // MARK: - Properties for Puzzle Game
    @Published var showPuzzleGame: Bool = false
    private var puzzleCompletionHandler: ((Bool) -> Void)?
    
    // MARK: - Initialization
    init() {
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.amulets = gameState.amulets
        self.gameLevel = gameState.currentLevel
        self.achievementViewModel = AchievementViewModel(appViewModel: self)
    }
    
    // MARK: - Computed Properties
    var currentBackground: String {
        return gameState.currentBackgroundId
    }
    
    var currentSkin: String {
        return gameState.currentSkinId
    }
    
    // MARK: - Navigation Methods
    func navigateTo(_ screen: AppScreen) {
        // Cleanup game view model if leaving game screen
        if currentScreen == .game && screen != .game {
            gameViewModel?.cleanup()
        }
        
        currentScreen = screen
    }
    
    func goToMenu() {
        gameViewModel = nil
        navigateTo(.menu)
    }
    
    // MARK: - Game Methods
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        
        // Validate level is unlocked
        guard isLevelUnlocked(levelToStart) else { return }
        
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        
        // Create new game view model
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        gameViewModel?.currentLevel = levelToStart
        
        navigateTo(.game)
        saveGameState()
        
        // Start the game after navigation
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.gameViewModel?.startGame()
        }
    }
    
    func pauseGame() {
        gameViewModel?.pauseGame()
    }
    
    func resumeGame() {
        gameViewModel?.resumeGame()
    }
    
    func restartLevel() {
        gameViewModel?.resetGame()
        
        // Restart the game after reset
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
            self?.gameViewModel?.startGame()
        }
    }
    
    func goToNextLevel() {
        if gameLevel < GameConstants.maxLevels {
            gameLevel += 1
            gameState.currentLevel = gameLevel
            saveGameState()
            
            // Reset game view model and start new level
            gameViewModel?.resetGame()
            gameViewModel?.currentLevel = gameLevel
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) { [weak self] in
                self?.gameViewModel?.startGame()
            }
        } else {
            // All levels completed, return to menu
            goToMenu()
        }
    }
    
    // MARK: - Puzzle Game Methods
    func showPuzzleGameOverlay(completion: @escaping (Bool) -> Void) {
        puzzleCompletionHandler = completion
        showPuzzleGame = true
    }
    
    func completePuzzleGame(success: Bool) {
        showPuzzleGame = false
        
        if success {
            // Add amulets reward
            addAmulets(GameConstants.puzzleReward)
            gameState.recordPuzzleCompleted()
            saveGameState()
        }
        
        // Call completion handler
        puzzleCompletionHandler?(success)
        puzzleCompletionHandler = nil
    }
    
    // MARK: - Level Completion
    func completeLevel(coinsCollected: Int, amuletsCollected: Int, perfectRun: Bool) {
        // Add collected resources (coins already multiplied by 5 in GameViewModel)
        gameState.addCoins(coinsCollected)
        gameState.addAmulets(amuletsCollected)
        
        // Record level completion
        gameState.completeLevel(gameLevel)
        
        // Record statistics
        if perfectRun {
            gameState.recordPerfectRun()
        }
        
        // Update local values
        coins = gameState.coins
        amulets = gameState.amulets
        
        saveGameState()
        checkAchievements()
    }
    
    // MARK: - Currency Methods
    func addCoins(_ amount: Int) {
        gameState.addCoins(amount)
        coins = gameState.coins
        saveGameState()
    }
    
    func addAmulets(_ amount: Int) {
        gameState.addAmulets(amount)
        amulets = gameState.amulets
        saveGameState()
    }
    
    func spendCoins(_ amount: Int) -> Bool {
        if gameState.spendCoins(amount) {
            coins = gameState.coins
            saveGameState()
            return true
        }
        return false
    }
    
    func spendAmulets(_ amount: Int) -> Bool {
        if gameState.spendAmulets(amount) {
            amulets = gameState.amulets
            saveGameState()
            return true
        }
        return false
    }
    
    // MARK: - Palace Methods
    func upgradePalaceBuilding(_ buildingId: String) -> Bool {
        if gameState.upgradePalaceBuilding(buildingId: buildingId) {
            coins = gameState.coins
            amulets = gameState.amulets
            saveGameState()
            checkAchievements()
            return true
        }
        return false
    }
    
    // MARK: - Daily Reward
    func claimDailyReward() {
        gameState.claimDailyReward()
        coins = gameState.coins
        saveGameState()
    }
    
    var canClaimDailyReward: Bool {
        return gameState.canClaimDailyReward
    }
    
    // MARK: - Achievements Methods
    func checkAchievements() {
        achievementViewModel?.checkAndCompleteAchievements()
        coins = gameState.coins
        amulets = gameState.amulets
    }
    
    func claimAchievement(_ achievementId: String) {
        achievementViewModel?.claimAchievement(achievementId)
        coins = gameState.coins
    }
    
    // MARK: - Shop Integration
    func purchaseItem(type: String, id: String, price: Int) -> Bool {
        guard gameState.coins >= price else { return false }
        
        var success = false
        
        switch type {
        case "background":
            success = gameState.purchaseBackground(id, price: price)
        case "skin":
            success = gameState.purchaseSkin(id, price: price)
        default:
            return false
        }
        
        if success {
            coins = gameState.coins
            saveGameState()
        }
        
        return success
    }
    
    func selectItem(type: String, id: String) {
        switch type {
        case "background":
            gameState.selectBackground(id)
        case "skin":
            gameState.selectSkin(id)
        default:
            return
        }
        
        saveGameState()
    }
    
    // MARK: - Game State Management
    func saveGameState() {
        gameState.save()
        
        DispatchQueue.main.async { [weak self] in
            self?.objectWillChange.send()
        }
    }
    
    func resetGameState() {
        GameState.reset()
        gameState = GameState()
        coins = 0
        amulets = 0
        gameLevel = 1
        
        achievementViewModel = AchievementViewModel(appViewModel: self)
        
        saveGameState()
    }
    
    // MARK: - Level Management
    func isLevelUnlocked(_ level: Int) -> Bool {
        return level <= gameState.maxUnlockedLevel
    }
    
    func isLevelCompleted(_ level: Int) -> Bool {
        return gameState.levelsCompleted.contains(level)
    }
    
    // MARK: - Passive Income Update
    func updatePalaceIncome() {
        gameState.updatePalaceIncome()
        coins = gameState.coins
        amulets = gameState.amulets
        saveGameState()
    }
}
