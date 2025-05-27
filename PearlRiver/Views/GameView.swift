import SwiftUI
import SpriteKit

struct GameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                SpriteKitGameView(size: geometry.size)
                    .environmentObject(appViewModel)
                    .ignoresSafeArea()
                
                if let gameViewModel = appViewModel.gameViewModel {
                    GameUIOverlayView(gameViewModel: gameViewModel, geometry: geometry)
                        .environmentObject(appViewModel)
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
            appViewModel.gameViewModel?.currentLevel = appViewModel.gameLevel
        }
        
        if view.scene == nil, let gameViewModel = appViewModel.gameViewModel {
            let scene = gameViewModel.setupScene(size: size)
            view.presentScene(scene)
        }
    }
}

#Preview {
    GameView()
        .environmentObject(AppViewModel())
}
