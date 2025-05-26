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
                Text("My Palace View - Coming Soon")
                    .fontPRG(24)
                    .transition(.move(edge: .trailing))
                
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
                Text("Daily Reward View - Coming Soon")
                    .transition(.move(edge: .trailing))
            }
            
            // Puzzle game overlay - shown on top of game screen
            if appViewModel.showPuzzleGame {
                PuzzleGameView { success in
                    appViewModel.completePuzzleGame(success: success)
                }
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appViewModel.currentScreen)
        .animation(.easeInOut(duration: 0.3), value: appViewModel.showPuzzleGame)
        .onAppear {
            // Update palace income on app launch
            appViewModel.updatePalaceIncome()
            
            // Start music if enabled
            if settings.musicIsOn {
                settings.playMusic()
            }
        }
        .onChange(of: phase) { newPhase in
            switch newPhase {
            case .active:
                // Update palace income when app becomes active
                appViewModel.updatePalaceIncome()
                settings.playMusic()
                
            case .background:
                settings.stopMusic()
                // Save game state when going to background
                appViewModel.saveGameState()
                
            case .inactive:
                settings.stopMusic()
                
            @unknown default:
                break
            }
        }
    }
}

#Preview {
    ContentView()
}
