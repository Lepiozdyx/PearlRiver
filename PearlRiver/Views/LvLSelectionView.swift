import SwiftUI

struct LvLSelectionView: View {
    
    @EnvironmentObject private var appViewModel: AppViewModel
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                        appViewModel.navigateTo(.menu)
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
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 100)
                    .overlay {
                        Text("Level select")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                Spacer()
                
                //
                HStack {
                    ForEach(0..<10) { lvl in
                        ActionButtonView(buttonImage: .buttonCircle, title: "Level \(lvl)", fontSize: 10, width: 80, height: 80) {
                            appViewModel.startGame(level: lvl)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LvLSelectionView()
        .environmentObject(AppViewModel())
}
