import SwiftUI

struct MenuView: View {
    
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                HStack(alignment: .top) {
                    VStack(alignment: .leading) {
                        ActionButtonView(
                            buttonImage: .buttonCircle,
                            title: "Daily Quest",
                            fontSize: 16,
                            width: 100,
                            height: 100
                        ) {
                            appViewModel.navigateTo(.daily)
                        }
                        
                        ActionButtonView(
                            buttonImage: .buttonPalace,
                            title: "",
                            fontSize: 16,
                            width: 90,
                            height: 110
                        ) {
                            appViewModel.navigateTo(.myPalace)
                        }
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing) {
                        ScoreboardView(amount: appViewModel.amulets, width: 155, height: 55, isCoins: false)
                        
                        ScoreboardView(amount: appViewModel.coins, width: 155, height: 55)
                    }
                }
                
                Spacer()
            }
            .padding()
            
            VStack {
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 100)
                
                Spacer()
                
                VStack(spacing: 10) {
                    HStack(spacing: 6) {
                        // Play
                        ActionButtonView(
                            title: "Play",
                            fontSize: 22,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.levelSelect)
                        }
                        
                        // Minigames
                        ActionButtonView(
                            title: "Mini games",
                            fontSize: 22,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.minigamesMenu)
                        }
                    }
                    
                    HStack(spacing: 6) {
                        // Shop
                        ActionButtonView(
                            title: "Shop",
                            fontSize: 22,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.shop)
                        }
                        
                        // Achievements
                        ActionButtonView(
                            title: "Achievements",
                            fontSize: 22,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.achievements)
                        }
                        
                        // Settings
                        ActionButtonView(
                            title: "Settings",
                            fontSize: 22,
                            width: 250,
                            height: 90
                        ) {
                            appViewModel.navigateTo(.settings)
                        }
                    }
                }
            }
            .padding()
        }
    }
}

#Preview {
    MenuView()
        .environmentObject(AppViewModel())
}
