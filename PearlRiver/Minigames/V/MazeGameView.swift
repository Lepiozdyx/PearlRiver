import SwiftUI
import SpriteKit

struct MazeGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = MazeGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @StateObject private var sceneController = MazeSceneController()
    
    @State private var isWin: Bool = false
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
                
                GeometryReader { geometry in
                    HStack(spacing: 0) {
                        Spacer()
                        Spacer()
                        
                        let mazeSize = CGSize(
                            width: min(geometry.size.width * 0.65, geometry.size.height * 0.9),
                            height: min(geometry.size.width * 0.65, geometry.size.height * 0.9)
                        )
                        
                        MazeViewContainer(
                            size: mazeSize,
                            isWin: $isWin,
                            appViewModel: appViewModel,
                            controller: sceneController
                        )
                        .frame(width: mazeSize.width, height: mazeSize.height)
                        .background {
                            Color.gray
                        }
                        
                        // Control elements
                        if !isWin {
                            MazeControlsView(
                                sceneController: sceneController,
                                width: geometry.size.width * 0.3
                            )
                        }
                        
                        Spacer()
                    }
                }
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            
            if isWin {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 15) {
                        Text("VICTORY!")
                            .fontPRG(36)
                            .padding(.vertical)
                            .padding(.horizontal, 30)
                            .background(
                                Image("labelFrame")
                                    .resizable()
                            )
                            .shadow(color: .green.opacity(0.7), radius: 10)
                        
                        // Action buttons
                        VStack(spacing: 15) {
                            ActionButtonView(title: "Play Again", fontSize: 22, width: 250, height: 60) {
                                sceneController.restartGame()
                                isWin = false
                                viewModel.restartGame()
                            }
                            
                            ActionButtonView(title: "Menu", fontSize: 22, width: 250, height: 60) {
                                appViewModel.navigateTo(.minigamesMenu)
                            }
                        }
                    }
                    .padding(30)
                    .background(
                        Image(.underlay)
                            .resizable()
                    )
                }
            }
        }
        .onAppear {
            viewModel.appViewModel = appViewModel
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}

// MARK: - MazeControlsView
struct MazeControlsView: View {
    @ObservedObject var sceneController: MazeSceneController
    let width: CGFloat
    
    var body: some View {
        VStack {
            Spacer()
            
            VStack(spacing: 4) {
                // Up button
                Button {
                    sceneController.moveUp()
                } label: {
                    Image(.buttonCircle)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .overlay {
                            Image(systemName: "chevron.up")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundColor(.black)
                        }
                }
                
                // Left and Right buttons
                HStack(spacing: 40) {
                    Button {
                        sceneController.moveLeft()
                    } label: {
                        Image(.buttonCircle)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .overlay {
                                Image(systemName: "chevron.left")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.black)
                            }
                    }
                    
                    Button {
                        sceneController.moveRight()
                    } label: {
                        Image(.buttonCircle)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 60)
                            .overlay {
                                Image(systemName: "chevron.right")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 30)
                                    .foregroundColor(.black)
                            }
                    }
                }
                
                // Down button
                Button {
                    sceneController.moveDown()
                } label: {
                    Image(.buttonCircle)
                        .resizable()
                        .scaledToFit()
                        .frame(height: 60)
                        .overlay {
                            Image(systemName: "chevron.down")
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .foregroundColor(.black)
                        }
                }
            }
            .padding(.bottom, 50)
        }
        .frame(width: width)
    }
}

// MARK: - MazeViewContainer
struct MazeViewContainer: UIViewRepresentable {
    let size: CGSize
    @Binding var isWin: Bool
    weak var appViewModel: AppViewModel?
    @ObservedObject var controller: MazeSceneController
    
    func makeUIView(context: Context) -> SKView {
        let skView = SKView(frame: CGRect(origin: .zero, size: size))
        skView.preferredFramesPerSecond = 60
        skView.showsFPS = false
        skView.showsNodeCount = false
        skView.showsDrawCount = false
        skView.showsQuadCount = false
        skView.ignoresSiblingOrder = true
        
        skView.backgroundColor = .clear
        
        return skView
    }
    
    func updateUIView(_ skView: SKView, context: Context) {
        if skView.scene == nil {
            let scene = MazeScene(
                size: size,
                rows: MazeGameConstants.defaultRows,
                cols: MazeGameConstants.defaultCols
            )
            scene.scaleMode = .aspectFill
            scene.isWinHandler = {
                DispatchQueue.main.async {
                    isWin = true
                }
            }
            
            controller.scene = scene
            
            skView.presentScene(scene)
        } else if skView.bounds.size != size {
            skView.bounds = CGRect(origin: .zero, size: size)
            
            if let _ = skView.scene as? MazeScene {
                let newScene = MazeScene(
                    size: size,
                    rows: MazeGameConstants.defaultRows,
                    cols: MazeGameConstants.defaultCols
                )
                newScene.scaleMode = .aspectFill
                newScene.isWinHandler = {
                    DispatchQueue.main.async {
                        isWin = true
                    }
                }
                
                controller.scene = newScene
                
                skView.presentScene(newScene)
            }
        }
    }
}

#Preview {
    MazeGameView()
        .environmentObject(AppViewModel())
}
