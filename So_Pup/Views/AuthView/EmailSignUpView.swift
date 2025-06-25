import SwiftUI

struct EmailSignUpView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
    @State private var confirmPassword = ""
    @State private var showPassword = false
    @State private var showConfirm = false
    @State private var showErrorAlert = false
    
    var body: some View {
        ZStack {
            Image("bottombg")
                .resizable()
                .scaledToFill()
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                
                CustomNavBar(
                    title: nil,
                    showBack: true,
                    onBackTap: {
                        presentationMode.wrappedValue.dismiss()
                    }, backgroundColor: Color.socialLight
                )
                .padding(.top, 8)
                .padding(.horizontal, 8.0)

                
                // Header
                VStack {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Create Account")
                            .font(.system(size: 28, weight: .bold))
                        
                        Text("Join SoPup to connect with nearby dog owners, plan meetups, and track your pup’s journey🐾")
                            .font(.callout)
                            .foregroundColor(.gray)
                    }
                    .padding(.vertical, 48)

                    // Fields
                    VStack(spacing: 16) {
                        SelectableField(
                            label: "Email Address",
                            value: $authViewModel.email,
                            placeholder: "Michael_Scott@example.com",
                            filled: false
                        )
                        
                        SelectableField(
                            label: "Password",
                            value: $authViewModel.password,
                            placeholder: "Sc@tt123!",
                            filled: false,
                            isSecure: true,
                            showToggle: true
                        )
                        
                        
                        SelectableField(
                            label: "Confirm Password",
                            value: $confirmPassword,
                            placeholder: "Sc@tt123!",
                            filled: false,
                            isSecure: true,
                            showToggle: true
                            
                        )
                    }
                }
                .padding(.horizontal)
                Spacer()
                
                // Sign Up Button
                SubmitButton(
                    title: "Sign Up",
                    backgroundColor: .socialButton,
                    foregroundColor: .socialText,
                    borderColor: .socialBorder
                ) {
                    Task {
                        guard confirmPassword == authViewModel.password else {
                            authViewModel.errorMessage = "Passwords do not match."
                            showErrorAlert = true
                            return
                        }
                        await authViewModel.signUp()
                        
                        // After sign-up, if there's any error message, show the alert
                        showErrorAlert = authViewModel.errorMessage != nil

                    }
                }
                .padding(.horizontal)
                .padding(.top)
                
                // MARK: - Footer
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
                        
                        NavigationLink(destination: SignInView().environmentObject(authViewModel)) {
                            Text("Sign In")
                                .font(.callout)
                                .bold()
                                .foregroundColor(Color.socialButton)
                        }
                    }
                }
                .padding(.bottom, 48.0)
                
            }
            .padding(.top)
        }
        .alert("Error", isPresented: $showErrorAlert) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(authViewModel.errorMessage ?? "Unknown error")
        }

        .onTapGesture {
            hideKeyboard()
        }
        .navigationBarBackButtonHidden(true)
        .navigationBarHidden(true)
    }
}

#Preview {
    NavigationStack {
        EmailSignUpView()
            .environmentObject(AuthViewModel())
    }
}

