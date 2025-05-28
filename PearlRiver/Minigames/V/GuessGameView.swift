import SwiftUI

struct GuessGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = GuessGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var hasAwardedCoins = false
    @State private var sliderValue: Double = 500
    @State private var titleScale: CGFloat = 0.8
    @State private var titleOpacity: Double = 0
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                        svm.play()
                        appViewModel.navigateTo(.minigamesMenu)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            VStack {
                Spacer()
                
                // Game content
                VStack(spacing: 20) {
                    // Feedback message
                    ZStack {
                        Image(.buttonRect)
                            .resizable()
                            .frame(width: 150, height: 60)
                        
                        Text("\(Int(sliderValue))")
                            .fontPRG(24)
                    }
                    
                    Text(viewModel.feedbackMessage)
                        .fontPRG(16)
                    
                    // Slider
                    HStack {
                        CircleButtonView(icon: "minus", height: 60) {
                            if sliderValue > 0 {
                                sliderValue -= 1
                            }
                        }
                        
                        Slider(value: $sliderValue, in: 0...999, step: 1)
                            .accentColor(.white)
                            .shadow(color: .black, radius: 2)
                            .frame(width: 300)
                        
                        CircleButtonView(icon: "plus", height: 60) {
                            if sliderValue < 999 {
                                sliderValue += 1
                            }
                        }
                    }
                    
                    // Action buttons
                    if case .playing = viewModel.gameState {
                        ActionButtonView(title: "Guess", fontSize: 20, width: 200, height: 60) {
                            viewModel.makeGuess(Int(sliderValue))
                        }
                    }
                    
                    // Continue button after incorrect guess
                    if case .guessed(let correct, _) = viewModel.gameState, !correct {
                        ActionButtonView(title: "Continue", fontSize: 20, width: 200, height: 60) {
                            viewModel.continueGame(withNewGuess: Int(sliderValue))
                        }
                    }
                    
                    // Success buttons
                    if case .guessed(let correct, _) = viewModel.gameState, correct {
                        HStack(spacing: 20) {
                            Text("Success!")
                                .fontPRG(24)
                            .scaleEffect(hasAwardedCoins ? 1.3 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: hasAwardedCoins)
                            
                            ActionButtonView(title: "Play Again", fontSize: 18, width: 150, height: 50) {
                                hasAwardedCoins = false
                                viewModel.startNewGame()
                                sliderValue = 500
                            }
                            
                            ActionButtonView(title: "Menu", fontSize: 18, width: 150, height: 50) {
                                appViewModel.navigateTo(.minigamesMenu)
                            }
                        }
                    }
                }
                .padding(.bottom, 30)
                .padding(.horizontal, 50)
                .background(
                    Image(.underlay)
                        .resizable()
                )
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            viewModel.startNewGame()
            sliderValue = 500
            hasAwardedCoins = false
            
            // Start animations
            withAnimation(.spring(response: 0.5, dampingFraction: 0.6).delay(0.1)) {
                titleScale = 1.0
                titleOpacity = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}

#Preview {
    GuessGameView()
        .environmentObject(AppViewModel())
}
