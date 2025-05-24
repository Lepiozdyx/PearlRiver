import SwiftUI
import Combine

class ShopViewModel: ObservableObject {
    enum ShopTab {
        case skins
        case backgrounds
    }
    
    @Published var currentTab: ShopTab = .skins
    @Published var availableSkins: [PlayerSkinItem] = []
    @Published var availableBackgrounds: [BackgroundItem] = []
    
    weak var appViewModel: AppViewModel?
    
    init() {
        loadItems()
    }
    
    private func loadItems() {
        availableSkins = PlayerSkinItem.availableSkins
        availableBackgrounds = BackgroundItem.availableBackgrounds
    }
    
    // MARK: - Skins Methods (обновлено с instruments)
    func isSkinPurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "king_default" || gameState.purchasedSkins.contains(id)
    }
    
    func isSkinSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentSkinId == id
    }
    
    func purchaseSkin(_ id: String) {
        guard let appViewModel = appViewModel,
              let skin = PlayerSkinItem.availableSkins.first(where: { $0.id == id }),
              appViewModel.gameState.coins >= skin.price else { return }
        
        // Используем метод GameState для покупки
        if appViewModel.gameState.purchaseSkin(id, price: skin.price) {
            appViewModel.saveGameState()
            selectSkin(id)
        }
    }
    
    func selectSkin(_ id: String) {
        guard let appViewModel = appViewModel,
              isSkinPurchased(id) else { return }
        
        appViewModel.gameState.selectSkin(id)
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
    
    // MARK: - Backgrounds Methods
    func isBackgroundPurchased(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return id == "medieval_castle" || gameState.purchasedBackgrounds.contains(id)
    }
    
    func isBackgroundSelected(_ id: String) -> Bool {
        guard let gameState = appViewModel?.gameState else { return false }
        return gameState.currentBackgroundId == id
    }
    
    func purchaseBackground(_ id: String) {
        guard let appViewModel = appViewModel,
              let background = BackgroundItem.availableBackgrounds.first(where: { $0.id == id }),
              appViewModel.gameState.coins >= background.price else { return }
        
        // Используем метод GameState для покупки
        if appViewModel.gameState.purchaseBackground(id, price: background.price) {
            appViewModel.saveGameState()
            selectBackground(id)
        }
    }
    
    func selectBackground(_ id: String) {
        guard let appViewModel = appViewModel,
              isBackgroundPurchased(id) else { return }
        
        appViewModel.gameState.selectBackground(id)
        appViewModel.saveGameState()
        
        objectWillChange.send()
    }
}
