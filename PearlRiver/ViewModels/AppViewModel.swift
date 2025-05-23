import SwiftUI
import Combine

// Экраны приложения
enum AppScreen: Equatable {
    case menu
    case levelSelect
    case game(level: Int)
    case palace
    case shop
    case achievements
    case settings
    case dailyReward
    case puzzleBonus
}

class AppViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentScreen: AppScreen = .menu
    @Published var gameState: GameState
    @Published var isLoading: Bool = false
    @Published var showDailyReward: Bool = false
    
    // MARK: - Child ViewModels
    @Published var gameViewModel: GameViewModel?
    @Published var palaceViewModel: PalaceViewModel?
    @Published var shopViewModel: ShopViewModel?
    @Published var achievementViewModel: AchievementViewModel?
    @Published var puzzleViewModel: PuzzleViewModel?
    
    // MARK: - Private Properties
    private var cancellables = Set<AnyCancellable>()
    private var palaceUpdateTimer: Timer?
    
    // MARK: - Initialization
    init() {
        self.gameState = GameState.load()
        setupDailyRewardCheck()
        setupPalaceIncomeTimer()
    }
    
    // MARK: - Navigation
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
        
        // Инициализация соответствующих ViewModel'ов при переходе
        switch screen {
        case .game(let level):
            gameViewModel = GameViewModel(level: level, appViewModel: self)
            
        case .palace:
            if palaceViewModel == nil {
                palaceViewModel = PalaceViewModel(appViewModel: self)
            }
            
        case .shop:
            if shopViewModel == nil {
                shopViewModel = ShopViewModel(appViewModel: self)
            }
            
        case .achievements:
            if achievementViewModel == nil {
                achievementViewModel = AchievementViewModel(appViewModel: self)
            }
            
        case .puzzleBonus:
            if puzzleViewModel == nil {
                puzzleViewModel = PuzzleViewModel(appViewModel: self)
            }
            
        default:
            break
        }
    }
    
    func goToMenu() {
        currentScreen = .menu
        gameViewModel = nil
    }
    
    // MARK: - Game Actions
    func startGame(level: Int) {
        navigateTo(.game(level: level))
    }
    
    func completeLevel(_ level: Int, coinsEarned: Int, amuletsEarned: Int, perfectRun: Bool = false) {
        gameState.completeLevel(level)
        gameState.addCoins(coinsEarned)
        gameState.addAmulets(amuletsEarned)
        
        // Проверка достижений
        checkAchievements()
        
        // Проверка достижения "Perfect Run"
        if perfectRun {
            unlockAchievement("perfect_run")
        }
        
        saveGameState()
    }
    
    func hitObstacle() {
        // Вычитаем монету при столкновении
        if gameState.coins > 0 {
            gameState.addCoins(-1)
        }
        gameState.totalObstaclesHit += 1
        saveGameState()
    }
    
    func collectCoin() {
        gameState.addCoins(GameConstants.coinValue)
        saveGameState()
    }
    
    func startPuzzleBonus() {
        navigateTo(.puzzleBonus)
    }
    
    func completePuzzle(success: Bool) {
        if success {
            gameState.addAmulets(GameConstants.puzzleReward)
            gameState.puzzlesCompleted += 1
            checkAchievements()
        }
        
        // Возвращаемся к игре
        if let gameVM = gameViewModel {
            navigateTo(.game(level: gameVM.currentLevel))
        }
        
        saveGameState()
    }
    
    // MARK: - Palace Actions
    func upgradePalaceBuilding(_ buildingId: String) -> Bool {
        guard let index = gameState.palaceBuildings.firstIndex(where: { $0.id == buildingId }),
              let goldCost = gameState.palaceBuildings[index].upgradeCostGold,
              let amuletCost = gameState.palaceBuildings[index].upgradeCostAmulets,
              gameState.coins >= goldCost,
              gameState.amulets >= amuletCost else {
            return false
        }
        
        gameState.addCoins(-goldCost)
        gameState.addAmulets(-amuletCost)
        gameState.palaceBuildings[index].level += 1
        
        checkAchievements()
        saveGameState()
        return true
    }
    
    // MARK: - Shop Actions
    func purchaseBackground(_ backgroundId: String) -> Bool {
        guard let background = BackgroundItem.availableBackgrounds.first(where: { $0.id == backgroundId }),
              gameState.coins >= background.price,
              !gameState.purchasedBackgrounds.contains(backgroundId) else {
            return false
        }
        
        gameState.addCoins(-background.price)
        gameState.purchasedBackgrounds.append(backgroundId)
        gameState.currentBackgroundId = backgroundId
        saveGameState()
        return true
    }
    
    func purchaseSkin(_ skinId: String) -> Bool {
        guard let skin = PlayerSkinItem.availableSkins.first(where: { $0.id == skinId }),
              gameState.coins >= skin.price,
              !gameState.purchasedSkins.contains(skinId) else {
            return false
        }
        
        gameState.addCoins(-skin.price)
        gameState.purchasedSkins.append(skinId)
        gameState.currentSkinId = skinId
        saveGameState()
        return true
    }
    
    func selectBackground(_ backgroundId: String) {
        guard gameState.purchasedBackgrounds.contains(backgroundId) else { return }
        gameState.currentBackgroundId = backgroundId
        saveGameState()
    }
    
    func selectSkin(_ skinId: String) {
        guard gameState.purchasedSkins.contains(skinId) else { return }
        gameState.currentSkinId = skinId
        saveGameState()
    }
    
    // MARK: - Achievement Actions
    func claimAchievement(_ achievementId: String) {
        // Immutable value 'achievement' was never used; consider replacing with '_' or removing it !
        guard let achievement = Achievement.byId(achievementId),
              gameState.completedAchievements.contains(achievementId),
              !gameState.claimedAchievements.contains(achievementId) else {
            return
        }
        
        gameState.claimedAchievements.append(achievementId)
        gameState.addCoins(GameConstants.achievementReward)
        saveGameState()
    }
    
    private func unlockAchievement(_ achievementId: String) {
        guard !gameState.completedAchievements.contains(achievementId) else { return }
        gameState.completedAchievements.append(achievementId)
        saveGameState()
    }
    
    // MARK: - Daily Reward
    func claimDailyReward() {
        gameState.claimDailyReward()
        showDailyReward = false
        saveGameState()
    }
    
    // MARK: - Private Methods
    private func setupDailyRewardCheck() {
        // Проверяем при запуске
        if gameState.canClaimDailyReward {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) { [weak self] in
                self?.showDailyReward = true
            }
        }
    }
    
    private func setupPalaceIncomeTimer() {
        // Обновляем доход дворца каждые 5 минут
        palaceUpdateTimer = Timer.scheduledTimer(withTimeInterval: 300, repeats: true) { [weak self] _ in
            self?.gameState.updatePalaceIncome()
            self?.saveGameState()
        }
    }
    
    private func checkAchievements() {
        for achievement in Achievement.allAchievements {
            if !gameState.completedAchievements.contains(achievement.id) &&
               achievement.requirement.isSatisfied(by: gameState) {
                unlockAchievement(achievement.id)
            }
        }
    }
    
    private func saveGameState() {
        gameState.save()
        objectWillChange.send()
    }
    
    // MARK: - Reset
    func resetProgress() {
        GameState.reset()
        gameState = GameState()
        saveGameState()
    }
    
    deinit {
        palaceUpdateTimer?.invalidate()
    }
}
