import UIKit
import FirebaseMessaging

// App lifecycle config
// APNs token registration must be handled via the UIApplicationDelegate lifecycle
// and only Apple’s system calls those specific delegate methods.

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        Messaging.messaging().apnsToken = deviceToken
        print("✅ [AppDelegate] APNs token registered")
        print("📲 Received APNs token: \(deviceToken.map { String(format: "%02x", $0) }.joined())")
    }
    
    func application(
            _ application: UIApplication,
            didFailToRegisterForRemoteNotificationsWithError error: Error
        ) {
            print("❌ Failed to register for remote notifications: \(error.localizedDescription)")
        }
    
}
