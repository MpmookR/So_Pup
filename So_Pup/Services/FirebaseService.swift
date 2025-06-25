import FirebaseAuth
import FirebaseCore
import GoogleSignIn

//Singleton service for handling Firebase Authentication tasks.
class FirebaseService {
    //Shared instance for global access
    static let shared = FirebaseService()
    
    /// Private initializer to enforce singleton pattern
    private init() {}

    //Signs up a new user with email and password using async/await
    func signUp(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().createUser(withEmail: email, password: password)
    }
    
    func signIn(email: String, password: String) async throws -> AuthDataResult {
        return try await Auth.auth().signIn(withEmail: email, password: password)
    }
    
    func signInWithApple(idToken: String, nonce: String) async throws -> AuthDataResult {
        let credential = OAuthProvider.credential(
            providerID: .apple,
            idToken: idToken,
            rawNonce: nonce
        )
        return try await Auth.auth().signIn(with: credential)
    }
    
    /// - Parameter presenting: The UIViewController used to present the Google sign-in flow.
    /// - Returns: An `AuthDataResult` representing the signed-in Firebase user.
    /// - Throws: An error if the sign-in process fails at any step.
    func signInWithGoogle(presenting: UIViewController) async throws -> AuthDataResult {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            throw NSError(domain: "GoogleSignIn", code: -1, userInfo: [NSLocalizedDescriptionKey: "Missing client ID"])
        }

        print("✅ clientID: \(clientID)")

        // Configure Google Sign-In with the retrieved clientID
        GIDSignIn.sharedInstance.configuration = GIDConfiguration(clientID: clientID)

        // Launch the Google Sign-In flow
        let result = try await GIDSignIn.sharedInstance.signIn(withPresenting: presenting)
        
        // Retrieve the signed-in Google user
        let user = result.user

        // Ensure the ID token is available
        guard let idToken = user.idToken?.tokenString else {
            throw NSError(domain: "GoogleSignIn", code: -2, userInfo: [NSLocalizedDescriptionKey: "Missing ID token"])
        }
        
        // Generate Firebase credential using Google ID token and access token
        let credential = GoogleAuthProvider.credential(withIDToken: idToken, accessToken: user.accessToken.tokenString)
        return try await Auth.auth().signIn(with: credential)
    }

    
    func signOut() throws {
        try Auth.auth().signOut()
    }

    // The currently signed-in user, if any
    var currentUser: User? {
        return Auth.auth().currentUser
    }
}

//nonce stands for number used once.
  ///In Apple Sign-In, it's a cryptographic string that helps prevent replay attacks


