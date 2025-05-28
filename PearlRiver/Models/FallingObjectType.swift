import SwiftUI

enum FallingObjectType: Int, CaseIterable, Identifiable {
    case shield = 0
    case vase
    case torch
    case coin
    case amulet
    
    var id: Int { self.rawValue }
    
    var imageResource: ImageResource {
        switch self {
        case .shield: return .shield
        case .vase: return .vase
        case .torch: return .torch
        case .coin: return .coin
        case .amulet: return .amulet
        }
    }
    
    var imageName: String {
        switch self {
        case .shield: return "shield"
        case .vase: return "vase"
        case .torch: return "torch"
        case .coin: return "coin"
        case .amulet: return "amulet"
        }
    }
    
    var size: CGSize {
        switch self {
        case .shield: return GameConstants.ObjectSizes.shield
        case .vase: return GameConstants.ObjectSizes.vase
        case .torch: return GameConstants.ObjectSizes.torch
        case .coin: return GameConstants.ObjectSizes.coin
        case .amulet: return GameConstants.ObjectSizes.amulet
        }
    }
    
    var points: Int {
        return 1
    }
    
    static func random(excludingKey: Bool = true) -> FallingObjectType {
        let weights: [(type: FallingObjectType, weight: Int)] = [
            (.shield, 25),
            (.vase, 25),
            (.torch, 20),
            (.coin, 20),
            (.amulet, 10)
        ]
        
        return weightedRandom(from: weights)
    }
    
    private static func weightedRandom(from weights: [(type: FallingObjectType, weight: Int)]) -> FallingObjectType {
        let totalWeight = weights.reduce(0) { $0 + $1.weight }
        let randomValue = Int.random(in: 1...totalWeight)
        
        var currentWeight = 0
        for (type, weight) in weights {
            currentWeight += weight
            if randomValue <= currentWeight {
                return type
            }
        }
        
        return .vase
    }
    
    static var gameObjectTypes: [FallingObjectType] {
        return [.shield, .vase, .torch, .coin, .amulet]
    }
}
