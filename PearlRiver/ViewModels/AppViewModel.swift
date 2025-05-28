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
    func startMiniGame(_ gameType: MiniGameType) {
        switch gameType {
        case .guessNumber:
            navigateTo(.guess)
        case .memoryCards:
            navigateTo(.memory)
        case .sequence:
            navigateTo(.sequence)
        case .maze:
            navigateTo(.maze)
        }
    }
    
    func navigateTo(_ screen: AppScreen) {
        if currentScreen == .game && screen != .game {
            gameViewModel?.cleanup()
        }
        
        currentScreen = screen
    }
    
    func goToMenu() {
        if let gameViewModel = gameViewModel {
            gameViewModel.cleanup()
        }
        gameViewModel = nil
        
        navigateTo(.menu)
    }
    
    // MARK: - Game Methods (адаптированы по образцу Oneida)
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        
        guard isLevelUnlocked(levelToStart) else {
            return
        }
        
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        gameViewModel?.currentLevel = levelToStart
        
        navigateTo(.game)
        saveGameState()
    }
    
    func pauseGame() {
        DispatchQueue.main.async {
            self.gameViewModel?.togglePause(true)
            self.objectWillChange.send()
        }
    }
    
    func resumeGame() {
        DispatchQueue.main.async {
            self.gameViewModel?.togglePause(false)
            self.objectWillChange.send()
        }
    }
    
    func restartLevel() {
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            self.gameViewModel?.resetGame()
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                self.objectWillChange.send()
                
                if let gameVM = self.gameViewModel {
                    gameVM.objectWillChange.send()
                }
            }
        }
    }
    
    func goToNextLevel() {
        guard let currentGameViewModel = gameViewModel else {
            return
        }
        
        let nextLevel = gameLevel + 1
        
        if nextLevel <= GameConstants.maxLevels {
            currentGameViewModel.cleanup()
            
            gameLevel = nextLevel
            gameState.currentLevel = nextLevel
            saveGameState()
            
            gameViewModel = GameViewModel()
            gameViewModel?.appViewModel = self
            gameViewModel?.currentLevel = nextLevel
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                self?.objectWillChange.send()
            }
            
        } else {
            goToMenu()
        }
    }
    
    // MARK: - Level Completion
    func completeLevel(coinsCollected: Int, amuletsCollected: Int, perfectRun: Bool) {
        print("AppViewModel: Level \(gameLevel) completed")
        print("  - Coins collected: \(coinsCollected)")
        print("  - Amulets collected: \(amuletsCollected)")
        print("  - Perfect run: \(perfectRun)")
        
        gameState.addCoins(coinsCollected)
        gameState.addAmulets(amuletsCollected)
        
        gameState.completeLevel(gameLevel)
        
        if perfectRun {
            gameState.recordPerfectRun()
        }
        
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
