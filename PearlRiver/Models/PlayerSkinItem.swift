import SwiftUI

struct PlayerSkinItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: PlayerSkinItem, rhs: PlayerSkinItem) -> Bool {
        return lhs.id == rhs.id
    }
    
    static let availableSkins: [PlayerSkinItem] = [
        PlayerSkinItem(
            id: "king_default",
            name: "King",
            imageName: "player_king",
            price: 0 // дефолтный
        ),
        PlayerSkinItem(
            id: "king_golden",
            name: "Golden King",
            imageName: "player_2king",
            price: 100
        ),
        PlayerSkinItem(
            id: "knight",
            name: "Knight",
            imageName: "player_knight",
            price: 100
        ),
        PlayerSkinItem(
            id: "queen",
            name: "Queen",
            imageName: "player_queen",
            price: 100
        )
    ]
    
    static func getSkin(id: String) -> PlayerSkinItem {
        return availableSkins.first { $0.id == id } ?? availableSkins[0]
    }
}
