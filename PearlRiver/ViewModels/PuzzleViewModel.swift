import SwiftUI
import Combine

class PuzzleViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var puzzleGame: PuzzleGame = PuzzleGame()
    @Published var dragState: PuzzleDragState = PuzzleDragState()
    @Published var showResult: Bool = false
    @Published var selectedPiecePosition: Int?
    @Published var secondSelectedPosition: Int?
    
    // MARK: - Properties
    weak var appViewModel: AppViewModel?
    private var timer: Timer?
    
    // MARK: - Computed Properties
    var timeRemainingText: String {
        let seconds = Int(puzzleGame.timeRemaining)
        return String(format: "%d:%02d", seconds / 60, seconds % 60)
    }
    
    var isCompleted: Bool {
        return puzzleGame.state == .completed
    }
    
    var isTimeOut: Bool {
        return puzzleGame.state == .timeOut
    }
    
    // MARK: - Initialization
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        startNewGame()
    }
    
    deinit {
        cleanup()
    }
    
    // MARK: - Game Control
    func startNewGame() {
        puzzleGame.setupNewGame()
        showResult = false
        selectedPiecePosition = nil
        secondSelectedPosition = nil
        startTimer()
    }
    
    private func startTimer() {
        timer?.invalidate()
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            self.puzzleGame.updateTimer(deltaTime: 0.1)
            
            if self.puzzleGame.state != .playing {
                self.timer?.invalidate()
                self.showResult = true
            }
            
            DispatchQueue.main.async {
                self.objectWillChange.send()
            }
        }
    }
    
    // MARK: - Piece Selection
    func selectPiece(at position: Int) {
        guard puzzleGame.state == .playing else { return }
        
        if let firstPosition = selectedPiecePosition {
            if firstPosition == position {
                // Deselect if same piece
                selectedPiecePosition = nil
            } else {
                // Swap pieces
                secondSelectedPosition = position
                swapPieces(firstPosition, position)
                
                // Reset selection after swap
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) { [weak self] in
                    self?.selectedPiecePosition = nil
                    self?.secondSelectedPosition = nil
                }
            }
        } else {
            // Select first piece
            selectedPiecePosition = position
        }
    }
    
    private func swapPieces(_ position1: Int, _ position2: Int) {
        puzzleGame.swapPieces(at: position1, and: position2)
        
        if puzzleGame.state == .completed {
            timer?.invalidate()
            showResult = true
            completePuzzle()
        }
    }
    
    // MARK: - Drag and Drop (альтернативный способ)
    func startDragging(piece: PuzzlePiece) {
        dragState.isDragging = true
        dragState.draggedPiece = piece
    }
    
    func updateDragOffset(_ offset: CGSize) {
        dragState.dragOffset = offset
    }
    
    func endDragging(at position: Int?) {
        if let draggedPiece = dragState.draggedPiece,
           let targetPosition = position,
           draggedPiece.currentPosition != targetPosition {
            puzzleGame.swapPieces(at: draggedPiece.currentPosition, and: targetPosition)
            
            if puzzleGame.state == .completed {
                timer?.invalidate()
                showResult = true
                completePuzzle()
            }
        }
        
        dragState = PuzzleDragState()
    }
    
    // MARK: - Completion
    private func completePuzzle() {
        let success = puzzleGame.state == .completed
        appViewModel?.completePuzzle(success: success)
    }
    
    func continueGame() {
        // Возвращаемся к основной игре
        if appViewModel?.gameViewModel != nil {
            appViewModel?.gameViewModel?.resumeGame()
        }
    }
    
    // MARK: - Cleanup
    private func cleanup() {
        timer?.invalidate()
        timer = nil
    }
}
