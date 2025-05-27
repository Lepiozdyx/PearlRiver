import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            // Main navigation
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                
            case .levelSelect:
                LvLSelectionView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                
            case .myPalace:
                MyPalaceView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                
            case .achievements:
                AchievementView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                
            case .daily:
                DailyRewardView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.currentScreen)
        .onAppear {
            setupApp()
        }
        .onChange(of: phase) { newPhase in
            handleScenePhaseChange(newPhase)
        }
    }
    
    private func setupApp() {
        // Update palace income on app launch
        appViewModel.updatePalaceIncome()
        
        // Start music if enabled
        if settings.musicIsOn && settings.soundIsOn {
            settings.playMusic()
        }
    }
    
    private func handleScenePhaseChange(_ newPhase: ScenePhase) {
        switch newPhase {
        case .active:
            appViewModel.updatePalaceIncome()
            settings.playMusic()
            
        case .background:
            settings.stopMusic()
            
            // Pause game if active (как в Oneida)
            if appViewModel.currentScreen == .game {
                appViewModel.pauseGame()
            }
            
            appViewModel.saveGameState()
            
        case .inactive:
            settings.stopMusic()
            
            // Pause game if active
            if appViewModel.currentScreen == .game {
                appViewModel.pauseGame()
            }
            
        @unknown default:
            break
        }
    }
}

#Preview {
    ContentView()
}
