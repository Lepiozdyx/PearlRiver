import SwiftUI

struct SoundButtonStyle: ButtonStyle {
    
    @StateObject private var settings = SettingsViewModel.shared
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { newValue in
                if newValue {
                    settings.play()
                }
            }
    }
}

extension Button {
    func withSound() -> some View {
        self.buttonStyle(SoundButtonStyle())
    }
}
