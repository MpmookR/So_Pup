import SwiftUI
import FirebaseAuth

struct EmailSignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.dismiss) private var dismiss

    @State private var confirmPassword = ""
    @State private var showErrorAlert = false

    var body: some View {
        ZStack {
            Image("bottombg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Nav
                CustomNavBar(
                    title: nil,
                    showBack: true,
                    onBackTap: { dismiss() },
                    backgroundColor: Color.socialLight
                )
                .padding(.top, 8)
                .padding(.horizontal, 8)

                // Header
                VStack(alignment: .leading, spacing: 8) {
                    Text("Create Account")
                        .font(.system(size: 28, weight: .bold))
                    Text("Join SoPup to connect with nearby dog owners, plan meetups, and track your pup’s journey 🐾")
                        .font(.callout)
                        .foregroundColor(.gray)
                }
                .padding(.vertical, 48)
                .padding(.horizontal)

                // Fields
                VStack(spacing: 16) {
                    SelectableField(
                        label: "Email Address",
                        value: $authViewModel.email,
                        placeholder: "michael_scott@example.com",
                        filled: false
                    )
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled(true)

                    SelectableField(
                        label: "Password",
                        value: $authViewModel.password,
                        placeholder: "Minimum 6 characters",
                        filled: false,
                        isSecure: true,
                        showToggle: true
                    )

                    SelectableField(
                        label: "Confirm Password",
                        value: $confirmPassword,
                        placeholder: "Re-enter password",
                        filled: false,
                        isSecure: true,
                        showToggle: true
                    )

                    // Inline validation hint (optional)
                    if !passwordsMatch && !authViewModel.password.isEmpty && !confirmPassword.isEmpty {
                        Text("Passwords do not match.")
                            .font(.footnote)
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.horizontal)

                Spacer()

                // Sign Up Button
                SubmitButton(
                    title: "Sign Up",
                    backgroundColor: canSubmit ? .socialButton : .gray.opacity(0.4),
                    foregroundColor: .socialText,
                    borderColor: .socialBorder
                ) {
                    Task {
                        guard canSubmit else { return }
                        await authViewModel.signUp()
                        // show alert if backend returns error
                        showErrorAlert = authViewModel.errorMessage != nil
                    }
                }
                .disabled(!canSubmit)
                .padding(.horizontal)
                .padding(.top)

                // Footer
                VStack(spacing: 4) {
                    Text("By continuing, you agree to SoPup's Terms of Service and acknowledge you've read our Privacy Policy.")
                        .font(.footnote)
                        .foregroundColor(.gray)
                        .multilineTextAlignment(.center)

                    Divider()

                    HStack(spacing: 4) {
                        Text("Already on SoPup?")
                            .font(.footnote)
                            .foregroundColor(.black)

                        NavigationLink(destination: SignInView()) {
                            Text("Sign In")
                                .font(.callout)
                                .bold()
                                .foregroundColor(Color.socialButton)
                        }
                    }
                }
                .padding(.bottom, 48)
            }
            .onTapGesture { hideKeyboard() }
            .navigationBarBackButtonHidden(true)
            .navigationBarHidden(true)
        }
        // Auto-dismiss when auth flips (RootView will show MainTab/Onboarding)
        .onChange(of: authViewModel.isLoggedIn) { _, loggedIn in
            if loggedIn { dismiss() }
        }
        .onChange(of: authViewModel.hasCompletedOnboarding) { _, done in
            if done { dismiss() }
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authViewModel.errorMessage ?? "Unknown error")
        }
    }

    // MARK: - Validation
    private var passwordsMatch: Bool {
        confirmPassword == authViewModel.password
    }
    private var canSubmit: Bool {
        !authViewModel.email.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty &&
        authViewModel.password.count >= 6 &&
        passwordsMatch
    }
}

#Preview {
    NavigationStack {
        EmailSignUpView()
            .environmentObject(AuthViewModel())
    }
}
