import SwiftUI

// MARK: - App (@main);
@main
struct NFCReaderApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var appDelegate

    var body: some Scene {
        WindowGroup {
            SplashScreen()
        }
    }
}

class AppDelegate: UIResponder, UIApplicationDelegate {
    
}
