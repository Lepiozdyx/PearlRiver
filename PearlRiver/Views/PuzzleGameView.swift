import SwiftUI

struct PuzzleGameView: View {
    @StateObject private var viewModel = PuzzleGameViewModel()
    @State private var amuletsAnimated = false
    
    let onComplete: (Bool) -> Void
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            if viewModel.gameCompleted {
                VStack(spacing: 30) {
                    Text(viewModel.gameWon ? "PUZZLE COMPLETED!" : "TIME'S UP!")
                        .fontPRG(32)
                    
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
                VStack(spacing: 10) {
                    Image(.buttonRect)
                        .resizable()
                        .frame(width: 110, height: 50)
                        .overlay {
                            Text("0:\(Int(viewModel.timeRemaining))")
                                .fontPRG(20)
                                .colorMultiply(viewModel.timeRemaining <= 6 ? .red : .white)
                                .offset(y: 2)
                        }
                    
                    Spacer()
                    
                    // Grid
                    HStack(spacing: 40) {
                        VStack(spacing: 10) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                                ForEach(viewModel.shuffledPieces, id: \.id) { piece in
                                    PuzzlePieceImageView(
                                        piece: piece,
                                        size: 60,
                                        isSelected: viewModel.selectedPiece?.id == piece.id
                                    )
                                    .onTapGesture {
                                        viewModel.selectPiece(piece)
                                    }
                                }
                            }
                            .frame(width: 200)
                        }
                        
                        VStack(spacing: 10) {
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 4) {
                                ForEach(0..<9, id: \.self) { index in
                                    PuzzleSlotImageView(
                                        targetPosition: index + 1,
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
                    
                    Spacer()
                    
                    Text("Tap a piece, then tap a slot to place it in the correct order")
                        .fontPRG(14)
                        .opacity(0.8)
                }
                .padding()
            }
        }
        .onAppear {
            viewModel.startNewGame()
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                amuletsAnimated = true
            }
        }
    }
}

struct PuzzlePieceImageView: View {
    let piece: PuzzlePiece
    let size: CGFloat
    let isSelected: Bool
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .fill(Color.clear)
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(isSelected ? .yellow : .white.opacity(0.3), lineWidth: isSelected ? 1.5 : 0.5)
                )
                .overlay {
                    Image(piece.imageName)
                        .resizable()
                        .scaledToFill()
                        .frame(width: size - 2, height: size - 2)
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                        .overlay(
                            // Показываем номер позиции для отладки (можно убрать потом)
                            Text("\(piece.position)")
                                .fontPRG(14)
                                .frame(width: 16, height: 16), alignment: .topTrailing)
                            #warning("delete numbers")
                }
        }
        .scaleEffect(isSelected ? 1.1 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct PuzzleSlotImageView: View {
    let targetPosition: Int
    let currentPiece: PuzzlePiece?
    let size: CGFloat
    
    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 6)
                .foregroundStyle(
                    currentPiece != nil
                    ? .green.opacity(0.5)
                    : .yellow.opacity(0.2)
                )
                .frame(width: size, height: size)
                .overlay(
                    RoundedRectangle(cornerRadius: 6)
                        .stroke(.white.opacity(0.5), lineWidth: 1)
                )
            
            if let piece = currentPiece {
                Image(piece.imageName)
                    .resizable()
                    .scaledToFill()
                    .frame(width: size - 2, height: size - 2)
                    .clipShape(RoundedRectangle(cornerRadius: 6))
                    
            } else {
                Text("\(targetPosition)")
                    .fontPRG(14)
            }
        }
    }
}

#Preview {
    PuzzleGameView(onComplete: {_ in })
}
