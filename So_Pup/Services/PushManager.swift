import FirebaseMessaging
import UIKit
import UserNotifications

final class PushManager: NSObject, ObservableObject, UNUserNotificationCenterDelegate, MessagingDelegate {
    
    @Published var pushToken: String? = nil
        
    static let shared = PushManager()

    func setupPush() {
        UNUserNotificationCenter.current().delegate = self
        Messaging.messaging().delegate = self

        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
            DispatchQueue.main.async {
                UIApplication.shared.registerForRemoteNotifications()
            }
        }
    }
    
    func getFCMToken() async -> String? {
        do {
            let token = try await Messaging.messaging().token()
            print("📲 Retrieved FCM token via PushManager: \(token)")
            return token
        } catch {
            print("❌ PushManager failed to get FCM token: \(error.localizedDescription)")
            return nil
        }
    }

    // called automatically by Firebase when:
    // - A new FCM token is issued (first install, app reinstall, or token refresh).
    // - The app launches and Firebase receives an APNs token from the system.
    func messaging(_ messaging: Messaging, didReceiveRegistrationToken fcmToken: String?) {
        print("📱 FCM Token: \(fcmToken ?? "nil")")
        self.pushToken = fcmToken // Store token
    }
}


