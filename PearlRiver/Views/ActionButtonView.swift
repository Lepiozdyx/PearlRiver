import SwiftUI

struct ActionButtonView: View {
    var buttonImage: ImageResource = .buttonRect
    let title: String
    let fontSize: CGFloat
    let width: CGFloat
    let height: CGFloat
    let action: () -> ()
    
    var body: some View {
        Button {
            action()
        } label: {
            Image(buttonImage)
                .resizable()
                .frame(maxWidth: width, maxHeight: height)
                .overlay {
                    Text(title)
                        .fontPRG(fontSize)
                        .offset(y: 2)
                        .padding(.horizontal)
                }
        }
    }
}

#Preview {
    ActionButtonView(title: "Play", fontSize: 32, width: 220, height: 80) {}
}
