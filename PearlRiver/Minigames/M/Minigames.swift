import Foundation

enum MiniGameType: String, Codable, CaseIterable, Identifiable {
    case guessNumber = "guess_number"
    case memoryCards = "memory_cards"
    case sequence = "sequence"
    case maze = "maze"
    
    var id: String { self.rawValue }
    
    var title: String {
        switch self {
        case .guessNumber: return "Guess the Number"
        case .memoryCards: return "Memory Cards"
        case .sequence: return "Repeat Sequence"
        case .maze: return "Maze"
        }
    }
}

// MARK: - Memory cards

enum MemoryGameConstants {
    static let gameDuration: TimeInterval = 50
    static let pairsCount = 6
}

enum MemoryCardImage: Int, CaseIterable {
    case card1 = 1, card2, card3, card4, card5, card6
    
    var imageName: String {
        return "card\(self.rawValue)"
    }
}

enum MemoryCardState {
    case down
    case up
    case matched
}

enum MemoryGameState: Equatable {
    case playing
    case finished(success: Bool)
}

struct MemoryCard: Identifiable, Equatable {
    let id = UUID()
    let imageIdentifier: Int
    var state: MemoryCardState = .down
    let position: Position
    
    struct Position: Equatable {
        let row: Int
        let column: Int
        
        static func == (lhs: Position, rhs: Position) -> Bool {
            lhs.row == rhs.row && lhs.column == rhs.column
        }
    }
    
    static func == (lhs: MemoryCard, rhs: MemoryCard) -> Bool {
        lhs.id == rhs.id
    }
}

struct MemoryBoardConfiguration {
    static func generateCards() -> [MemoryCard] {
        var cards: [MemoryCard] = []
        let totalPairs = MemoryGameConstants.pairsCount
        
        for i in 1...totalPairs {
            for _ in 1...2 {
                cards.append(MemoryCard(imageIdentifier: i, position: .init(row: 0, column: 0)))
            }
        }
        
        cards.shuffle()
        
        var index = 0
        for row in 0..<3 {
            for column in 0..<4 {
                guard index < cards.count else { break }
                
                cards[index] = MemoryCard(
                    imageIdentifier: cards[index].imageIdentifier,
                    position: .init(row: row, column: column)
                )
                index += 1
            }
        }
        
        return cards
    }
}

// MARK: - Guess number

enum GuessGameState: Equatable {
    case playing
    case guessed(correct: Bool, message: String)
}

enum GuessNumberConstants {
    static let minNumber = 0
    static let maxNumber = 999
}

// MARK: - Sequence

enum SequenceGameConstants {
    static let initialSequenceLength = 2
    static let showImageDuration: TimeInterval = 1.5
    static let successDuration: TimeInterval = 1.5
    static let availableImages = ["sign1", "sign2", "sign3", "sign4", "sign5", "sign6", "sign7", "sign8"]
}

enum SequenceGameState: Equatable {
    case showing
    case playing
    case success
    case gameOver
}

struct SequenceImage: Identifiable, Equatable {
    let id = UUID()
    let imageName: String
    
    static func random() -> SequenceImage {
        let randomIndex = Int.random(in: 0..<SequenceGameConstants.availableImages.count)
        return SequenceImage(imageName: SequenceGameConstants.availableImages[randomIndex])
    }
    
    static func == (lhs: SequenceImage, rhs: SequenceImage) -> Bool {
        return lhs.imageName == rhs.imageName
    }
}

// MARK: - Maze

enum MazeGameConstants {
    static let defaultRows = 15
    static let defaultCols = 15
}

enum MazeGameState: Equatable {
    case playing
    case finished(success: Bool)
}
