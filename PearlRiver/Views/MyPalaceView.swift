import SwiftUI

struct MyPalaceView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var selectedBuilding: PalaceBuilding?
    @State private var showBuildingDetail = false
    @State private var buildingsAnimated = false
    
    var body: some View {
        ZStack {
            AppBGView(name: .bgPalace)
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 8) {
                        ScoreboardView(
                            amount: appViewModel.amulets,
                            width: 145,
                            height: 45,
                            isCoins: false
                        )
                        
                        ScoreboardView(
                            amount: appViewModel.coins,
                            width: 145,
                            height: 45
                        )
                    }
                }
                Spacer()
            }
            .padding()
            
            // Palace buildings
            ZStack {
                VStack {
                    HStack {
                        Spacer()
                        Spacer()
                        PalaceBuildingButton(
                            building: getBuildingById("healing_springs"),
                            imageName: .healingSprings,
                            size: CGSize(width: 110, height: 135),
                            isAnimated: buildingsAnimated
                        ) {
                            selectBuilding("healing_springs")
                        }
                        Spacer()
                        PalaceBuildingButton(
                            building: getBuildingById("temple_of_light"),
                            imageName: .templeOfLight,
                            size: CGSize(width: 110, height: 150),
                            isAnimated: buildingsAnimated
                        ) {
                            selectBuilding("temple_of_light")
                        }
                        .offset(y: 20)
                        Spacer()
                    }
                    Spacer()
                }
                
                HStack {
                    Spacer()
                    PalaceBuildingButton(
                        building: getBuildingById("grand_arena"),
                        imageName: .grandArena,
                        size: CGSize(width: 120, height: 120),
                        isAnimated: buildingsAnimated
                    ) {
                        selectBuilding("grand_arena")
                    }
                    Spacer()
                    PalaceBuildingButton(
                        building: getBuildingById("kings_keep"),
                        imageName: .kingsKeep,
                        size: CGSize(width: 115, height: 160),
                        isAnimated: buildingsAnimated
                    ) {
                        selectBuilding("kings_keep")
                    }
                    Spacer()
                    Spacer()
                    Spacer()
                }
                
                VStack {
                    Spacer()
                    HStack {
                        PalaceBuildingButton(
                            building: getBuildingById("royal_barracks"),
                            imageName: .royalBarracks,
                            size: CGSize(width: 110, height: 130),
                            isAnimated: buildingsAnimated
                        ) {
                            selectBuilding("royal_barracks")
                        }
                        Spacer()
                    }
                }
            }
            .padding()
            .onAppear {
                withAnimation(.easeOut(duration: 0.6).delay(0.2)) {
                    buildingsAnimated = true
                }
            }
            
            // Building detail
            if showBuildingDetail, let building = selectedBuilding {
                BuildingDetailView(
                    building: building,
                    onUpgrade: { buildingId in
                        upgradeBuilding(buildingId)
                    },
                    onClose: {
                        closeBuildingDetail()
                    }
                )
                .transition(.scale.combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: showBuildingDetail)
    }
    
    // MARK: - Methods
    
    private func getBuildingById(_ id: String) -> PalaceBuilding? {
        return appViewModel.gameState.palaceBuildings.first { $0.id == id }
    }
    
    private func selectBuilding(_ buildingId: String) {
        guard let building = getBuildingById(buildingId) else { return }
        
        svm.play()
        selectedBuilding = building
        showBuildingDetail = true
    }
    
    private func upgradeBuilding(_ buildingId: String) {
        let success = appViewModel.upgradePalaceBuilding(buildingId)
        
        if success {
            selectedBuilding = getBuildingById(buildingId)
            svm.play()
        }
    }
    
    private func closeBuildingDetail() {
        showBuildingDetail = false
        selectedBuilding = nil
    }
}

// MARK: - Palace Building Button
struct PalaceBuildingButton: View {
    let building: PalaceBuilding?
    let imageName: ImageResource
    let size: CGSize
    let isAnimated: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            VStack(spacing: 4) {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .frame(height: size.height)
                    .overlay(alignment: .bottomTrailing) {
                        if let building = building {
                            Image(.amulet)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 30)
                                .shadow(color: .black, radius: 3)
                                .background() {
                                    Text("\(building.level)")
                                        .fontPRG(16)
                                        .offset(y: -2)
                                }
                        }
                    }
            }
        }
        .buttonStyle(.plain)
        .scaleEffect(isAnimated ? 1.0 : 0.8)
        .opacity(isAnimated ? 1.0 : 0)
    }
}

#Preview {
    MyPalaceView()
        .environmentObject(AppViewModel())
}
