import Foundation

class PuzzleGameViewModel: ObservableObject {
    @Published var timeRemaining: Double = GameConstants.puzzleTimerDuration
    @Published var shuffledPieces: [Int] = []
    @Published var targetGrid: [Int?] = Array(repeating: nil, count: GameConstants.puzzleGridSize * GameConstants.puzzleGridSize)
    @Published var selectedPiece: Int? = nil
    @Published var gameCompleted: Bool = false
    @Published var gameWon: Bool = false
    
    private var timer: Timer?
    private let correctOrder = Array(1...9) // Правильный порядок 1-9
    
    init() {
        startNewGame()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startNewGame() {
        // Перемешиваем кусочки пазла
        shuffledPieces = correctOrder.shuffled()
        targetGrid = Array(repeating: nil, count: 9)
        selectedPiece = nil
        timeRemaining = GameConstants.puzzleTimerDuration
        gameCompleted = false
        gameWon = false
        
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.timeRemaining -= 0.1
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
            
            if self.timeRemaining <= 0 {
                self.endGame(won: false)
            }
        }
    }
    
    func selectPiece(_ piece: Int) {
        guard !gameCompleted else { return }
        selectedPiece = piece
    }
    
    func placePieceAt(index: Int) {
        guard !gameCompleted,
              let piece = selectedPiece,
              targetGrid[index] == nil else { return }
        
        // Размещаем кусочек в сетке
        targetGrid[index] = piece
        
        // Убираем кусочек из доступных
        if let pieceIndex = shuffledPieces.firstIndex(of: piece) {
            shuffledPieces.remove(at: pieceIndex)
        }
        
        selectedPiece = nil
        
        // Проверяем победу
        checkWinCondition()
    }
    
    private func checkWinCondition() {
        guard targetGrid.compactMap({ $0 }).count == 9 else { return }
        
        let isCorrect = targetGrid.enumerated().allSatisfy { index, piece in
            return piece == index + 1
        }
        
        if isCorrect {
            endGame(won: true)
        }
    }
    
    private func endGame(won: Bool) {
        timer?.invalidate()
        gameCompleted = true
        gameWon = won
    }
}
