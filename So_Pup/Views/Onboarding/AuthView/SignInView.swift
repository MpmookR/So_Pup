import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        ZStack {
            Image("bottombg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 24) {
                CustomNavBar(
                    title: nil,
                    showBack: true,
                    onBackTap: { dismiss() },
                    backgroundColor: Color.socialLight
                )
                .padding(.top, 8)

                // Welcome
                VStack(alignment: .leading) {
                    Text("Welcome to SoPup")
                        .font(.title).fontWeight(.bold)
                        .foregroundColor(Color.socialText)
                    Text("Where pups meet, play and find a perfect match 🐾")
                        .foregroundColor(Color.socialText)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.bottom, 42)

                // Inputs
                VStack(spacing: 16) {
                    SelectableField(
                        label: "Email Address",
                        value: $authViewModel.email,
                        placeholder: "Michael_Scott@example.com",
                        filled: false
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                    SelectableField(
                        label: "Password",
                        value: $authViewModel.password,
                        placeholder: "••••••••",
                        filled: false,
                        isSecure: true,
                        showToggle: true
                    )

                    // Log In
                    SubmitButton(
                        title: "Log In",
                        backgroundColor: .socialButton,
                        foregroundColor: .socialText,
                        borderColor: .socialBorder
                    ) {
                        Task { await authViewModel.signIn() }
                    }
                    .disabled(authViewModel.email.isEmpty || authViewModel.password.isEmpty)
                }

                Text("or sign in with")
                    .font(.callout)
                    .foregroundColor(.black)

                
                VStack(spacing: 16) {
                    AppleSignInButtonView()
                    GoogleSignInButtonView()

                    if let error = authViewModel.errorMessage {
                        Text(error).foregroundColor(.red).multilineTextAlignment(.center).padding(.horizontal)
                    }
                    if authViewModel.isLoggedIn {
                        Text("✅ Signed in successfully").foregroundColor(.green)
                    }
                }

                // Footer
                VStack(spacing: 4) {
                    Text("By continuing, you agree to SoPup's Terms of Service and acknowledge you've read our Privacy Policy.")
                        .font(.footnote).foregroundColor(.gray).multilineTextAlignment(.center)
                    Divider()
                    HStack(spacing: 4) {
                        Text("Not on SoPup yet?").font(.footnote).foregroundColor(.black)
                        NavigationLink(destination: RegisterView()) {
                            Text("Sign Up").font(.callout).bold().foregroundColor(Color.socialButton)
                        }
                    }
                }

                Spacer() // ← keep the spacer here, inside the VStack
            }
            .padding()
//            .onTapGesture { hideKeyboard() }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
            .onAppear {
                if let user = Auth.auth().currentUser {
                    print("✅ Firebase connected: signed in as \(user.uid)")
                } else {
                    print("✅ Firebase connected: no user signed in")
                }
            }
            .onChange(of: authViewModel.isLoggedIn) { _, loggedIn in
                if loggedIn { dismiss() }
            }
            .onChange(of: authViewModel.hasCompletedOnboarding) { _, done in
                if done { dismiss() }
            }
        }
    }
}
