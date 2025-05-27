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
                
                Text("Daily Reward")
                    .fontPRG(32)
                
                Text("Coming Soon!")
                    .fontPRG(24)
                
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
                        .opacity(0.7)
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
