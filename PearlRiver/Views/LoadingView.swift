import SwiftUI

struct LoadingView: View {
    var body: some View {
        ZStack {
            Color.teal.ignoresSafeArea()
            
            VStack {
                Spacer()
                
                Image(.logo)
                    .resizable()
                    .scaledToFit()
                    .frame(height: 150)
                
                Text("Play the best games!")
                    .fontPRG(26)
                
                Spacer()
                
                HStack {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    
                    Text("Loading...")
                        .fontPRG(20)
                }
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    LoadingView()
}
