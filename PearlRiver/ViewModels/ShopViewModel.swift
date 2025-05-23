import SwiftUI
import Combine

class ShopViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var currentTab: ShopItemType = .background
    @Published var backgrounds: [BackgroundItem] = []
    @Published var skins: [PlayerSkinItem] = []
    @Published var showPurchaseAlert: Bool = false
    @Published var purchaseAlertMessage: String = ""
    
    // MARK: - Properties
    weak var appViewModel: AppViewModel?
    
    // MARK: - Computed Properties
    var coins: Int {
        return appViewModel?.gameState.coins ?? 0
    }
    
    var purchasedBackgrounds: [String] {
        return appViewModel?.gameState.purchasedBackgrounds ?? []
    }
    
    var purchasedSkins: [String] {
        return appViewModel?.gameState.purchasedSkins ?? []
    }
    
    var currentBackgroundId: String {
        return appViewModel?.gameState.currentBackgroundId ?? "medieval_castle"
    }
    
    var currentSkinId: String {
        return appViewModel?.gameState.currentSkinId ?? "king_default"
    }
    
    // MARK: - Initialization
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        loadItems()
    }
    
    // MARK: - Methods
    func loadItems() {
        backgrounds = BackgroundItem.availableBackgrounds
        skins = PlayerSkinItem.availableSkins
    }
    
    func isBackgroundPurchased(_ backgroundId: String) -> Bool {
        return purchasedBackgrounds.contains(backgroundId)
    }
    
    func isSkinPurchased(_ skinId: String) -> Bool {
        return purchasedSkins.contains(skinId)
    }
    
    func isBackgroundSelected(_ backgroundId: String) -> Bool {
        return currentBackgroundId == backgroundId
    }
    
    func isSkinSelected(_ skinId: String) -> Bool {
        return currentSkinId == skinId
    }
    
    func canPurchaseItem(price: Int) -> Bool {
        return coins >= price
    }
    
    // MARK: - Actions
    func purchaseBackground(_ background: BackgroundItem) {
        guard let appViewModel = appViewModel else { return }
        
        if !canPurchaseItem(price: background.price) {
            showInsufficientFundsAlert()
            return
        }
        
        if appViewModel.purchaseBackground(background.id) {
            showSuccessAlert(itemName: background.name)
        }
    }
    
    func purchaseSkin(_ skin: PlayerSkinItem) {
        guard let appViewModel = appViewModel else { return }
        
        if !canPurchaseItem(price: skin.price) {
            showInsufficientFundsAlert()
            return
        }
        
        if appViewModel.purchaseSkin(skin.id) {
            showSuccessAlert(itemName: skin.name)
        }
    }
    
    func selectBackground(_ backgroundId: String) {
        appViewModel?.selectBackground(backgroundId)
    }
    
    func selectSkin(_ skinId: String) {
        appViewModel?.selectSkin(skinId)
    }
    
    // MARK: - Alerts
    private func showInsufficientFundsAlert() {
        purchaseAlertMessage = "Not enough coins! You need more coins to purchase this item."
        showPurchaseAlert = true
    }
    
    private func showSuccessAlert(itemName: String) {
        purchaseAlertMessage = "Successfully purchased \(itemName)!"
        showPurchaseAlert = true
    }
}
