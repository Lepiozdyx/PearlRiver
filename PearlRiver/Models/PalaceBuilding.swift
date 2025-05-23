import Foundation
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
struct PalaceBuilding: Identifiable, Codable {
    let id: String
    let type: PalaceBuildingType
    var level: Int = 0
    
    // Вычисляемые свойства для доходов
    var goldPerDay: Int {
        guard level > 0 else { return 0 }
        
        switch (type, level) {
        case (.kingsKeep, 1): return 3
        case (.kingsKeep, 2): return 7
        case (.kingsKeep, 3): return 12
        case (.kingsKeep, 4): return 20
        case (.kingsKeep, 5): return 30
            
        case (.royalBarracks, 1): return 2
        case (.royalBarracks, 2): return 5
        case (.royalBarracks, 3): return 10
        case (.royalBarracks, 4): return 15
        case (.royalBarracks, 5): return 25
            
        case (.templeOfLight, 1): return 3
        case (.templeOfLight, 2): return 8
        case (.templeOfLight, 3): return 13
        case (.templeOfLight, 4): return 18
        case (.templeOfLight, 5): return 28
            
        case (.grandArena, 1): return 2
        case (.grandArena, 2): return 6
        case (.grandArena, 3): return 11
        case (.grandArena, 4): return 17
        case (.grandArena, 5): return 24
            
        case (.healingSprings, 1): return 2
        case (.healingSprings, 2): return 5
        case (.healingSprings, 3): return 9
        case (.healingSprings, 4): return 13
        case (.healingSprings, 5): return 19
            
        default: return 0
        }
    }
    
    var amuletsPerDay: Int {
        guard level > 0 else { return 0 }
        
        switch level {
        case 1: return 1
        case 2: return 2
        case 3: return 3
        case 4: return 4
        case 5: return 5
        default: return 0
        }
    }
    
    // Стоимость улучшения
    var upgradeCostGold: Int? {
        guard level < maxLevel else { return nil }
        
        switch (type, level + 1) {
        case (.kingsKeep, 1): return 10
        case (.kingsKeep, 2): return 30
        case (.kingsKeep, 3): return 60
        case (.kingsKeep, 4): return 120
        case (.kingsKeep, 5): return 250
            
        case (.royalBarracks, 1): return 15
        case (.royalBarracks, 2): return 40
        case (.royalBarracks, 3): return 80
        case (.royalBarracks, 4): return 150
        case (.royalBarracks, 5): return 300
            
        case (.templeOfLight, 1): return 10
        case (.templeOfLight, 2): return 35
        case (.templeOfLight, 3): return 75
        case (.templeOfLight, 4): return 140
        case (.templeOfLight, 5): return 250
            
        case (.grandArena, 1): return 12
        case (.grandArena, 2): return 30
        case (.grandArena, 3): return 60
        case (.grandArena, 4): return 120
        case (.grandArena, 5): return 250
            
        case (.healingSprings, 1): return 8
        case (.healingSprings, 2): return 25
        case (.healingSprings, 3): return 50
        case (.healingSprings, 4): return 90
        case (.healingSprings, 5): return 200
            
        default: return nil
        }
    }
    
    var upgradeCostAmulets: Int? {
        guard level < maxLevel else { return nil }
        
        switch (type, level + 1) {
        case (.kingsKeep, 1): return 5
        case (.kingsKeep, 2): return 15
        case (.kingsKeep, 3): return 30
        case (.kingsKeep, 4): return 60
        case (.kingsKeep, 5): return 100
            
        case (.royalBarracks, 1): return 7
        case (.royalBarracks, 2): return 20
        case (.royalBarracks, 3): return 40
        case (.royalBarracks, 4): return 70
        case (.royalBarracks, 5): return 120
            
        case (.templeOfLight, 1): return 8
        case (.templeOfLight, 2): return 18
        case (.templeOfLight, 3): return 40
        case (.templeOfLight, 4): return 70
        case (.templeOfLight, 5): return 110
            
        case (.grandArena, 1): return 6
        case (.grandArena, 2): return 15
        case (.grandArena, 3): return 30
        case (.grandArena, 4): return 50
        case (.grandArena, 5): return 90
            
        case (.healingSprings, 1): return 5
        case (.healingSprings, 2): return 12
        case (.healingSprings, 3): return 25
        case (.healingSprings, 4): return 45
        case (.healingSprings, 5): return 80
            
        default: return nil
        }
    }
    
    var maxLevel: Int {
        return 5
    }
    
    var canUpgrade: Bool {
        return level < maxLevel
    }
    
    init(type: PalaceBuildingType, level: Int = 0) {
        self.id = type.rawValue
        self.type = type
        self.level = level
    }
    
    // Создание дефолтного набора зданий
    static func defaultBuildings() -> [PalaceBuilding] {
        return PalaceBuildingType.allCases.map { PalaceBuilding(type: $0) }
    }
}
