import SwiftUI
import FirebaseAuth

struct ContentView: View {
    @StateObject private var authViewModel = AuthViewModel()
    
    var body: some View {
        VStack(spacing: 8) {
            Text("SoPup!")
                .font(.title)

            // Apple Sign-In Button
//            AppleSignInButtonView()
//                .environmentObject(authViewModel)
//            
//            // Google Sign-In Button
//            GoogleSignInButtonView()
//                .environmentObject(authViewModel)
//
//            // Show error if any
//            if let error = authViewModel.errorMessage {
//                Text(error)
//                    .foregroundColor(.red)
//                    .multilineTextAlignment(.center)
//                    .padding()
//            }
//
//            // Success message
//            if authViewModel.isLoggedIn {
//                Text("✅ Signed in successfully")
//                    .foregroundColor(.green)
//            }
        }
        .padding()
//        .onAppear {
//            if let user = Auth.auth().currentUser {
//                print("✅ Firebase connected: signed in as \(user.uid)")
//            } else {
//                print("✅ Firebase connected: no user signed in")
//            }
//        }
    }
}

#Preview {
    ContentView()
}
