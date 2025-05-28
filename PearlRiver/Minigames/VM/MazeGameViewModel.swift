import SwiftUI
import Combine

class MazeGameViewModel: ObservableObject {
    @Published private(set) var gameState: MazeGameState = .playing
    @Published private(set) var hasAwardedCoins = false
    
    private var cancellables = Set<AnyCancellable>()
    
    weak var appViewModel: AppViewModel?
    
    init() {
        setupGame()
    }
    
    private func setupGame() {
        gameState = .playing
        hasAwardedCoins = false
    }
    
    func restartGame() {
        gameState = .playing
        hasAwardedCoins = false
    }
    
    func handleWin() {
        if !hasAwardedCoins {
            gameState = .finished(success: true)
            hasAwardedCoins = true
        }
    }
}
