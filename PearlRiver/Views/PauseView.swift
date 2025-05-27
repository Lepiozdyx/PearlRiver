import SwiftUI

struct PauseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                Image(.underlay)
                    .resizable()
                    .frame(width: 200, height: 70)
                    .overlay {
                        Text("PAUSED")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                VStack(spacing: 15) {
                    ActionButtonView(
                        title: "Continue",
                        fontSize: 24,
                        width: 250,
                        height: 65
                    ) {
                        svm.play()
                        appViewModel.resumeGame()
                    }
                    
                    // Restart button
                    ActionButtonView(
                        title: "Restart",
                        fontSize: 24,
                        width: 250,
                        height: 65
                    ) {
                        svm.play()
                        appViewModel.restartLevel()
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
                }
            }
        }
    }
}

#Preview {
    PauseView()
        .environmentObject(AppViewModel())
}
