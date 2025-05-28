import SwiftUI

// Типы зданий дворца
enum PalaceBuildingType: String, Codable, CaseIterable {
    case kingsKeep = "kings_keep"
    case royalBarracks = "royal_barracks"
    case templeOfLight = "temple_of_light"
    case grandArena = "grand_arena"
    case healingSprings = "healing_springs"
    
    var displayName: String {
        switch self {
        case .kingsKeep: return "King's Keep"
        case .royalBarracks: return "Royal Barracks"
        case .templeOfLight: return "Temple of Light"
        case .grandArena: return "Grand Arena"
        case .healingSprings: return "Healing Springs"
        }
    }
    
    var description: String {
        switch self {
        case .kingsKeep:
            return "A grand fortress tower where the ruler oversees the kingdom. Upgrading the keep enhances control, unlocking new features and expanding your influence."
        case .royalBarracks:
            return "The training ground for the king's army. Upgrading increases defense and speeds up the recruitment of knights."
        case .templeOfLight:
            return "A sacred place devoted to divine powers. Upgrading grants blessings and brings spiritual prosperity."
        case .grandArena:
            return "A massive arena where knights fight for honor and glory. Upgrading draws more spectators and increases revenue."
        case .healingSprings:
            return "Restorative baths where citizens rejuvenate. Upgrading improves wellbeing and lowers health-related costs."
        }
    }
    
    var imageName: String {
        switch self {
        case .kingsKeep: return "kings_keep"
        case .royalBarracks: return "royal_barracks"
        case .templeOfLight: return "temple_of_light"
        case .grandArena: return "grand_arena"
        case .healingSprings: return "healing_springs"
        }
    }
}

