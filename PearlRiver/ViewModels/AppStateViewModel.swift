import Foundation

@MainActor
final class AppStateViewModel: ObservableObject {
    
    @Published private(set) var appState: AppStates = .fetch
    
    let webManager: NetworkManager
    
    init(webManager: NetworkManager = NetworkManager()) {
        self.webManager = webManager
    }
    
    func fetchState() {
        Task {
            if webManager.supportURL != nil {
                appState = .support
                return
            }
            
            do {
                if try await webManager.checkInitialURL() {
                    appState = .support
                } else {
                    appState = .app
                }
            } catch {
                appState = .app
            }
        }
    }
}
