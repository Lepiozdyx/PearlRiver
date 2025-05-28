import SwiftUI

struct BuildingDetailView: View {
    let building: PalaceBuilding
    let onUpgrade: (String) -> Void
    let onClose: () -> Void
    
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var showContent = false
    @State private var upgradeButtonScale: CGFloat = 1.0
    
    var canAffordUpgrade: Bool {
        guard building.canUpgrade else { return false }
        return appViewModel.coins >= building.upgradeCostGold &&
               appViewModel.amulets >= building.upgradeCostAmulets
    }
    
    var body: some View {
        ZStack {
            Color.black.opacity(0.7)
                .ignoresSafeArea()
                .onTapGesture {
                    svm.play()
                    onClose()
                }
            
            // Main content
            HStack(spacing: 8) {
                // Left side - Building basic info
                VStack(spacing: 8) {
                    Text(building.name)
                        .fontPRG(20)
                    
                    Text("Level: \(building.level)")
                        .fontPRG(16)
                    
                    Text(building.description)
                        .fontPRG(10)
                }
                .frame(width: 160)
                
                // Right side - Details and upgrade info
                VStack(spacing: 16) {
                    // Current income
                    VStack(spacing: 8) {
                        Text("Daily Income:")
                            .fontPRG(14)
                        
                        HStack(spacing: 10) {
                            // Gold income
                            HStack(spacing: 2) {
                                Image(.coin)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                                Text("\(building.goldPerDay)/day")
                                    .fontPRG(12)
                            }
                            
                            // Amulets income
                            HStack(spacing: 2) {
                                Image(.amulet)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 20)
                                
                                Text("\(building.amuletsPerDay)/day")
                                    .fontPRG(12)
                            }
                        }
                    }
                    
                    // Upgrade section
                    if building.canUpgrade {
                        VStack(spacing: 8) {
                            Text("Upgrade to Level \(building.level + 1)")
                                .fontPRG(16)
                            
                            HStack(spacing: 20) {
                                // Upgrade cost
                                VStack(spacing: 5) {
                                    Text("Cost:")
                                        .fontPRG(12)
                                    
                                    HStack(spacing: 10) {
                                        // Coin cost
                                        HStack(spacing: 2) {
                                            Image(.coin)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 16)
                                            
                                            Text("\(building.upgradeCostGold)")
                                                .fontPRG(11)
                                                .foregroundColor(
                                                    appViewModel.coins >= building.upgradeCostGold
                                                    ? .white : .red
                                                )
                                        }
                                        
                                        // Amulets cost
                                        HStack(spacing: 2) {
                                            Image(.amulet)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 16)
                                            
                                            Text("\(building.upgradeCostAmulets)")
                                                .fontPRG(11)
                                                .colorMultiply(
                                                    appViewModel.amulets >= building.upgradeCostAmulets
                                                    ? .white : .red
                                                )
                                        }
                                    }
                                }
                                
                                // Next level benefits
                                VStack(spacing: 5) {
                                    Text("New Income:")
                                        .fontPRG(12)
                                    
                                    HStack(spacing: 10) {
                                        // Next level gold income
                                        HStack(spacing: 2) {
                                            Image(.coin)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 16)
                                            
                                            Text("\(building.nextLevelGoldPerDay)/day")
                                                .fontPRG(11)
                                        }
                                        
                                        // Next level amulets income
                                        HStack(spacing: 2) {
                                            Image(.amulet)
                                                .resizable()
                                                .scaledToFit()
                                                .frame(height: 16)
                                            
                                            Text("\(building.nextLevelAmuletsPerDay)/day")
                                                .fontPRG(11)
                                        }
                                    }
                                }
                            }
                        }
                    } else {
                        Text("MAX LEVEL REACHED")
                            .fontPRG(16)
                    }
                    
                    // Action buttons
                    HStack(spacing: 15) {
                        // Close button
                        ActionButtonView(
                            title: "Close",
                            fontSize: 16,
                            width: 100,
                            height: 45
                        ) {
                            svm.play()
                            onClose()
                        }
                        
                        // Upgrade button
                        if building.canUpgrade {
                            Button {
                                if canAffordUpgrade {
                                    svm.play()
                                    onUpgrade(building.id)
                                }
                            } label: {
                                Image(.buttonRect)
                                    .resizable()
                                    .frame(width: 100, height: 45)
                                    .overlay {
                                        Text("Upgrade")
                                            .fontPRG(16)
                                            .offset(y: 2)
                                    }
                                    .opacity(canAffordUpgrade ? 1.0 : 0.6)
                                    .scaleEffect(upgradeButtonScale)
                                    .animation(
                                        canAffordUpgrade && building.canUpgrade
                                        ? Animation.easeInOut(duration: 1.0)
                                            .repeatForever(autoreverses: true)
                                        : .default,
                                        value: upgradeButtonScale
                                    )
                            }
                            .disabled(!canAffordUpgrade)
                        }
                    }
                }
                .frame(width: 350)
            }
            .frame(width: 600, height: 350)
            .background(
                Image(.underlay)
                    .resizable()
            )
            .scaleEffect(showContent ? 1.0 : 0.8)
            .opacity(showContent ? 1.0 : 0)
        }
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                showContent = true
            }
            
            if canAffordUpgrade && building.canUpgrade {
                upgradeButtonScale = 1.05
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func getBuildingImageName() -> String {
        switch building.id {
        case "kings_keep": return "kingsKeep"
        case "royal_barracks": return "royalBarracks"
        case "temple_of_light": return "templeOfLight"
        case "grand_arena": return "grandArena"
        case "healing_springs": return "healingSprings"
        default: return "kingsKeep"
        }
    }
}

#Preview {
    BuildingDetailView(
        building: PalaceBuilding.defaultBuildings()[0],
        onUpgrade: { _ in },
        onClose: { }
    )
    .environmentObject(AppViewModel())
}
