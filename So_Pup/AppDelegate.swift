//
//  Handles iOS system callbacks for APNs (Apple Push Notification Service)
//  registration and integrates them with Firebase Cloud Messaging (FCM).
//
//  Key Responsibilities:
//  - Receive the APNs device token after successful registration
//  - Pass the APNs token to Firebase Messaging so pushes can be delivered
//  - Log the APNs token in hex format for debugging
//  - Handle failures when APNs registration does not succeed
//
//  Usage:
//  Declared with @UIApplicationDelegateAdaptor in SoPupApp, so it is active
//  at app launch without a traditional AppDelegate file.
//
import UIKit
import FirebaseMessaging

class AppDelegate: NSObject, UIApplicationDelegate {
    func application(
        _ application: UIApplication,
        didRegisterForRemoteNotificationsWithDeviceToken deviceToken: Data
    ) {
        // Forward APNs token to Firebase Messaging
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
