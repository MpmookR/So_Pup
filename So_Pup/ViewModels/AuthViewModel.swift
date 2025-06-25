import Foundation
import UIKit
import FirebaseAuth

//@MainActor tells compiler to run all code in this class on the main thread to safely update UI-related
@MainActor
class AuthViewModel: ObservableObject {
    
    /// Email entered by the user (bound to TextField)
    @Published var email = ""
    
    /// Password entered by the user (bound to SecureField)
    @Published var password = ""
    
    /// Holds error message for UI display
    @Published var errorMessage: String?
    
    /// Indicates whether a sign-in or sign-up process is ongoing
    @Published var isLoading = false
    
    /// Indicates whether the user is successfully authenticated
    @Published var isLoggedIn = false
    
    // MARK: - Initializer
    /// Initialize login state based on current Firebase session
    init (){
        self.isLoggedIn = Auth.auth().currentUser != nil
    }
    
    // MARK: - Authentication Methods
    /// Sign in with email and password using FirebaseService
    func signIn() async {
        isLoading = true
        errorMessage = nil
        do {
            _ = try await FirebaseService.shared.signIn(email: email, password: password)
            isLoggedIn = true
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
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
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
