import SwiftUI

struct ShopView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var viewModel = ShopViewModel()
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var contentOpacity: Double = 0
    @State private var contentOffset: CGFloat = 20
    
    private let columns = Array(repeating: GridItem(.flexible()), count: 4)
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                // Header with back button and currency
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
            
            VStack {
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 80)
                    .overlay {
                        Text("Shop")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                Spacer()
                
                SelectorTabView(
                    selectedTab: $viewModel.currentTab
                )
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                // Shop items grid
                VStack {
                    LazyVGrid(columns: columns, spacing: 15) {
                        if viewModel.currentTab == .skins {
                            ForEach(viewModel.availableSkins) { skin in
                                ShopItemView(
                                    itemType: .player,
                                    imageName: skin.imageName,
                                    name: skin.name,
                                    price: skin.price,
                                    isPurchased: viewModel.isSkinPurchased(skin.id),
                                    isSelected: viewModel.isSkinSelected(skin.id),
                                    canAfford: appViewModel.coins >= skin.price,
                                    onBuy: {
                                        viewModel.purchaseSkin(skin.id)
                                    },
                                    onSelect: {
                                        viewModel.selectSkin(skin.id)
                                    }
                                )
                            }
                        } else {
                            ForEach(viewModel.availableBackgrounds) { background in
                                ShopItemView(
                                    itemType: .background,
                                    imageName: background.imageName,
                                    name: background.name,
                                    price: background.price,
                                    isPurchased: viewModel.isBackgroundPurchased(background.id),
                                    isSelected: viewModel.isBackgroundSelected(background.id),
                                    canAfford: appViewModel.coins >= background.price,
                                    onBuy: {
                                        viewModel.purchaseBackground(background.id)
                                    },
                                    onSelect: {
                                        viewModel.selectBackground(background.id)
                                    }
                                )
                            }
                        }
                    }
                }
                .frame(maxWidth: 500)
                .opacity(contentOpacity)
                .offset(y: contentOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                viewModel.appViewModel = appViewModel
                
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    contentOpacity = 1.0
                    contentOffset = 0
                }
            }
        }
    }
}

#Preview {
    ShopView()
        .environmentObject(AppViewModel())
}

// MARK: - Subviews
struct SelectorTabView: View {
    
    @Binding var selectedTab: ShopViewModel.ShopTab
    
    var body: some View {
        HStack(spacing: 20) {
            SelectorTabButton(
                title: "Skin",
                isSelected: selectedTab == .skins,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .skins
                    }
                }
            )
            
            SelectorTabButton(
                title: "Location",
                isSelected: selectedTab == .backgrounds,
                action: {
                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                        selectedTab = .backgrounds
                    }
                }
            )
        }
    }
}

// Tab button
struct SelectorTabButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.buttonRect)
                .resizable()
                .frame(width: 125, height: 45)
                .overlay(
                    Text(title)
                        .fontPRG(16)
                )
                .scaleEffect(isSelected ? 1.0 : 0.8)
        }
    }
}

// Shop item view
struct ShopItemView: View {
    
    enum ShopItemType {
        case player
        case background
    }
    
    let itemType: ShopItemType
    let imageName: String
    let name: String
    let price: Int
    let isPurchased: Bool
    let isSelected: Bool
    let canAfford: Bool
    let onBuy: () -> Void
    let onSelect: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Item image
            Image(.underlay)
                .resizable()
                .frame(maxWidth: 130, maxHeight: 160)
                .overlay {
                    Image(getPreview())
                        .resizable()
                        .scaledToFit()
                        .scaleEffect(isAnimating ? 1.05 : 1.0)
                        .animation(
                            Animation.easeInOut(duration: 1.5)
                                .repeatForever(autoreverses: true),
                            value: isAnimating
                        )
                        .onAppear {
                            isAnimating = true
                        }
                        .padding(20)
                }
            
            // Buy/select button
            Button {
                if isPurchased {
                    if !isSelected {
                        onSelect()
                    }
                } else if canAfford {
                    onBuy()
                }
            } label: {
                Image(.buttonRect)
                    .resizable()
                    .frame(maxWidth: 130, maxHeight: 40)
                    .overlay {
                        if isPurchased {
                            Text(isSelected ? "Selected" : "Select")
                                .fontPRG(14)
                                .offset(y: 2)
                        } else {
                            HStack(spacing: 4) {
                                Image(.coin)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(height: 25)
                                
                                Text("\(price)")
                                    .fontPRG(14)
                            }
                            .offset(y: 2)
                        }
                    }
            }
            .disabled((isPurchased && isSelected) || (!isPurchased && !canAfford))
            .opacity((isPurchased && isSelected) || (!isPurchased && !canAfford) ? 0.6 : 1)
        }
    }
    
    private func getPreview() -> String {
        switch itemType {
        case .player:
            if imageName.contains("player_king") {
                return "player_king"
            } else if imageName.contains("player_2king") {
                return "player_2king"
            } else if imageName.contains("player_knight") {
                return "player_knight"
            } else if imageName.contains("player_queen") {
                return "player_queen"
            } else {
                return "player_king"
            }
        case .background:
            if imageName.contains("bg_medieval_castle") {
                return "bg_medieval_castle_preview"
            } else if imageName.contains("bg_royal_palace") {
                return "bg_royal_palace_preview"
            } else if imageName.contains("bg_ancient_temple") {
                return "bg_ancient_temple_preview"
            } else if imageName.contains("bg_old_chambers") {
                return "bg_old_chambers_preview"
            } else {
                return "bg_medieval_castle_preview"
            }
        }
    }
}
