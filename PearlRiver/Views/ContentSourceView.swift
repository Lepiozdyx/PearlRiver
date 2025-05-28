import SwiftUI

struct ContentSourceView: View {
    
    @StateObject private var state = AppStateViewModel()
    
    var body: some View {
        Group {
            switch state.appState {
            case .fetch:
                LoadingView()
            case .support:
                if let url = state.webManager.supportURL {
                    WebViewManager(url: url, webManager: state.webManager)
                        .onAppear {
                            ScreenManager.shared.unlockOrientation()
                        }
                } else {
                    WebViewManager(url: NetworkManager.initURL, webManager: state.webManager)
                        .onAppear {
                            ScreenManager.shared.unlockOrientation()
                        }
                }
            case .app:
                ContentView()
            }
        }
        .onAppear {
            state.fetchState()
        }
    }
}

#Preview {
    ContentSourceView()
}
