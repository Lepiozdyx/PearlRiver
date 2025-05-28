import SwiftUI

struct SequenceGameView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var vm = SequenceGameViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var hasAwardedCoins = false
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppBGView()
                
                VStack {
                    HStack(alignment: .top) {
                        CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                            svm.play()
                            appViewModel.navigateTo(.minigamesMenu)
                        }
                        
                        Spacer()
                        
                        // Sequence counter
                        ZStack {
                            Image(.buttonRect)
                                .resizable()
                                .frame(width: 150, height: 50)
                            
                            Text("lvl : \(vm.currentSequenceLength)")
                                .fontPRG(18)
                        }
                    }
                    Spacer()
                }
                .padding()
                
                Spacer()
                
                HStack(spacing: 20) {
                    Image(.buttonCircle)
                        .resizable()
                        .overlay {
                            if let currentImage = vm.currentShowingImage {
                                Image(currentImage.imageName)
                                    .resizable()
                                    .scaledToFit()
                                    .padding(30)
                                    .transition(.scale.combined(with: .opacity))
                                    .id("currentImage-\(currentImage.id)")
                            }
                        }
                        .frame(width: 150, height: 150)
                    
                    LazyVGrid(columns: columns, spacing: 10) {
                        ForEach(SequenceGameConstants.availableImages, id: \.self) { imageName in
                            SequenceImageButton(
                                imageName: imageName,
                                onTap: {
                                    vm.selectImage(SequenceImage(imageName: imageName))
                                },
                                disabled: vm.gameState != .playing,
                                size: 70
                            )
                        }
                    }
                    .frame(maxWidth: 320)
                }
                .frame(maxWidth: 600)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            
            if vm.gameState == .success {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("Success!")
                            .fontPRG(24)
                        
                        ActionButtonView(title: "Continue", fontSize: 20, width: 200, height: 60) {
                            vm.nextRound()
                        }
                    }
                    .padding(30)
                    .background(
                        Image(.underlay)
                            .resizable()
                    )
                }
                .transition(.opacity)
            } else if vm.gameState == .gameOver {
                ZStack {
                    Color.black.opacity(0.7)
                        .edgesIgnoringSafeArea(.all)
                    
                    VStack(spacing: 20) {
                        Text("Game Over")
                            .fontPRG(24)
                        
                        Text("You made a mistake in the sequence.")
                            .fontPRG(18)
                        
                        if vm.currentSequenceLength > SequenceGameConstants.initialSequenceLength {
                            HStack {
                                Text("Good job!")
                                    .fontPRG(30)
                            }
                            .scaleEffect(hasAwardedCoins ? 1.3 : 1.0)
                            .animation(.spring(response: 0.5, dampingFraction: 0.6), value: hasAwardedCoins)
                        }
                        
                        HStack(spacing: 20) {
                            ActionButtonView(title: "Try Again", fontSize: 18, width: 180, height: 60) {
                                hasAwardedCoins = false
                                vm.restartAfterGameOver()
                            }
                            
                            ActionButtonView(title: "Menu", fontSize: 18, width: 180, height: 60) {
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
                .transition(.opacity)
            }
        }
        .onAppear {
            vm.startNewGame()
            hasAwardedCoins = false
            
            withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                contentOpacity = 1.0
                contentOffset = 0
            }
        }
    }
}


struct SequenceImageButton: View {
    let imageName: String
    let onTap: () -> Void
    let disabled: Bool
    let size: CGFloat
    
    var body: some View {
        Button(action: onTap) {
            Image(.buttonCircle)
                .resizable()
                .overlay {
                    Image(imageName)
                        .resizable()
                        .padding(20)
                }
                .frame(width: size, height: size)
                .opacity(disabled ? 0.6 : 1.0)
        }
        .disabled(disabled)
    }
}

#Preview {
    SequenceGameView()
}
