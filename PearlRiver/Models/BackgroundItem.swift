import SwiftUI

struct BackgroundItem: Identifiable, Codable, Equatable {
    let id: String
    let name: String
    let imageName: String
    let price: Int
    
    static func == (lhs: BackgroundItem, rhs: BackgroundItem) -> Bool {
        return lhs.id == rhs.id
    }
    
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
            price: 100
        ),
        BackgroundItem(
            id: "ancient_temple",
            name: "Ancient Temple",
            imageName: "bg_ancient_temple",
            price: 100
        ),
        BackgroundItem(
            id: "old_chambers",
            name: "Royal Chambers",
            imageName: "bg_old_chambers",
            price: 100
        )
    ]
    
    static func getBackground(id: String) -> BackgroundItem {
        return availableBackgrounds.first { $0.id == id } ?? availableBackgrounds[0]
    }
}
