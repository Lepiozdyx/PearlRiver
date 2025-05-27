import Foundation

struct PuzzleDefinition {
    let id: Int
    let name: String
    let pieces: [PuzzlePiece]
    
    struct PuzzlePiece {
        let position: Int
        let imageName: String
    }
    
    // Создать пазл по ID
    static func createPuzzle(id: Int) -> PuzzleDefinition {
        let pieces = (1...9).map { position in
            PuzzlePiece(
                position: position,
                imageName: "puzzle_\(id)_piece_\(position)"
            )
        }
        
        return PuzzleDefinition(
            id: id,
            name: "Puzzle \(id)",
            pieces: pieces
        )
    }
    
    static let availablePuzzles: [PuzzleDefinition] = {
        return (1...4).map { createPuzzle(id: $0) }
    }()
    
    static func randomPuzzle() -> PuzzleDefinition {
        return availablePuzzles.randomElement() ?? availablePuzzles[0]
    }
}

// MARK: - Puzzle Game State
struct PuzzlePiece {
    let puzzleId: Int
    let position: Int
    let imageName: String
    
    var isCorrectlyPlaced: Bool = false
}

extension PuzzlePiece: Identifiable {
    var id: String { "\(puzzleId)_\(position)" }
}

extension PuzzlePiece: Equatable {
    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        return lhs.puzzleId == rhs.puzzleId && lhs.position == rhs.position
    }
}
