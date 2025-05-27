import SwiftUI

struct GameOverView: View {
    let coinsEarned: Int
    let amuletsEarned: Int
    let currentLevel: Int
    let isLastLevel: Bool
    
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var showContent = false
    @State private var coinsAnimated = false
    @State private var amuletsAnimated = false
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack {
                Image(.underlay)
                    .resizable()
                    .frame(width: 300, height: 100)
                    .overlay {
                        Text("Level \(currentLevel) complete")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                    .scaleEffect(showContent ? 1.0 : 0.5)
                    .opacity(showContent ? 1.0 : 0)
                
                // Rewards
                HStack(spacing: 20) {
                    // Coins earned
                    HStack(spacing: 2) {
                        Image(.coin)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(coinsAnimated ? 360 : 0))
                        
                        Text("+ \(coinsEarned)")
                            .fontPRG(26)
                    }
                    .scaleEffect(coinsAnimated ? 1.0 : 0)
                    .opacity(coinsAnimated ? 1.0 : 0)
                    
                    // Amulets earned
                    HStack(spacing: 2) {
                        Image(.amulet)
                            .resizable()
                            .frame(width: 40, height: 40)
                            .rotationEffect(.degrees(amuletsAnimated ? -360 : 0))
                        
                        Text("+ \(amuletsEarned)")
                            .fontPRG(26)
                    }
                    .scaleEffect(amuletsAnimated ? 1.0 : 0)
                    .opacity(amuletsAnimated ? 1.0 : 0)
                }
                
                // Buttons
                VStack(spacing: 15) {
                    // Next Level button
                    if !isLastLevel {
                        ActionButtonView(
                            title: "Next Level",
                            fontSize: 24,
                            width: 250,
                            height: 65
                        ) {
                            svm.play()
                            appViewModel.goToNextLevel()
                        }
                        .opacity(showContent ? 1.0 : 0)
                    }
                    
                    // Menu button
                    ActionButtonView(
                        title: "Menu",
                        fontSize: 24,
                        width: 250,
                        height: 65
                    ) {
                        svm.play()
                        appViewModel.goToMenu()
                    }
                    .opacity(showContent ? 1.0 : 0)
                }
            }
            .padding()
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
                coinsAnimated = true
            }
            
            withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.5)) {
                amuletsAnimated = true
            }
        }
    }
}

#Preview {
    GameOverView(coinsEarned: 5, amuletsEarned: 10, currentLevel: 1, isLastLevel: false)
}
