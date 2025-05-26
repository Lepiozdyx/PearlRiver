import SwiftUI

struct ScoreboardView: View {
    let amount: Int
    let width: CGFloat
    let height: CGFloat
    
    var isCoins: Bool = true
    
    var body: some View {
        Image(.buttonRect)
            .resizable()
            .frame(maxWidth: width, maxHeight: height)
            .overlay(alignment: .leading) {
                Image(isCoins ? .coin : .amulet)
                    .resizable()
                    .scaledToFit()
                    .frame(height: height * 0.8)
                    .padding(.leading)
                    .offset(y: 5)
            }
            .overlay {
                Text("\(amount)")
                    .fontPRG(22)
                    .offset(x: 20, y: 2)
            }
    }
}

#Preview {
    ScoreboardView(amount: 1999, width: 150, height: 60, isCoins: false)
}
