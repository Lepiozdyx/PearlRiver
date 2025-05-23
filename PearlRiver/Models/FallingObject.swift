import Foundation
import CoreGraphics

// Типы падающих объектов
enum FallingObjectType: String, CaseIterable {
    case shield = "shield"
    case vase = "vase"
    case torch = "torch"
    case coin = "coin"
    case amulet = "amulet"
    
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
    
    var isCollectable: Bool {
        switch self {
        case .coin, .amulet:
            return true
        case .shield, .vase, .torch:
            return false
        }
    }
    
    var isObstacle: Bool {
        return !isCollectable
    }
    
    var value: Int {
        switch self {
        case .coin:
            return GameConstants.coinValue
        case .amulet:
            return 0 // доступ к бонусной игре
        default:
            return 0
        }
    }
    
    // Вероятность появления объекта (от 0 до 1)
    var spawnProbability: Double {
        switch self {
        case .shield: return 0.25
        case .vase: return 0.25
        case .torch: return 0.25
        case .coin: return 0.20
        case .amulet: return 0.05 // Редкий объект
        }
    }
    
    // Получение случайного типа объекта с учетом вероятностей
    static func random() -> FallingObjectType {
        let totalProbability = allCases.map { $0.spawnProbability }.reduce(0, +)
        let randomValue = Double.random(in: 0...totalProbability)
        
        var accumulator = 0.0
        for type in allCases {
            accumulator += type.spawnProbability
            if randomValue <= accumulator {
                return type
            }
        }
        
        return .shield // Fallback
    }
}

// Модель падающего объекта
struct FallingObject: Identifiable {
    let id = UUID()
    let type: FallingObjectType
    var position: CGPoint
    var velocity: CGFloat // Скорость падения
    let size: CGSize
    var rotation: Double = 0 // Для анимации вращения
    
    init(type: FallingObjectType, position: CGPoint, velocity: CGFloat) {
        self.type = type
        self.position = position
        self.velocity = velocity
        self.size = type.size
        
        // Добавляем начальное вращение для некоторых объектов
        if type == .coin || type == .amulet {
            self.rotation = Double.random(in: 0...360)
        }
    }
    
    // Обновление позиции объекта
    mutating func update(deltaTime: TimeInterval) {
        position.y += velocity * CGFloat(deltaTime)
        
        // Вращение для монет и амулетов
        if type == .coin || type == .amulet {
            rotation += 180 * deltaTime // 180 градусов в секунду
        }
    }
    
    // Проверка выхода за пределы экрана
    func isOffScreen(screenHeight: CGFloat) -> Bool {
        return position.y > screenHeight + size.height / 2
    }
}
