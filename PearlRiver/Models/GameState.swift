import Foundation

struct GameState: Codable {
    // MARK: - Валюта
    var coins: Int = 0
    var amulets: Int = 0
    
    // MARK: - Прогресс
    var currentLevel: Int = 1
    var maxUnlockedLevel: Int = 1
    var levelsCompleted: [Int] = []
    
    // MARK: - Дворец
    var palaceBuildings: [PalaceBuilding] = PalaceBuilding.defaultBuildings()
    var lastPalaceUpdate: Date = Date()
    
    // MARK: - Магазин
    var purchasedBackgrounds: [String] = ["medieval_castle"] // Дефолтный фон
    var purchasedSkins: [String] = ["king_default"] // Дефолтный скин
    
    var currentBackgroundId: String = "medieval_castle"
    var currentSkinId: String = "king_default"
    
    // MARK: - Достижения
    var completedAchievements: [String] = []
    var claimedAchievements: [String] = []
    
    // MARK: - Статистика
    var totalCoinsCollected: Int = 0
    var totalAmuletsCollected: Int = 0
    var totalObstaclesHit: Int = 0
    var puzzlesCompleted: Int = 0
    var perfectRuns: Int = 0 // Уровни без попаданий в препятствия
    
    // MARK: - Ежедневная награда
    var lastDailyRewardDate: Date?
    
    // MARK: - Вычисляемые свойства
    var canClaimDailyReward: Bool {
        guard let lastDate = lastDailyRewardDate else { return true }
        return !Calendar.current.isDateInToday(lastDate)
    }
    
    var nextAvailableLevel: Int {
        return min(maxUnlockedLevel + 1, GameConstants.maxLevels)
    }
    
    // MARK: - Методы для валюты
    mutating func addCoins(_ amount: Int) {
        coins += amount
        if amount > 0 {
            totalCoinsCollected += amount
        }
    }
    
    mutating func addAmulets(_ amount: Int) {
        amulets += amount
        if amount > 0 {
            totalAmuletsCollected += amount
        }
    }
    
    mutating func spendCoins(_ amount: Int) -> Bool {
        guard coins >= amount else { return false }
        coins -= amount
        return true
    }
    
    mutating func spendAmulets(_ amount: Int) -> Bool {
        guard amulets >= amount else { return false }
        amulets -= amount
        return true
    }
    
    // MARK: - Методы для прогресса
    mutating func completeLevel(_ level: Int) {
        if !levelsCompleted.contains(level) {
            levelsCompleted.append(level)
        }
        if level >= maxUnlockedLevel && level < GameConstants.maxLevels {
            maxUnlockedLevel = level + 1
        }
    }
    
    mutating func recordPerfectRun() {
        perfectRuns += 1
    }
    
    mutating func recordObstacleHit() {
        totalObstaclesHit += 1
    }
    
    mutating func recordPuzzleCompleted() {
        puzzlesCompleted += 1
    }
    
    // MARK: - Методы для дворца
    mutating func updatePalaceIncome() {
        let now = Date()
        let daysSinceLastUpdate = Calendar.current.dateComponents([.day], from: lastPalaceUpdate, to: now).day ?? 0
        
        if daysSinceLastUpdate >= 1 {
            // Начисляем доход за каждый день
            for _ in 0..<daysSinceLastUpdate {
                for building in palaceBuildings {
                    addCoins(building.goldPerDay)
                    addAmulets(building.amuletsPerDay)
                }
            }
            lastPalaceUpdate = now
        }
    }
    
    mutating func upgradePalaceBuilding(buildingId: String) -> Bool {
        guard let index = palaceBuildings.firstIndex(where: { $0.id == buildingId }) else {
            return false
        }
        
        let building = palaceBuildings[index]
        guard building.canUpgrade else { return false }
        
        // Проверяем достаточно ли ресурсов
        guard coins >= building.upgradeCostGold && amulets >= building.upgradeCostAmulets else {
            return false
        }
        
        // Списываем ресурсы
        coins -= building.upgradeCostGold
        amulets -= building.upgradeCostAmulets
        
        // Улучшаем здание
        palaceBuildings[index].upgrade()
        
        return true
    }
    
    // MARK: - Ежедневная награда
    mutating func claimDailyReward() {
        guard canClaimDailyReward else { return }
        addCoins(GameConstants.dailyReward)
        lastDailyRewardDate = Date()
    }
    
    // MARK: - Магазин
    mutating func purchaseBackground(_ backgroundId: String, price: Int) -> Bool {
        guard spendCoins(price) else { return false }
        
        if !purchasedBackgrounds.contains(backgroundId) {
            purchasedBackgrounds.append(backgroundId)
        }
        
        return true
    }
    
    mutating func purchaseSkin(_ skinId: String, price: Int) -> Bool {
        guard spendCoins(price) else { return false }
        
        if !purchasedSkins.contains(skinId) {
            purchasedSkins.append(skinId)
        }
        
        return true
    }
    
    mutating func selectBackground(_ backgroundId: String) {
        if purchasedBackgrounds.contains(backgroundId) {
            currentBackgroundId = backgroundId
        }
    }
    
    mutating func selectSkin(_ skinId: String) {
        if purchasedSkins.contains(skinId) {
            currentSkinId = skinId
        }
    }
    
    // MARK: - Достижения
    mutating func completeAchievement(_ achievementId: String) {
        if !completedAchievements.contains(achievementId) {
            completedAchievements.append(achievementId)
        }
    }
    
    mutating func claimAchievement(_ achievementId: String) {
        if completedAchievements.contains(achievementId) && !claimedAchievements.contains(achievementId) {
            claimedAchievements.append(achievementId)
            addCoins(GameConstants.achievementReward)
        }
    }
    
    // MARK: - Persistence
    private static let gameStateKey = "pearlRiverGameState"
    
    static func load() -> GameState {
        guard let data = UserDefaults.standard.data(forKey: gameStateKey) else {
            return GameState()
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            var gameState = try decoder.decode(GameState.self, from: data)
            // Обновляем доход дворца при загрузке
            gameState.updatePalaceIncome()
            return gameState
        } catch {
            print("Failed to decode game state: \(error)")
            return GameState()
        }
    }
    
    func save() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let encoded = try encoder.encode(self)
            UserDefaults.standard.set(encoded, forKey: GameState.gameStateKey)
            UserDefaults.standard.synchronize()
        } catch {
            print("Failed to encode game state: \(error)")
        }
    }
    
    static func reset() {
        UserDefaults.standard.removeObject(forKey: gameStateKey)
        UserDefaults.standard.synchronize()
    }
}
