import SwiftUI

struct AchievementView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = AchievementViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
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
            
            VStack(spacing: 0) {
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 80)
                    .overlay {
                        Text("Achievements")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                Spacer()
                
                // Main content
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 10) {
                        ForEach(viewModel.achievements) { achievement in
                            AchiItemView(
                                achievement: achievement,
                                isCompleted: viewModel.isAchievementCompleted(achievement.id),
                                isNotified: viewModel.isAchievementClaimed(achievement.id),
                                progress: viewModel.getAchievementProgress(achievement),
                                onClaim: {
                                    svm.play()
                                    viewModel.claimAchievement(achievement.id)
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .opacity(contentOpacity)
                    .offset(y: contentOffset)
                }
                .frame(maxWidth: 450)
                .padding(.vertical, 40)
                .padding(.horizontal, 30)
                .background(
                    Image(.underlay)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.appViewModel = appViewModel
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
            }
        }
    }
}

struct AchiItemView: View {
    let achievement: Achievement
    let isCompleted: Bool
    let isNotified: Bool
    let progress: (current: Int, total: Int)?
    let onClaim: () -> Void
    
    @State private var animate = false
    
    var body: some View {
        VStack {
            Image(achievement.imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 100)
                .colorMultiply(isCompleted ? .white : .black)
                .scaleEffect(animate && isCompleted && !isNotified ? 1.1 : 1.0)
                .animation(
                    Animation.easeInOut(duration: 1.5)
                        .repeatForever(autoreverses: true),
                    value: animate
                )
                .onAppear {
                    animate = true
                }
                .overlay(alignment: .bottomTrailing) {
                    // Claim reward button or status
                    VStack {
                        if isCompleted {
                            if isNotified {
                                Image(.amulet)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 30)
                                    .shadow(color: .black, radius: 3)
                                    .background() {
                                        Circle()
                                            .frame(width: 20, height: 20)
                                            .foregroundColor(.green)
                                            .offset(y: -2)
                                    }
                            } else {
                                Button(action: onClaim) {
                                    HStack(spacing: 2) {
                                        Image("coin")
                                            .resizable()
                                            .scaledToFit()
                                            .frame(height: 20)
                                        
                                        Text("claim")
                                            .fontPRG(14)
                                    }
                                    .padding(.horizontal, 12)
                                    .padding(.vertical, 8)
                                    .background(
                                        Image(.buttonRect)
                                            .resizable()
                                            .shadow(color: .black.opacity(0.5), radius: 3)
                                    )
                                    .scaleEffect(animate ? 1.05 : 1.0)
                                    .animation(
                                        Animation.easeInOut(duration: 0.8)
                                            .repeatForever(autoreverses: true),
                                        value: animate
                                    )
                                }
                            }
                        }
                    }
                }
            
            // Achievement information
            VStack(spacing: 5) {
                Text(achievement.description)
                    .fontPRG(10)
                    .lineLimit(4)
                    .frame(width: 100)
                
                if let progress = progress, !isCompleted {
                    HStack(spacing: 4) {
                        Text("Progress:")
                            .fontPRG(10)
                        
                        Text("\(progress.current)/\(progress.total)")
                            .fontPRG(12)
                    }
                }
            }
            .frame(height: 80)
        }
    }
}

#Preview {
    AchievementView()
        .environmentObject(AppViewModel())
}
