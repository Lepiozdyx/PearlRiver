import SwiftUI

struct MyPalaceView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            AppBGView(name: .bgPalace)
            
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
            
            VStack(spacing: 0) {
                HStack(spacing: 60) {
                    Spacer()
                    ActionButtonView(
                        buttonImage: .healingSprings,
                        title: "",
                        fontSize: 0,
                        width: 100,
                        height: 120
                    ) {
                        
                    }
                    
                    ActionButtonView(
                        buttonImage: .templeOfLight,
                        title: "",
                        fontSize: 0,
                        width: 100,
                        height: 120
                    ) {
                        
                    }
                    .offset(y: 60)
                    Spacer()
                }
                
                HStack {
                    ActionButtonView(
                        buttonImage: .grandArena,
                        title: "",
                        fontSize: 0,
                        width: 130,
                        height: 120
                    ) {
                        
                    }
                    .offset(x: 60)
                    Spacer()
                    ActionButtonView(
                        buttonImage: .kingsKeep,
                        title: "",
                        fontSize: 0,
                        width: 100,
                        height: 120
                    ) {
                        
                    }
                    Spacer()
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    ActionButtonView(
                        buttonImage: .royalBarracks,
                        title: "",
                        fontSize: 0,
                        width: 100,
                        height: 120
                    ) {
                        
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
            }
            .padding()
        }
    }
}

#Preview {
    MyPalaceView()
        .environmentObject(AppViewModel())
}
