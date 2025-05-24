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
        let cases = excludingKey ?
        FallingObjectType.allCases.filter({ $0 != .shield }) :
        FallingObjectType.allCases
        
        let randomIndex = Int.random(in: 0..<cases.count)
        return cases[randomIndex]
    }
}
