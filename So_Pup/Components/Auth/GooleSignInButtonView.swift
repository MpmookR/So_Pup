import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

struct GoogleSignInButtonView: View {
    @EnvironmentObject var authViewModel: AuthViewModel

    var body: some View {
        SignInButton(
            title: "Continue with Google",
            icon: Image("gmail")
        ) {
            handleSignIn()
        }
    }

    private func handleSignIn() {
        guard let rootViewController = getRootViewController() else {
            authViewModel.errorMessage = "Unable to get root view controller."
            return
        }

        Task {
            await authViewModel.handleGoogleSignIn(presenting: rootViewController)
        }
    }

    // Safely gets the root UIViewController for SwiftUI-based apps
    private func getRootViewController() -> UIViewController? {
        guard let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = scene.windows.first(where: { $0.isKeyWindow }),
              let rootVC = window.rootViewController else {
            return nil
        }
        return rootVC
    }
}
