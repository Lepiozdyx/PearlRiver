import SwiftUI

class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        ScreenLockHelper.orientationMask = .landscape
        ScreenLockHelper.isAutoRotationEnabled = false
        
        if #available(iOS 14.0, *) {} else {
            let contentView = CustomHostingController(rootView: ContentView())
            window = UIWindow(frame: UIScreen.main.bounds)
            window?.rootViewController = contentView
            window?.makeKeyAndVisible()
        }
        
        return true
    }
}

@main
struct PearlRiverApp: App {
    
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate
    
    var body: some Scene {
        WindowGroup {
            ContentSourceView()
                .preferredColorScheme(.light)
        }
    }
}
