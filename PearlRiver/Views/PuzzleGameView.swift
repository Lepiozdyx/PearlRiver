import SwiftUI

struct PuzzleGameView: View {
    @StateObject private var viewModel = PuzzleGameViewModel()
    
    let onComplete: (Bool) -> Void // true если выиграл, false если проиграл
    
    var body: some View {
        ZStack {
            // Фон
            Color.black.opacity(0.9)
                .ignoresSafeArea()
            
            if viewModel.gameCompleted {
                // Экран результата
                VStack(spacing: 30) {
                    Text(viewModel.gameWon ? "PUZZLE COMPLETED!" : "TIME'S UP!")
                        .fontPRG(32)
                    
                    Text(viewModel.gameWon ?
                         "You earned \(GameConstants.puzzleReward) amulets!" :
                         "You earned 0 amulets")
                        .fontPRG(20)
                    
                    Button(action: {
                        onComplete(viewModel.gameWon)
                    }) {
                        Text("CONTINUE")
                            .fontPRG(24)
                            .padding(.horizontal, 40)
                            .padding(.vertical, 15)
                            .background(
                                RoundedRectangle(cornerRadius: 15)
                                    .fill(Color.blue)
                            )
                    }
                }
            } else {
                // Игровой экран
                VStack(spacing: 20) {
                    // Заголовок и таймер
                    HStack {
                        Text("PUZZLE BONUS")
                            .fontPRG(24)
                        
                        Spacer()
                        
                        Text("\(Int(viewModel.timeRemaining))")
                            .fontPRG(32)
                            .foregroundColor(viewModel.timeRemaining <= 3 ? .red : .white)
                    }
                    .padding(.horizontal)
                    
                    // Игровое поле
                    HStack(spacing: 40) {
                        // Левая часть - перемешанные кусочки
                        VStack(spacing: 10) {
                            Text("PIECES")
                                .fontPRG(16)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(viewModel.shuffledPieces, id: \.self) { piece in
                                    PuzzlePieceView(
                                        piece: piece,
                                        size: 60,
                                        isSelected: viewModel.selectedPiece == piece
                                    )
                                    .onTapGesture {
                                        viewModel.selectPiece(piece)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                        
                        // Правая часть - целевая сетка
                        VStack(spacing: 10) {
                            Text("TARGET")
                                .fontPRG(16)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 8) {
                                ForEach(0..<9, id: \.self) { index in
                                    PuzzleSlotView(
                                        targetNumber: index + 1,
                                        currentPiece: viewModel.targetGrid[index],
                                        size: 60
                                    )
                                    .onTapGesture {
                                        if viewModel.selectedPiece != nil {
                                            viewModel.placePieceAt(index: index)
                                        }
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                    }
                    
                    // Инструкция
                    Text("Tap a piece, then tap a slot to place it in the correct order (1-9)")
                        .fontPRG(14)
                        .padding(.horizontal)
                        .opacity(0.8)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startNewGame()
        }
    }
}

#Preview {
    PuzzleGameView(onComplete: {_ in })
}

// MARK: - Puzzle Piece View
struct PuzzlePieceView: View {
    let piece: Int
    let size: CGFloat
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(isSelected ? Color.yellow : Color.blue)
                .frame(width: size, height: size)
            
            Text("\(piece)")
                .font(.system(size: size * 0.4, weight: .bold))
                .foregroundColor(.white)
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

// MARK: - Puzzle Target Slot View
struct PuzzleSlotView: View {
    let targetNumber: Int
    let currentPiece: Int?
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 8)
                .fill(currentPiece != nil ? Color.green : Color.gray.opacity(0.3))
                .frame(width: size, height: size)
            
            if let piece = currentPiece {
                Text("\(piece)")
                    .font(.system(size: size * 0.4, weight: .bold))
                    .foregroundColor(.white)
            } else {
                Text("\(targetNumber)")
                    .font(.system(size: size * 0.3, weight: .light))
                    .foregroundColor(.white.opacity(0.5))
            }
        }
    }
}
