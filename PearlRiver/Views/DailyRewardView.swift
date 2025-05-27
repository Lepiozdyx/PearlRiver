import SwiftUI

struct DailyRewardView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
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
                }
                Spacer()
            }
            .padding()
            
            VStack {
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 80)
                    .overlay {
                        Text("Daily Reward")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                Spacer()
                
                HStack {
                    ForEach(1..<8) { day in
                        Image(.buttonCircle)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 100)
                            .overlay {
                                VStack(spacing: 4) {
                                    Text("Day \(day)")
                                        .fontPRG(18)
                                    
                                    HStack(spacing: 2) {
                                        Image(.coin)
                                            .resizable()
                                            .scaledToFit()
                                            .frame(width: 25)
                                        
                                        Text("+ 10")
                                            .fontPRG(16)
                                    }
                                }
                            }
                    }
                }
                
                if appViewModel.canClaimDailyReward {
                    ActionButtonView(
                        title: "Claim +10 Coins",
                        fontSize: 20,
                        width: 250,
                        height: 65
                    ) {
                        svm.play()
                        appViewModel.claimDailyReward()
                    }
                } else {
                    Text("Already claimed today")
                        .fontPRG(18)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    DailyRewardView()
        .environmentObject(AppViewModel())
}
