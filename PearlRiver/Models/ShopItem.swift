import Foundation

// Структура для фонов
struct BackgroundItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: BackgroundItem, rhs: BackgroundItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные фоны в магазине
    static let availableBackgrounds: [BackgroundItem] = [
        BackgroundItem(
            id: "medieval_castle",
            name: "Medieval Castle",
            imageName: "bg_medieval_castle",
            price: 0 // дефолтный
        ),
        BackgroundItem(
            id: "royal_palace",
            name: "Royal Palace",
            imageName: "bg_royal_palace",
            price: GameConstants.shopItemPrice
        ),
        BackgroundItem(
            id: "ancient_temple",
            name: "Ancient Temple",
            imageName: "bg_ancient_temple",
            price: GameConstants.shopItemPrice
        ),
        BackgroundItem(
            id: "royal_chambers",
            name: "Royal Chambers",
            imageName: "bg_royal_chambers",
            price: GameConstants.shopItemPrice
        )
    ]
    
    static func getBackground(id: String) -> BackgroundItem {
        return availableBackgrounds.first { $0.id == id } ?? availableBackgrounds[0]
    }
}

// Структура для скинов персонажа
struct PlayerSkinItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: PlayerSkinItem, rhs: PlayerSkinItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    // Доступные скины в магазине
    static let availableSkins: [PlayerSkinItem] = [
        PlayerSkinItem(
            id: "king_default",
            name: "King",
            imageName: "player_king",
            price: 0 // Бесплатный (дефолтный)
        ),
        PlayerSkinItem(
            id: "king_golden",
            name: "Golden King",
            imageName: "player_king2",
            price: GameConstants.shopItemPrice
        ),
        PlayerSkinItem(
            id: "knight",
            name: "Knight",
            imageName: "player_knight",
            price: GameConstants.shopItemPrice
        ),
        PlayerSkinItem(
            id: "queen",
            name: "Queen",
            imageName: "player_queen",
            price: GameConstants.shopItemPrice
        )
    ]
    
    static func getSkin(id: String) -> PlayerSkinItem {
        return availableSkins.first { $0.id == id } ?? availableSkins[0]
    }
}

// Enum для типов товаров в магазине
enum ShopItemType {
    case background
    case skin
    
    var title: String {
        switch self {
        case .background:
            return "Backgrounds"
        case .skin:
            return "Skins"
        }
    }
}
