import SwiftUI

struct MiniGamesMenuView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    @State private var gridOpacity: Double = 0
    @State private var gridOffset: CGFloat = 20
    
    let columns = Array(repeating: GridItem(.flexible()), count: 2)
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                HStack(alignment: .top) {
                    CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
             
            VStack {
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 80)
                    .overlay {
                        Text("Mini games")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                Spacer()
                
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(MiniGameType.allCases) { gameType in
                        MiniGameItemView(gameType: gameType) {
                            appViewModel.startMiniGame(gameType)
                        }
                    }
                }
                .frame(maxWidth: 550)
                .opacity(gridOpacity)
                .offset(y: gridOffset)
                
                Spacer()
            }
            .padding()
            .onAppear {
                withAnimation(.easeOut(duration: 0.5).delay(0.3)) {
                    gridOpacity = 1.0
                    gridOffset = 0
                }
            }
        }
    }
}

struct MiniGameItemView: View {
    let gameType: MiniGameType
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(gameType.title)
                .fontPRG(20)
                .frame(maxWidth: 150, maxHeight: 100)
                .padding()
                .background(
                    Image(.buttonRect)
                        .resizable()
                )
        }
    }
}

#Preview {
    MiniGamesMenuView()
        .environmentObject(AppViewModel())
}
