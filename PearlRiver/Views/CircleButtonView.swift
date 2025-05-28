import SwiftUI

struct CircleButtonView: View {
    let icon: String
    let height: CGFloat
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(.buttonCircle)
                .resizable()
                .scaledToFit()
                .frame(height: height)
                .overlay {
                    Image(systemName: icon)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 35)
                        .foregroundStyle(.white)
                        .padding()
                }
        }
    }
}

#Preview {
    CircleButtonView(icon: "arrow.left", height: 60, action: {})
}
