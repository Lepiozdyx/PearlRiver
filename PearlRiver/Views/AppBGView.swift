import SwiftUI

struct AppBGView: View {
    var body: some View {
        Image(.bgMain)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    AppBGView()
}
