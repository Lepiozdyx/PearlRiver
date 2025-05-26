import SwiftUI

struct AppBGView: View {
    
    var name: ImageResource = .bgMain
    
    var body: some View {
        Image(name)
            .resizable()
            .ignoresSafeArea()
    }
}

#Preview {
    AppBGView()
}
