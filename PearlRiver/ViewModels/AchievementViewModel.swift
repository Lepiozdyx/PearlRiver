import SwiftUI
import Combine

class AchievementViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var achievements: [Achievement] = []
    @Published var showClaimAnimation: Bool = false
    @Published var claimedAchievementId: String?
    
    // MARK: - Properties
    weak var appViewModel: AppViewModel?
    
    // MARK: - Computed Properties
    var completedAchievements: [String] {
        return appViewModel?.gameState.completedAchievements ?? []
    }
    
    var claimedAchievements: [String] {
        return appViewModel?.gameState.claimedAchievements ?? []
    }
    
    // MARK: - Initialization
    init(appViewModel: AppViewModel? = nil) {
        self.appViewModel = appViewModel
        loadAchievements()
    }
    
    // MARK: - Methods
    func loadAchievements() {
        achievements = Achievement.allAchievements
    }
    
    func isAchievementCompleted(_ achievementId: String) -> Bool {
        return completedAchievements.contains(achievementId)
    }
    
    func isAchievementClaimed(_ achievementId: String) -> Bool {
        return claimedAchievements.contains(achievementId)
    }
    
    func canClaimAchievement(_ achievementId: String) -> Bool {
        return isAchievementCompleted(achievementId) && !isAchievementClaimed(achievementId)
    }
    
    func claimAchievement(_ achievementId: String) {
        guard canClaimAchievement(achievementId),
              let appViewModel = appViewModel else { return }
        
        appViewModel.gameState.claimAchievement(achievementId)
        appViewModel.saveGameState()
        
        claimedAchievementId = achievementId
        showClaimAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { [weak self] in
            self?.showClaimAnimation = false
            self?.claimedAchievementId = nil
        }
    }
    
    func getAchievementProgress(_ achievement: Achievement) -> (current: Int, total: Int)? {
        guard let gameState = appViewModel?.gameState else { return nil }
        
        switch achievement.requirement {
        case .completeLevels(let count):
            return (gameState.levelsCompleted.count, count)
            
        case .collectCoins(let amount):
            return (gameState.totalCoinsCollected, amount)
            
        case .collectAmulets(let amount):
            return (gameState.totalAmuletsCollected, amount)
            
        case .completePuzzles(let count):
            return (gameState.puzzlesCompleted, count)
            
        case .upgradePalaceBuilding(let level):
            let maxLevel = gameState.palaceBuildings.map { $0.level }.max() ?? 0
            return (maxLevel, level)
            
        case .completeWithoutHits:
            return nil
        }
    }
    
    func checkAndCompleteAchievements() {
        guard let appViewModel = appViewModel else { return }
        let gameState = appViewModel.gameState
        
        for achievement in Achievement.allAchievements {
            if !gameState.completedAchievements.contains(achievement.id) {
                if achievement.requirement.isSatisfied(by: gameState) {
                    appViewModel.gameState.completeAchievement(achievement.id)
                }
            }
        }
        
        appViewModel.saveGameState()
    }
}
