//
//  AppViewModel.swift
//  PearlRiver
//
//  Created by Alex on 24.05.2025.
//


import SwiftUI
import Combine

class AppViewModel: ObservableObject {
    @Published var currentScreen: AppScreen = .menu
    @Published var gameLevel: Int = 1
    @Published var coins: Int = 0
    @Published var amulets: Int = 0
    @Published var gameState: GameState
    
    @Published var gameViewModel: GameViewModel?
    @Published var achievementViewModel: AchievementViewModel?
    
    init() {
        self.gameState = GameState.load()
        self.coins = gameState.coins
        self.amulets = gameState.amulets
        self.gameLevel = gameState.currentLevel
        self.achievementViewModel = AchievementViewModel(appViewModel: self)
    }
    
    var currentBackground: String {
        return gameState.currentBackgroundId
    }
    
    var currentSkin: String {
        return gameState.currentSkinId
    }
    
    // MARK: - Navigation Methods
    func navigateTo(_ screen: AppScreen) {
        currentScreen = screen
    }
    
//    func goToMenu() {
//        gameViewModel = nil
//        navigateTo(.menu)
//    }
//    
//    func goToPalace() {
//        navigateTo(.myPalace)
//    }
//    
//    func goToLevelSelect() {
//        navigateTo(.levelSelect)
//    }
//    
//    func goToShop() {
//        navigateTo(.shop)
//    }
//    
//    func goToAchievements() {
//        navigateTo(.achievements)
//    }
//    
//    func goToSettings() {
//        navigateTo(.settings)
//    }
    
    // MARK: - Game Methods
    func startGame(level: Int? = nil) {
        let levelToStart = level ?? gameState.currentLevel
        gameLevel = levelToStart
        gameState.currentLevel = levelToStart
        
        gameViewModel = GameViewModel()
        gameViewModel?.appViewModel = self
        navigateTo(.game)
        saveGameState()
    }
    
    func pauseGame() {
        gameViewModel?.pauseGame()
    }
    
    func resumeGame() {
        gameViewModel?.resumeGame()
    }
    
    func restartLevel() {
        gameViewModel?.resetGame()
    }
    
    func goToNextLevel() {
        if gameLevel < GameConstants.maxLevels {
            gameLevel += 1
            gameState.currentLevel = gameLevel
            startGame(level: gameLevel)
        } else {
            navigateTo(.menu)
        }
    }
    
    // MARK: - Currency Methods (обновлено под амулеты)
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
            // Обновляем локальные значения валют
            coins = gameState.coins
            amulets = gameState.amulets
            saveGameState()
            
            // Проверяем достижения после улучшения
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
        // Обновляем локальные значения после возможного получения наград
        coins = gameState.coins
        amulets = gameState.amulets
    }
    
    func claimAchievement(_ achievementId: String) {
        achievementViewModel?.claimAchievement(achievementId)
        coins = gameState.coins // Обновляем после получения награды
    }
    
    // MARK: - Level Completion
    func completeLevel(coinsCollected: Int, amuletsCollected: Int, perfectRun: Bool) {
        // Добавляем собранные ресурсы
        gameState.addCoins(coinsCollected * GameConstants.coinValue)
        gameState.addAmulets(amuletsCollected)
        
        // Записываем завершение уровня
        gameState.completeLevel(gameLevel)
        
        // Записываем статистику
        if perfectRun {
            gameState.recordPerfectRun()
        }
        
        // Обновляем локальные значения
        coins = gameState.coins
        amulets = gameState.amulets
        
        saveGameState()
        checkAchievements()
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
        
        // Обновляем опубликованные свойства
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
        
        // Пересоздаем AchievementViewModel
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
}
