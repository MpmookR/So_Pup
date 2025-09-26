# 🐶 SoPup iOS Frontend

SoPup is an iOS mobile app built with SwiftUI and MVVM that helps dog owners connect, socialise, and manage their dogs responsibly.

## Features
- Dual modes: Puppy Mode and Social Mode
- Matchmaking and chat
- Meet-ups & reviews (Social Mode only)
- Firebase integration (Auth, Firestore, Messaging)

## Requirements
- Xcode 15+
- iOS 18.5+
- Swift 5.9+
- Firebase iOS SDKs (`Auth`, `Firestore`, `Storage`, `Messaging`)  

## Signing & Capabilities

The app requires specific **Signing & Capabilities** setup in Xcode.  

- **Team**: Puangpaka Rattana  
- **Bundle Identifier**: `MyK.SoPup`  
- **Signing**: Automatically managed  

### Enabled Capabilities
- **Remote notifications** (for push notifications via FCM)  
- **Maps** (Bike, Bus, Car, Subway, Taxi, Train, Ferry, Pedestrian routing options enabled)  
- **Sign in with Apple**  

### Apple Developer Account Notice
This project is configured with the Apple Developer account of **Puangpaka Rattana**.  
If you are **outside this team**, you may face signing and provisioning issues when trying to build or run the app.

To run under your own account:
1. Open the project in Xcode.  
2. Go to **Signing & Capabilities** for the `SoPup` target.  
3. Change the **Team** to your Apple Developer Team.  
4. Update the **Bundle Identifier** (e.g. `com.yourname.SoPup`).  
5. Ensure your Apple Developer membership supports the required capabilities (Push Notifications, Sign in with Apple, Maps).  

---

## Setup
1. Clone the repo:
   git clone https://github.com/MpmookR/So_Pup.git

2. Open the project in Xcode

3. Install dependencies (Firebase SDKs via Swift Package Manager or CocoaPods, depending on project setup).

4. Configure Firebase:
    - Add GoogleService-Info.plist into the project.
    - Ensure App Check, Firestore, and Authentication are enabled in your Firebase console.
    - Build and run on simulator or physical device.
    
🔗 Backend Integration
This frontend integrates with the SoPup Cloud Backend:
    - Backend README: https://github.com/MpmookR/SoPup_CloudFucntion
    - All API requests are routed via the deployed api function.


