import Foundation

struct Achievement: Identifiable, Codable, Equatable {
    let id: String
    let title: String
    let description: String
    let imageName: String
    let requirement: AchievementRequirement
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Все доступные достижения
    static let allAchievements: [Achievement] = [
        Achievement(
            id: "first_victory",
            title: "First Victory",
            description: "Complete your first level",
            imageName: "royalStart",
            requirement: .completeLevels(count: 1)
        ),
        Achievement(
            id: "coin_collector",
            title: "Coin Collector",
            description: "Collect 100 coins in total",
            imageName: "fullTreasure",
            requirement: .collectCoins(amount: 100)
        ),
        Achievement(
            id: "puzzle_master",
            title: "Puzzle Master",
            description: "Complete 10 bonus puzzles",
            imageName: "puzzleSmith",
            requirement: .completePuzzles(count: 10)
        ),
        Achievement(
            id: "palace_builder",
            title: "Palace Builder",
            description: "Upgrade any palace building to level 5",
            imageName: "wreathMaster",
            requirement: .upgradePalaceBuilding(level: 5)
        ),
        Achievement(
            id: "perfect_run",
            title: "Perfect Run",
            description: "Complete a level without hitting any obstacles",
            imageName: "flawlessVictory",
            requirement: .completeWithoutHits
        )
    ]
    
    static func byId(_ id: String) -> Achievement? {
        return allAchievements.first { $0.id == id }
    }
}

// Типы требований для достижений
enum AchievementRequirement: Codable, Equatable {
    case completeLevels(count: Int)
    case collectCoins(amount: Int)
    case collectAmulets(amount: Int)
    case completePuzzles(count: Int)
    case upgradePalaceBuilding(level: Int)
    case completeWithoutHits
    
    // Проверка выполнения требования
    func isSatisfied(by gameState: GameState) -> Bool {
        switch self {
        case .completeLevels(let count):
            return gameState.levelsCompleted.count >= count
            
        case .collectCoins(let amount):
            return gameState.totalCoinsCollected >= amount
            
        case .collectAmulets(let amount):
            return gameState.totalAmuletsCollected >= amount
            
        case .completePuzzles(let count):
            return gameState.puzzlesCompleted >= count
            
        case .upgradePalaceBuilding(let level):
            return gameState.palaceBuildings.contains { $0.level >= level }
            
        case .completeWithoutHits:
            // Проверяется через perfectRuns
            return gameState.perfectRuns > 0
        }
    }
    
    // Кодирование и декодирование для Codable
    enum CodingKeys: String, CodingKey {
        case type
        case value
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        
        switch self {
        case .completeLevels(let count):
            try container.encode("completeLevels", forKey: .type)
            try container.encode(count, forKey: .value)
        case .collectCoins(let amount):
            try container.encode("collectCoins", forKey: .type)
            try container.encode(amount, forKey: .value)
        case .collectAmulets(let amount):
            try container.encode("collectAmulets", forKey: .type)
            try container.encode(amount, forKey: .value)
        case .completePuzzles(let count):
            try container.encode("completePuzzles", forKey: .type)
            try container.encode(count, forKey: .value)
        case .upgradePalaceBuilding(let level):
            try container.encode("upgradePalaceBuilding", forKey: .type)
            try container.encode(level, forKey: .value)
        case .completeWithoutHits:
            try container.encode("completeWithoutHits", forKey: .type)
            try container.encode(0, forKey: .value)
        }
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let type = try container.decode(String.self, forKey: .type)
        
        switch type {
        case "completeLevels":
            let count = try container.decode(Int.self, forKey: .value)
            self = .completeLevels(count: count)
        case "collectCoins":
            let amount = try container.decode(Int.self, forKey: .value)
            self = .collectCoins(amount: amount)
        case "collectAmulets":
            let amount = try container.decode(Int.self, forKey: .value)
            self = .collectAmulets(amount: amount)
        case "completePuzzles":
            let count = try container.decode(Int.self, forKey: .value)
            self = .completePuzzles(count: count)
        case "upgradePalaceBuilding":
            let level = try container.decode(Int.self, forKey: .value)
            self = .upgradePalaceBuilding(level: level)
        case "completeWithoutHits":
            self = .completeWithoutHits
        default:
            throw DecodingError.dataCorrupted(
                DecodingError.Context(
                    codingPath: container.codingPath,
                    debugDescription: "Unknown achievement requirement type"
                )
            )
        }
    }
}
