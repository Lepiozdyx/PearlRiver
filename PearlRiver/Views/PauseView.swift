import SwiftUI

struct PauseView: View {
    
    @EnvironmentObject private var appViewModel: AppViewModel
    @State private var isProcessingAction = false
    
    var body: some View {
        ZStack {
            // Затемнение всего экрана
            Color.black.opacity(0.6)
                .ignoresSafeArea()
            
            VStack(spacing: 10) {
                Image(.underlay)
                    .resizable()
                    .frame(width: 150, height: 65)
                    .overlay {
                        Text("Pause")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                // Continue button
                ActionButtonView(title: "Continue", fontSize: 24, width: 250, height: 65) {
                    appViewModel.resumeGame()
                }
                
                // Restart button
                ActionButtonView(title: "Restart", fontSize: 24, width: 250, height: 65) {
                    guard !isProcessingAction else { return }
                    isProcessingAction = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appViewModel.restartLevel()
                    }
                }
                .opacity(isProcessingAction ? 0.7 : 1.0)
                
                // Menu button
                ActionButtonView(title: "Menu", fontSize: 24, width: 250, height: 65) {
                    guard !isProcessingAction else { return }
                    isProcessingAction = true
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                        appViewModel.navigateTo(.menu)
                    }
                }
                .opacity(isProcessingAction ? 0.5 : 1.0)
            }
        }
    }
}

#Preview {
    PauseView()
        .environmentObject(AppViewModel())
}
