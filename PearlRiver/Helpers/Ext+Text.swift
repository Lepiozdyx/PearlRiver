import SwiftUI

extension Text {
    func fontPRG(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .regular, design: .serif))
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}
