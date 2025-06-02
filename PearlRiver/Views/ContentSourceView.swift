import SwiftUI

struct ContentSourceView: View {
    
    @StateObject private var state = AppStateViewModel()
    private var orientation = ScreenManager.shared
        
    var body: some View {
        Group {
            switch state.appState {
            case .fetch:
                LoadingView()
                
            case .supp:
                if let url = state.webManager.targetURL {
                    WebViewManager(url: url, webManager: state.webManager)
                        .onAppear {
                            orientation.unlockOrientation()
                        }
                    
                } else {
                    WebViewManager(url: NetworkManager.initialURL, webManager: state.webManager)
                        .onAppear {
                            orientation.unlockOrientation()
                        }
                }
                
            case .final:
                ContentView()
                    .preferredColorScheme(.light)
            }
        }
        .onAppear {
            state.stateCheck()
        }
    }
}

#Preview {
    ContentSourceView()
}
