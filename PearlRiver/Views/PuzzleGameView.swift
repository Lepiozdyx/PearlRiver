import SwiftUI

struct PuzzleGameView: View {
    @StateObject private var viewModel = PuzzleGameViewModel()
    @State private var amuletsAnimated = false
    
    let onComplete: (Bool) -> Void
    
    let grid = Array(repeating: GridItem(.flexible(), spacing: 4), count: 3)
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            if viewModel.gameCompleted {
                VStack(spacing: 30) {
                    Text(viewModel.gameWon ? "PUZZLE COMPLETED!" : "TIME'S UP!")
                        .fontPRG(24)
                    
                    HStack(spacing: 2) {
                        Image(.amulet)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 40)
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
                .padding()
            } else {
                VStack(spacing: 0) {
                    TimerView(timeRemaining: viewModel.timeRemaining)
                    
                    Spacer()
                    
                    HStack(spacing: 0) {
                        // Left
                        PuzzleGridContainer {
                            LazyVGrid(columns: grid, spacing: 4) {
                                ForEach(viewModel.shuffledPieces, id: \.id) { piece in
                                    PuzzlePieceView(
                                        piece: piece,
                                        isSelected: viewModel.selectedPiece?.id == piece.id
                                    ) {
                                        viewModel.selectPiece(piece)
                                    }
                                }
                            }
                        }
                        
                        Spacer()
                        
                        // Right
                        PuzzleGridContainer {
                            LazyVGrid(columns: grid, spacing: 4) {
                                ForEach(0..<9, id: \.self) { index in
                                    PuzzleSlotView(
                                        targetPosition: index + 1,
                                        currentPiece: viewModel.targetGrid[index]
                                    ) {
                                        if viewModel.selectedPiece != nil {
                                            viewModel.placePieceAt(index: index)
                                        }
                                    }
                                }
                            }
                        }
                    }
                    .aspectRatio(2.2, contentMode: .fit)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .padding(.horizontal, 20)
                    
                    Spacer()
                    
                    Text("Tap a piece, then tap a slot to place it in the correct order")
                        .fontPRG(14)
                        .opacity(0.8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
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

struct PuzzleGridContainer<Content: View>: View {
    let content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        content
            .aspectRatio(1, contentMode: .fit)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct TimerView: View {
    let timeRemaining: Double
    
    var body: some View {
        Image(.buttonRect)
            .resizable()
            .scaledToFit()
            .frame(height: 50)
            .overlay {
                Text("0:\(Int(timeRemaining))")
                    .fontPRG(20)
                    .colorMultiply(timeRemaining <= 6 ? .red : .white)
                    .offset(y: 2)
            }
    }
}

struct PuzzlePieceView: View {
    let piece: PuzzlePiece
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color.clear)
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(isSelected ? .yellow : .white.opacity(0.3), lineWidth: isSelected ? 1.5 : 0.5)
                    )
                    .overlay {
                        Image(piece.imageName)
                            .resizable()
                            .scaledToFill()
                            .clipped()
                            .clipShape(RoundedRectangle(cornerRadius: 6))
                    }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .scaleEffect(isSelected ? 1.05 : 1.0)
        .animation(.easeInOut(duration: 0.2), value: isSelected)
    }
}

struct PuzzleSlotView: View {
    let targetPosition: Int
    let currentPiece: PuzzlePiece?
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                RoundedRectangle(cornerRadius: 6)
                    .foregroundStyle(
                        currentPiece != nil
                        ? .green.opacity(0.5)
                        : .yellow.opacity(0.2)
                    )
                    .aspectRatio(1, contentMode: .fit)
                    .overlay(
                        RoundedRectangle(cornerRadius: 6)
                            .stroke(.white.opacity(0.5), lineWidth: 1)
                    )
                
                if let piece = currentPiece {
                    Image(piece.imageName)
                        .resizable()
                        .scaledToFill()
                        .clipped()
                        .clipShape(RoundedRectangle(cornerRadius: 6))
                } else {
                    Text("\(targetPosition)")
                        .fontPRG(12)
                }
            }
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    PuzzleGameView(onComplete: {_ in })
}
