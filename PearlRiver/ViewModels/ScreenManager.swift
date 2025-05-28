import SwiftUI

class ScreenManager {
    
    static let shared = ScreenManager()
    
    private init() {}
    
    func unlockOrientation() {
        ScreenLockHelper.orientationMask = .all
        ScreenLockHelper.isAutoRotationEnabled = true
        UIViewController.attemptRotationToDeviceOrientation()
    }
    
    func lockLandscape() {
        ScreenLockHelper.orientationMask = .landscape
        ScreenLockHelper.isAutoRotationEnabled = false
        
        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            if windowScene.interfaceOrientation.isPortrait {
                ScreenLockHelper.isAutoRotationEnabled = true
                UIViewController.attemptRotationToDeviceOrientation()
                
                if #available(iOS 16.0, *) {
                    windowScene.requestGeometryUpdate(.iOS(interfaceOrientations: .landscapeRight))
                } else {
                    UIDevice.current.setValue(UIDeviceOrientation.landscapeRight.rawValue, forKey: "orientation")
                }
                
                ScreenLockHelper.isAutoRotationEnabled = false
            }
        }
    }
}

class ScreenLockHelper {
    public static var orientationMask: UIInterfaceOrientationMask = .landscapeLeft
    public static var isAutoRotationEnabled: Bool = false
}

class CustomHostingController<Content: View>: UIHostingController<Content> {
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return ScreenLockHelper.orientationMask
    }

    override var shouldAutorotate: Bool {
        return ScreenLockHelper.isAutoRotationEnabled
    }
}
