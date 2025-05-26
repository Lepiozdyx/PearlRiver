import SwiftUI

struct PuzzleGameView: View {
    @StateObject private var viewModel = PuzzleGameViewModel()
    @State private var amuletsAnimated = false
    
    let onComplete: (Bool) -> Void
    
    var body: some View {
        ZStack {
            // Фон
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            if viewModel.gameCompleted {
                // Экран результата
                VStack(spacing: 30) {
                    Text(viewModel.gameWon ? "PUZZLE COMPLETED!" : "TIME'S UP!")
                        .fontPRG(32)
                    
                    // Amulets earned
                    HStack(spacing: 2) {
                        Image(.amulet)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(amuletsAnimated ? -360 : 0))
                        
                        Text(
                            viewModel.gameWon
                            ? "+ \(GameConstants.puzzleReward)"
                            : " 0 amulets"
                        )
                        .fontPRG(26)
                    }
                    .scaleEffect(amuletsAnimated ? 1.0 : 0)
                    .opacity(amuletsAnimated ? 1.0 : 0)
                    
                    ActionButtonView(title: "Continue", fontSize: 24, width: 250, height: 65) {
                        onComplete(viewModel.gameWon)
                    }
                }
            } else {
                // Игровой экран
                VStack(spacing: 20) {
                    // Заголовок и таймер
                    HStack {
                        Text("Bonus Game")
                            .fontPRG(22)
                        
                        Spacer()
                        
                        Image(.buttonRect)
                            .resizable()
                            .frame(width: 110, height: 50)
                            .overlay {
                                Text("0:\(Int(viewModel.timeRemaining))")
                                    .fontPRG(30)
                                    .colorMultiply(viewModel.timeRemaining <= 6 ? .red : .white)
                                    .offset(y: 2)
                            }
                    }
                    .frame(width: 350)
                    
                    // Игровое поле
                    HStack(spacing: 40) {
                        // Левая часть - перемешанные кусочки
                        VStack(spacing: 10) {
                            Text("PIECES")
                                .fontPRG(16)
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
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
                            
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
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
                    Text("Tap a piece, then tap a slot to place it in the correct order")
                        .fontPRG(14)
                        .opacity(0.8)
                    
                    Spacer()
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startNewGame()
            
            // Animate amulets
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                amuletsAnimated = true
            }
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
