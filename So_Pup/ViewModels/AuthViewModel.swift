import Foundation
import UIKit
import FirebaseAuth
import FirebaseFirestore

//@MainActor tells compiler to run all code in this class on the main thread to safely update UI-related
@MainActor
class AuthViewModel: ObservableObject {
    
    @Published var email = ""
    @Published var password = ""
    @Published var errorMessage: String?
    @Published var isLoading = false
    @Published var isLoggedIn = false
    @Published var hasCompletedOnboarding = false
    
    private let db = Firestore.firestore()
    
    // MARK: - Initializer
    /// Initialize login state based on current Firebase session
    init (){
        self.isLoggedIn = Auth.auth().currentUser != nil
        if isLoggedIn {
            Task {
                await fetchOnboardingStatus()
            }
        }
    }
    
    // MARK: - Authentication Methods
    /// Sign in with email and password using FirebaseService
    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await FirebaseService.shared.signIn(email: email, password: password)
            isLoggedIn = true
            await fetchOnboardingStatus()

        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    /// Register a new user with Firebase using email and password
    func signUp() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await FirebaseService.shared.signUp(email: email, password: password)
            isLoggedIn = true
            hasCompletedOnboarding = false
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    /// Handles Apple Sign-In using Firebase
    /// - Parameters:
    ///   - idToken: The Apple ID token received after authorization
    ///   - nonce: The original un-hashed nonce used in the request
    func handleAppleSignIn(idToken: String, nonce: String) async {
        print("🟢 handleAppleSignIn started")
        
        isLoading = true
        errorMessage = nil
        do {
            let result = try await FirebaseService.shared.signInWithApple(idToken: idToken, nonce: nonce)
            
            print("✅ Firebase Apple Sign-In success: \(result.user.uid)")
            
            isLoggedIn = true
            // check the onboarding status
            await fetchOnboardingStatus()

        } catch {
            
            print("❌ Firebase Apple Sign-In failed: \(error.localizedDescription)")
            
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    func handleGoogleSignIn(presenting: UIViewController) async {
        isLoading = true
        errorMessage = nil
        do {
            let result = try await FirebaseService.shared.signInWithGoogle(presenting: presenting)
            isLoggedIn = true
            await fetchOnboardingStatus()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
    
    private func fetchOnboardingStatus() async {
        /// mock
        self.hasCompletedOnboarding = false
/// pull real data
//            guard let uid = Auth.auth().currentUser?.uid else { return }
//            do {
//                let doc = try await db.collection("users").document(uid).getDocument()
//                if let data = doc.data(), let status = data["hasCompletedOnboarding"] as? Bool {
//                    self.hasCompletedOnboarding = status
//                } else {
//                    self.hasCompletedOnboarding = false
//                }
//            } catch {
//                print("❌ Error fetching onboarding status: \(error.localizedDescription)")
//                self.hasCompletedOnboarding = false
//            }
        }
    
    
    /// Signs out the current user
    func signOut() {
        do {
            try FirebaseService.shared.signOut()
            isLoggedIn = false
        } catch {
            errorMessage = error.localizedDescription
        }
    }
}
