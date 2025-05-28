import SwiftUI
import Combine

class GuessNumberViewModel: ObservableObject {
    @Published private(set) var gameState: GuessGameState = .playing
    @Published private(set) var targetNumber: Int = 0
    @Published private(set) var attempts: Int = 0
    @Published private(set) var feedbackMessage: String = "Guess the number"
    
    init() {
        startNewGame()
    }
    
    func startNewGame() {
        targetNumber = Int.random(in: GuessNumberConstants.minNumber...GuessNumberConstants.maxNumber)
        attempts = 0
        feedbackMessage = "Guess the number between \(GuessNumberConstants.minNumber) and \(GuessNumberConstants.maxNumber)"
        gameState = .playing
    }
    
    func makeGuess(_ guess: Int) {
        attempts += 1
        
        if guess == targetNumber {
            feedbackMessage = "Correct! You guessed it in \(attempts) attempts."
            gameState = .guessed(correct: true, message: feedbackMessage)
        } else if guess < targetNumber {
            feedbackMessage = "Higher. The number is greater than \(guess)."
            gameState = .guessed(correct: false, message: feedbackMessage)
        } else {
            feedbackMessage = "Lower. The number is less than \(guess)."
            gameState = .guessed(correct: false, message: feedbackMessage)
        }
    }
    
    func continueGame(withNewGuess newGuess: Int? = nil) {
        gameState = .playing
        
        if let newGuess = newGuess {
            DispatchQueue.main.async {
                self.makeGuess(newGuess)
            }
        }
    }
}
