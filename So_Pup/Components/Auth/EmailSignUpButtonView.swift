import SwiftUI

struct EmailSignUpButtonView: View {
    var body: some View {
        SignInButton(
            title: "Sign up with Email",
            icon: Image("mail"),
            action: {}
        )
        .disabled(true) // disables the inner button so it doesn't trigger anything
    }
}