// Модель здания дворца
struct PalaceBuilding: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let description: String
    let imageName: String
    var level: Int
    
    static func == (lhs: PalaceBuilding, rhs: PalaceBuilding) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Вычисляемые свойства для текущего уровня
    var goldPerDay: Int {
        return getGoldPerDay(for: level)
    }
    
    var amuletsPerDay: Int {
        return getAmuletsPerDay(for: level)
    }
    
    // ДОБАВЛЕНО: Вычисляемые свойства для следующего уровня
    var nextLevelGoldPerDay: Int {
        guard canUpgrade else { return goldPerDay }
        return getGoldPerDay(for: level + 1)
    }
    
    var nextLevelAmuletsPerDay: Int {
        guard canUpgrade else { return amuletsPerDay }
        return getAmuletsPerDay(for: level + 1)
    }
    
    // ДОБАВЛЕНО: Приватные методы для расчета дохода по уровню
    private func getGoldPerDay(for buildingLevel: Int) -> Int {
        switch id {
        case "kings_keep":
            switch buildingLevel {
            case 1: return 3
            case 2: return 7
            case 3: return 12
            case 4: return 20
            case 5: return 30
            default: return 0
            }
        case "royal_barracks":
            switch buildingLevel {
            case 1: return 2
            case 2: return 5
            case 3: return 10
            case 4: return 15
            case 5: return 25
            default: return 0
            }
        case "temple_of_light":
            switch buildingLevel {
            case 1: return 3
            case 2: return 8
            case 3: return 13
            case 4: return 18
            case 5: return 28
            default: return 0
            }
        case "grand_arena":
            switch buildingLevel {
            case 1: return 2
            case 2: return 6
            case 3: return 11
            case 4: return 17
            case 5: return 24
            default: return 0
            }
        case "healing_springs":
            switch buildingLevel {
            case 1: return 2
            case 2: return 5
            case 3: return 9
            case 4: return 13
            case 5: return 19
            default: return 0
            }
        default: return 0
        }
    }
    
    private func getAmuletsPerDay(for buildingLevel: Int) -> Int {
        switch id {
        case "kings_keep":
            switch buildingLevel {
            case 1: return 1
            case 2: return 2
            case 3: return 3
            case 4: return 5
            case 5: return 7
            default: return 0
            }
        case "royal_barracks":
            switch buildingLevel {
            case 1: return 1
            case 2: return 2
            case 3: return 3
            case 4: return 4
            case 5: return 5
            default: return 0
            }
        case "temple_of_light":
            switch buildingLevel {
            case 1: return 1
            case 2: return 2
            case 3: return 3
            case 4: return 4
            case 5: return 5
            default: return 0
            }
        case "grand_arena":
            switch buildingLevel {
            case 1: return 1
            case 2: return 2
            case 3: return 3
            case 4: return 4
            case 5: return 5
            default: return 0
            }
        case "healing_springs":
            switch buildingLevel {
            case 1: return 1
            case 2: return 2
            case 3: return 3
            case 4: return 4
            case 5: return 5
            default: return 0
            }
        default: return 0
        }
    }
    
    var upgradeCostGold: Int {
        let nextLevel = level + 1
        guard nextLevel <= 5 else { return 0 }
        
        switch id {
        case "kings_keep":
            switch nextLevel {
            case 2: return 30
            case 3: return 60
            case 4: return 120
            case 5: return 250
            default: return 0
            }
        case "royal_barracks":
            switch nextLevel {
            case 2: return 40
            case 3: return 80
            case 4: return 150
            case 5: return 300
            default: return 0
            }
        case "temple_of_light":
            switch nextLevel {
            case 2: return 35
            case 3: return 75
            case 4: return 140
            case 5: return 250
            default: return 0
            }
        case "grand_arena":
            switch nextLevel {
            case 2: return 30
            case 3: return 60
            case 4: return 120
            case 5: return 250
            default: return 0
            }
        case "healing_springs":
            switch nextLevel {
            case 2: return 25
            case 3: return 50
            case 4: return 90
            case 5: return 200
            default: return 0
            }
        default: return 0
        }
    }
    
    var upgradeCostAmulets: Int {
        let nextLevel = level + 1
        guard nextLevel <= 5 else { return 0 }
        
        switch id {
        case "kings_keep":
            switch nextLevel {
            case 2: return 15
            case 3: return 30
            case 4: return 60
            case 5: return 100
            default: return 0
            }
        case "royal_barracks":
            switch nextLevel {
            case 2: return 20
            case 3: return 40
            case 4: return 70
            case 5: return 120
            default: return 0
            }
        case "temple_of_light":
            switch nextLevel {
            case 2: return 18
            case 3: return 40
            case 4: return 70
            case 5: return 110
            default: return 0
            }
        case "grand_arena":
            switch nextLevel {
            case 2: return 15
            case 3: return 30
            case 4: return 50
            case 5: return 90
            default: return 0
            }
        case "healing_springs":
            switch nextLevel {
            case 2: return 12
            case 3: return 25
            case 4: return 45
            case 5: return 80
            default: return 0
            }
        default: return 0
        }
    }
    
    var canUpgrade: Bool {
        return level < 5
    }
    
    mutating func upgrade() {
        if canUpgrade {
            level += 1
        }
    }
    
    // Дефолтные здания дворца согласно ТЗ
    static func defaultBuildings() -> [PalaceBuilding] {
        return [
            PalaceBuilding(
                id: "kings_keep",
                name: "King's Keep",
                description: "A grand fortress tower where the ruler oversees the kingdom. Upgrading the keep enhances control, unlocking new features and expanding your influence.",
                imageName: "building_kings_keep",
                level: 1
            ),
            PalaceBuilding(
                id: "royal_barracks",
                name: "Royal Barracks",
                description: "The training ground for the king's army. Upgrading increases defense and speeds up the recruitment of knights.",
                imageName: "building_royal_barracks",
                level: 1
            ),
            PalaceBuilding(
                id: "temple_of_light",
                name: "Temple of Light",
                description: "A sacred place devoted to divine powers. Upgrading grants blessings and brings spiritual prosperity.",
                imageName: "building_temple_of_light",
                level: 1
            ),
            PalaceBuilding(
                id: "grand_arena",
                name: "Grand Arena",
                description: "A massive arena where knights fight for honor and glory. Upgrading draws more spectators and increases revenue.",
                imageName: "building_grand_arena",
                level: 1
            ),
            PalaceBuilding(
                id: "healing_springs",
                name: "Healing Springs",
                description: "Restorative baths where citizens rejuvenate. Upgrading improves wellbeing and lowers health-related costs.",
                imageName: "building_healing_springs",
                level: 1
            )
        ]
    }
}
