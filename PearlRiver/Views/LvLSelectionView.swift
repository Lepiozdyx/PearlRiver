import SwiftUI

struct LvLSelectionView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var animateButtons = false
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                // Header with back button and currency
                HStack(alignment: .top) {
                    CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        ScoreboardView(
                            amount: appViewModel.amulets,
                            width: 145,
                            height: 45,
                            isCoins: false
                        )
                        
                        ScoreboardView(
                            amount: appViewModel.coins,
                            width: 145,
                            height: 45
                        )
                    }
                }
                Spacer()
            }
            .padding()
            
            VStack {
                // Title
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 100)
                    .overlay {
                        Text("Level Select")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                Spacer()
                
                // Levels grid
                HStack {
                    ForEach (1..<11) { level in
                        LevelButtonView(
                            level: level,
                            isUnlocked: appViewModel.isLevelUnlocked(level),
                            isCompleted: appViewModel.isLevelCompleted(level),
                            animateButtons: animateButtons
                        ) {
                            svm.play()
                            appViewModel.startGame(level: level)
                        }
                        .scaleEffect(animateButtons ? 1.0 : 0.8)
                        .opacity(animateButtons ? 1.0 : 0)
                        .animation(
                            .spring(response: 0.6, dampingFraction: 0.8)
                            .delay(Double(level) * 0.05),
                            value: animateButtons
                        )
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                animateButtons = true
            }
        }
    }
}

// MARK: - Level Button Component
struct LevelButtonView: View {
    let level: Int
    let isUnlocked: Bool
    let isCompleted: Bool
    let animateButtons: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button {
            if isUnlocked {
                action()
            }
        } label: {
            ZStack {
                // Button background
                Image(.buttonCircle)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 60)
                    .opacity(isUnlocked ? 1.0 : 0.7)
                    .overlay(
                        // Lock overlay for locked levels
                        Group {
                            if !isUnlocked {
                                Image(systemName: "lock.fill")
                                    .font(.system(size: 30))
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    )
                    .overlay(alignment: .top) {
                        // Stars for completed levels
                        if isCompleted {
                            Image(systemName: "star.fill")
                                .font(.system(size: 12))
                                .foregroundColor(.yellow)
                        }
                    }
                
                // Level number
                if isUnlocked {
                    Text("\(level)")
                        .fontPRG(26)
                }
            }
            .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .disabled(!isUnlocked)
        .onLongPressGesture(
            minimumDuration: 0,
            maximumDistance: .infinity,
            pressing: { pressing in
                withAnimation(.easeInOut(duration: 0.1)) {
                    isPressed = pressing
                }
            },
            perform: {}
        )
    }
}

#Preview {
    LvLSelectionView()
        .environmentObject(AppViewModel())
}
