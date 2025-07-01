import SwiftUI
import AuthenticationServices

struct AppleSignInButtonView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @State private var currentNonce: String?

    
    var body: some View {
        SignInWithAppleButton(
            .continue,
            onRequest: { request in
                print("Apple Sign In: Request started")

                let nonce = randomNonceString()
                currentNonce = nonce
                request.requestedScopes = [.fullName, .email]
                request.nonce = sha256(nonce)
            },
            onCompletion: { result in
                print("Apple Sign In: Completion triggered")

                switch result {
                case .success(let authResults):
                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential,
                       let appleIDTokenData = appleIDCredential.identityToken,
                       let appleIDToken = String(data: appleIDTokenData, encoding: .utf8),
                       let nonce = currentNonce {
                        Task {
                            await authViewModel.handleAppleSignIn(idToken: appleIDToken, nonce: nonce)
                        }
                    } else {
                        authViewModel.errorMessage = "Apple Sign In failed: identityToken was nil."
                    }
                case .failure(let error):
                    authViewModel.errorMessage = "Apple Sign In failed: \(error.localizedDescription)"
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 44)
        .cornerRadius(21)
    }
}
