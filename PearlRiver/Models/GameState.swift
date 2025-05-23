import Foundation

struct GameState: Codable {
    // MARK: - Валюта
    var coins: Int = 0
    var amulets: Int = 0
    
    // MARK: - Прогресс
    var currentLevel: Int = 1
    var maxUnlockedLevel: Int = 1
    var levelsCompleted: [Int] = [] // Массив завершенных уровней
    
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
    
    // MARK: - Методы
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
    
    mutating func completeLevel(_ level: Int) {
        if !levelsCompleted.contains(level) {
            levelsCompleted.append(level)
        }
        if level >= maxUnlockedLevel && level < GameConstants.maxLevels {
            maxUnlockedLevel = level + 1
        }
    }
    
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
    
    mutating func claimDailyReward() {
        guard canClaimDailyReward else { return }
        addCoins(GameConstants.dailyReward)
        lastDailyRewardDate = Date()
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
