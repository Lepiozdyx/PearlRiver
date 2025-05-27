import SwiftUI

struct PauseView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 20) {
                // Заголовок паузы
                Image(.underlay)
                    .resizable()
                    .frame(width: 200, height: 70)
                    .overlay {
                        Text("PAUSED")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                VStack(spacing: 15) {
                    // Continue button
                    Button {
                        svm.play()
                        appViewModel.resumeGame()
                    } label: {
                        ActionButtonView(
                            title: "Continue",
                            fontSize: 24,
                            width: 250,
                            height: 65
                        ) {}
                    }
                    
                    // Restart button
                    Button {
                        svm.play()
                        appViewModel.restartLevel()
                    } label: {
                        ActionButtonView(
                            title: "Restart",
                            fontSize: 24,
                            width: 250,
                            height: 65
                        ) {}
                    }
                    
                    // Menu button
                    Button {
                        svm.play()
                        appViewModel.goToMenu()
                    } label: {
                        ActionButtonView(
                            title: "Menu",
                            fontSize: 24,
                            width: 250,
                            height: 65
                        ) {}
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
