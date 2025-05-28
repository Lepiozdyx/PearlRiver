import SwiftUI

struct ContentView: View {
    @StateObject private var appViewModel = AppViewModel()
    @StateObject private var settings = SettingsViewModel.shared
    
    @Environment(\.scenePhase) private var phase
    
    var body: some View {
        ZStack {
            switch appViewModel.currentScreen {
            case .menu:
                MenuView()
                    .environmentObject(appViewModel)
                    .transition(.opacity)
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .levelSelect:
                LvLSelectionView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .game:
                GameView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .myPalace:
                MyPalaceView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                
            case .settings:
                SettingsView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .shop:
                ShopView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .achievements:
                AchievementView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .daily:
                DailyRewardView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            // MARK: Mini-games
                
            case .minigamesMenu:
                MiniGamesMenuView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .trailing))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .memory:
                MemoryGameView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .guess:
                GuessGameView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .sequence:
                SequenceGameView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
                
            case .maze:
                MazeGameView()
                    .environmentObject(appViewModel)
                    .transition(.move(edge: .bottom))
                    .onAppear {
                        ScreenManager.shared.lockLandscape()
                    }
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
        appViewModel.updatePalaceIncome()
        
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
            
            if appViewModel.currentScreen == .game {
                appViewModel.pauseGame()
            }
            
            appViewModel.saveGameState()
            
        case .inactive:
            settings.stopMusic()
            
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
