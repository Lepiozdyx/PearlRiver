import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                // Scene
                SpriteKitGameView(size: geometry.size)
                    .environmentObject(appViewModel)
                    .edgesIgnoringSafeArea(.all)
                
                if let gameViewModel = appViewModel.gameViewModel {
                    VStack {
                        HStack(alignment: .top) {
                            CircleButtonView(icon: "arrowshape.backward.fill", height: 55) {
                                appViewModel.pauseGame()
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .trailing) {
                                ScoreboardView(
                                    amount: gameViewModel.amuletsCollected,
                                    width: 135,
                                    height: 40,
                                    isCoins: false
                                )
                                
                                ScoreboardView(
                                    amount: gameViewModel.coinsCollected,
                                    width: 135,
                                    height: 40
                                )
                            }
                        }
                        Spacer()
                    }
                    .padding()
                }
                
                if let gameVM = appViewModel.gameViewModel {
                    Group {
                        // Pause overlay
                        if gameVM.isPaused {
                            PauseView()
                                .environmentObject(appViewModel)
                                .transition(.opacity)
                                .animation(.easeInOut(duration: 0.3), value: gameVM.isPaused)
                        }
                    }
                }
            }
            .onDisappear {
                // Pause game when leaving the view
                if let gameVM = appViewModel.gameViewModel {
                    gameVM.togglePause(true)
                }
            }
        }
    }
}

// MARK: - SpriteKitGameView

struct SpriteKitGameView: UIViewRepresentable {
    
    @EnvironmentObject private var appViewModel: AppViewModel
    
    let size: CGSize
    
    func makeUIView(context: Context) -> SKView {
        let view = SKView()
        view.preferredFramesPerSecond = 60
        view.showsFPS = false
        view.showsNodeCount = false
        return view
    }
    
    func updateUIView(_ view: SKView, context: Context) {
        if appViewModel.gameViewModel == nil {
            appViewModel.gameViewModel = GameViewModel()
            appViewModel.gameViewModel?.appViewModel = appViewModel
        }
        
        if view.scene == nil {
            let scene = appViewModel.gameViewModel?.setupScene(size: size)
            view.presentScene(scene)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
