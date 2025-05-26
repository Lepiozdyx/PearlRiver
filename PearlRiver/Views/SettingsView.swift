import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var appViewModel: AppViewModel
    @StateObject private var svm = SettingsViewModel.shared
    
    var body: some View {
        ZStack {
            AppBGView()
            
            VStack {
                // Header with back button and currency
                HStack(alignment: .top) {
                    CircleButtonView(icon: "arrowshape.backward.fill", height: 65) {
                        svm.play()
                        appViewModel.navigateTo(.menu)
                    }
                    
                    Spacer()
                }
                Spacer()
            }
            .padding()
            
            VStack {
                // Title
                Image(.buttonRect)
                    .resizable()
                    .frame(width: 250, height: 100)
                    .overlay {
                        Text("Settings")
                            .fontPRG(24)
                            .offset(y: 2)
                    }
                
                Spacer()
                
                VStack(spacing: 20) {
                    HStack(spacing: 60) {
                        SettingRow(
                            title: "Sound",
                            isOn: svm.soundIsOn,
                            action: {
                                svm.toggleSound()
                            }
                        )
                        
                        SettingRow(
                            title: "Music",
                            isOn: svm.musicIsOn,
                            isDisabled: !svm.soundIsOn,
                            action: {
                                svm.toggleMusic()
                            }
                        )
                    }
                    
                    VStack(spacing: 10) {
                        Text("Language")
                            .fontPRG(18)
                        
                        Image(.flag)
                            .resizable()
                            .scaledToFit()
                            .frame(height: 35)
                            .overlay(
                                Circle()
                                    .stroke(.white, lineWidth: 0.5)
                            )
                    }
                }
                .frame(width: 350)
                .padding(40)
                .background(
                    Image(.underlay)
                        .resizable()
                )
                
                Spacer()
            }
            .padding()
        }
    }
}

#Preview {
    SettingsView()
        .environmentObject(AppViewModel())
}

// MARK: - Subviews
struct SettingRow: View {
    let title: String
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            Text(title)
                .fontPRG(18)
            
            ToggleButtonView(isOn: isOn, isDisabled: isDisabled, action: action)
        }
    }
}

struct ToggleButtonView: View {
    let isOn: Bool
    var isDisabled: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            ZStack {
                Capsule()
                    .fill(isOn ? .yellow.opacity(0.8) : .yellow.opacity(0.5))
                    .frame(width: 75, height: 35)
                    .overlay(
                        Capsule()
                            .stroke(.white, lineWidth: 0.5)
                    )
                    .opacity(isDisabled ? 0.5 : 1.0)
                
                Capsule()
                    .fill(.yellow)
                    .frame(width: 38, height: 30)
                    .shadow(radius: 1, x: 1, y: 1)
                    .overlay {
                        Text(isOn ? "On" : "Off")
                            .fontPRG(14)
                    }
                    .overlay(
                        Capsule()
                            .stroke(.white, lineWidth: 0.5)
                    )
                    .offset(x: isOn ? 15 : -15)
                    .animation(.spring(response: 0.2, dampingFraction: 0.7), value: isOn)
                    .opacity(isDisabled ? 0.5 : 1.0)
            }
        }
        .buttonStyle(.plain)
        .disabled(isDisabled)
    }
}
