import Foundation

class PuzzleGameViewModel: ObservableObject {
    @Published var timeRemaining: Double = GameConstants.puzzleTimerDuration
    @Published var shuffledPieces: [PuzzlePiece] = []
    @Published var targetGrid: [PuzzlePiece?] = Array(repeating: nil, count: GameConstants.puzzleGridSize * GameConstants.puzzleGridSize)
    @Published var selectedPiece: PuzzlePiece? = nil
    @Published var gameCompleted: Bool = false
    @Published var gameWon: Bool = false
    @Published var currentPuzzle: PuzzleDefinition?
    
    private var timer: Timer?
    
    init() {
        startNewGame()
    }
    
    deinit {
        timer?.invalidate()
    }
    
    func startNewGame() {
        currentPuzzle = PuzzleDefinition.randomPuzzle()
        
        guard let puzzle = currentPuzzle else { return }
        
        let pieces = puzzle.pieces.map { piece in
            PuzzlePiece(
                puzzleId: puzzle.id,
                position: piece.position,
                imageName: piece.imageName
            )
        }
        
        shuffledPieces = pieces.shuffled()
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
    
    func selectPiece(_ piece: PuzzlePiece) {
        guard !gameCompleted else { return }
        selectedPiece = piece
    }
    
    func placePieceAt(index: Int) {
        guard !gameCompleted,
              let piece = selectedPiece,
              targetGrid[index] == nil else {
            return
        }
        
        targetGrid[index] = piece
        
        if let pieceIndex = shuffledPieces.firstIndex(of: piece) {
            shuffledPieces.remove(at: pieceIndex)
        }
        
        selectedPiece = nil
        
        checkWinCondition()
    }
    
    private func checkWinCondition() {
        guard targetGrid.compactMap({ $0 }).count == 9 else {
            return
        }
        
        let isCorrect = targetGrid.enumerated().allSatisfy { index, piece in
            guard let piece = piece else { return false }
            let correctPosition = index + 1
            let isCorrectlyPlaced = piece.position == correctPosition
            
            return isCorrectlyPlaced
        }

        if isCorrect {
            endGame(won: true)
        }
    }
    
    private func endGame(won: Bool) {
            timer?.invalidate()
            
            if won {
                gameWon = true
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
                    guard let self = self else { return }
                    self.gameCompleted = true
                }
            } else {
                gameWon = false
                gameCompleted = true
            }
        }
    
    func isPieceAvailable(_ piece: PuzzlePiece) -> Bool {
        return shuffledPieces.contains(piece)
    }
    
    func isPiecePlaced(_ piece: PuzzlePiece) -> Bool {
        return targetGrid.contains(piece)
    }
}
