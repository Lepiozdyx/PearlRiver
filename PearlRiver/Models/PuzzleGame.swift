import Foundation
import SwiftUI

// Модель кусочка пазла
struct PuzzlePiece: Identifiable, Equatable {
    let id = UUID()
    let correctPosition: Int // Правильная позиция (0-8 для пазла 3x3)
    var currentPosition: Int // Текущая позиция
    let imageName: String // Имя изображения части пазла
    
    var isInCorrectPosition: Bool {
        return currentPosition == correctPosition
    }
    
    static func == (lhs: PuzzlePiece, rhs: PuzzlePiece) -> Bool {
        return lhs.id == rhs.id
    }
}

// Состояние игры в пазл
enum PuzzleGameState: Equatable {
    case playing
    case completed
    case timeOut
}

// Модель игры в пазл
struct PuzzleGame {
    var pieces: [PuzzlePiece] = []
    var state: PuzzleGameState = .playing
    var timeRemaining: TimeInterval = GameConstants.puzzleTimerDuration
    
    // Инициализация новой игры
    mutating func setupNewGame() {
        // Создаем 9 кусочков пазла (3x3)
        pieces = []
        for i in 0..<9 {
            let piece = PuzzlePiece(
                correctPosition: i,
                currentPosition: i,
                imageName: "puzzle_piece_\(i)"
            )
            pieces.append(piece)
        }
        
        // Перемешиваем позиции
        shufflePieces()
        
        state = .playing
        timeRemaining = GameConstants.puzzleTimerDuration
    }
    
    // Перемешивание кусочков
    private mutating func shufflePieces() {
        var positions = Array(0..<9)
        positions.shuffle()
        
        for i in 0..<pieces.count {
            pieces[i].currentPosition = positions[i]
        }
    }
    
    // Обмен местами двух кусочков
    mutating func swapPieces(at position1: Int, and position2: Int) {
        guard state == .playing else { return }
        
        if let index1 = pieces.firstIndex(where: { $0.currentPosition == position1 }),
           let index2 = pieces.firstIndex(where: { $0.currentPosition == position2 }) {
            
            pieces[index1].currentPosition = position2
            pieces[index2].currentPosition = position1
            
            // Проверяем, собран ли пазл
            checkCompletion()
        }
    }
    
    // Проверка завершения пазла
    private mutating func checkCompletion() {
        if pieces.allSatisfy({ $0.isInCorrectPosition }) {
            state = .completed
        }
    }
    
    // Обновление таймера
    mutating func updateTimer(deltaTime: TimeInterval) {
        guard state == .playing else { return }
        
        timeRemaining -= deltaTime
        if timeRemaining <= 0 {
            timeRemaining = 0
            state = .timeOut
        }
    }
    
    // Получение кусочка по позиции
    func getPiece(at position: Int) -> PuzzlePiece? {
        return pieces.first { $0.currentPosition == position }
    }
}

// Дополнительная структура для хранения состояния перетаскивания в UI
struct PuzzleDragState {
    var isDragging: Bool = false
    var draggedPiece: PuzzlePiece?
    var dragOffset: CGSize = .zero
    var hoveredPosition: Int?
}
