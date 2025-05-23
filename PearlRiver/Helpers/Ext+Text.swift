import SwiftUI

struct Extension_Text: View {
    var body: some View {
        Text("Font")
            .myFont(32)
    }
}

extension Text {
    func myFont(_ size: CGFloat) -> some View {
        self
            .font(.system(size: size, weight: .regular, design: .serif))
            .foregroundStyle(.white)
            .shadow(color: .black, radius: 0.5, x: 0.5, y: 0.5)
            .multilineTextAlignment(.center)
            .textCase(.uppercase)
    }
}

#Preview {
    Extension_Text()
}
