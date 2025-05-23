import SwiftUI
import Combine

class PalaceViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var buildings: [PalaceBuilding] = []
    @Published var selectedBuilding: PalaceBuilding?
    @Published var showBuildingDetail: Bool = false
    @Published var totalDailyGold: Int = 0
    @Published var totalDailyAmulets: Int = 0
    
    // MARK: - Properties
    weak var appViewModel: AppViewModel?
    
    // MARK: - Computed Properties
    var coins: Int {
        return appViewModel?.gameState.coins ?? 0
    }
    
    var amulets: Int {
        return appViewModel?.gameState.amulets ?? 0
    }
    
    // MARK: - Initialization
    init(appViewModel: AppViewModel) {
        self.appViewModel = appViewModel
        loadBuildings()
        calculateTotalIncome()
    }
    
    // MARK: - Methods
    func loadBuildings() {
        buildings = appViewModel?.gameState.palaceBuildings ?? []
    }
    
    func selectBuilding(_ building: PalaceBuilding) {
        selectedBuilding = building
        showBuildingDetail = true
    }
    
    func dismissBuildingDetail() {
        showBuildingDetail = false
        selectedBuilding = nil
    }
    
    func canUpgradeBuilding(_ building: PalaceBuilding) -> Bool {
        guard let goldCost = building.upgradeCostGold,
              let amuletCost = building.upgradeCostAmulets else {
            return false
        }
        
        return coins >= goldCost && amulets >= amuletCost
    }
    
    func upgradeBuilding(_ building: PalaceBuilding) {
        guard let appViewModel = appViewModel,
              canUpgradeBuilding(building) else { return }
        
        if appViewModel.upgradePalaceBuilding(building.id) {
            loadBuildings()
            calculateTotalIncome()
            
            // Обновляем выбранное здание
            if let updatedBuilding = buildings.first(where: { $0.id == building.id }) {
                selectedBuilding = updatedBuilding
            }
        }
    }
    
    private func calculateTotalIncome() {
        totalDailyGold = buildings.reduce(0) { $0 + $1.goldPerDay }
        totalDailyAmulets = buildings.reduce(0) { $0 + $1.amuletsPerDay }
    }
    
    // Получение позиции здания на экране
    func getBuildingPosition(for building: PalaceBuilding, in geometry: GeometryProxy) -> CGPoint {
        let x = building.type.position.x * geometry.size.width
        let y = building.type.position.y * geometry.size.height
        return CGPoint(x: x, y: y)
    }
}
