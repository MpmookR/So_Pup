import SwiftUI
import FirebaseAuth

struct SignInView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @Environment(\.presentationMode) var presentationMode
    
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
                        onBackTap: {
                            presentationMode.wrappedValue.dismiss()
                        }, backgroundColor: Color.socialLight
                    )
                    .padding(.top, 8)
                    
                    // MARK: - Welcome Section
                    VStack(alignment: .leading) {
                        Text("Welcome to SoPup")
                            .font(.title)
                            .fontWeight(.bold)
                            .foregroundColor(Color.socialText)
                        
                        Text("Where pups meet, play and find a perfect match 🐾")
                            .foregroundColor(Color.socialText)
                            .font(.subheadline)
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.bottom, 42.0)
                    
                    // MARK: - Input Fields
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
                        Spacer()
                        
                        // MARK: - Log In Button
                        SubmitButton(
                            title: "Log In",
                            backgroundColor: .socialButton,
                            foregroundColor: .socialText,
                            borderColor: .socialBorder
                        ) {
                            Task {
                                await authViewModel.signIn()
                            }
                        }
                    }
                    
                    VStack{
                        Text("or sign in with")
                            .font(.callout)
                            .foregroundColor(.black)
                    }
                    
                    VStack(spacing: 16) {
                        
                        AppleSignInButtonView()
                            .environmentObject(authViewModel)
                        
                        GoogleSignInButtonView()
                            .environmentObject(authViewModel)
                        
                        if let error = authViewModel.errorMessage {
                            Text(error)
                                .foregroundColor(.red)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        
                        if authViewModel.isLoggedIn {
                            Text("✅ Signed in successfully")
                                .foregroundColor(.green)
                        }
                    }
                    
                    // MARK: - Footer
                    VStack(spacing: 4) {
                        Text("By continuing, you agree to SoPup's Terms of Service and acknowledge you've read our Privacy Policy.")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .multilineTextAlignment(.center)
                        
                        Divider()
                        
                        HStack(spacing: 4) {
                            Text("Not on SoPup yet?")
                                .font(.footnote)
                                .foregroundColor(.black)
                            
                            NavigationLink(destination: RegisterView().environmentObject(authViewModel)) {
                                Text("Sign Up")
                                    .font(.callout)
                                    .bold()
                                    .foregroundColor(Color.socialButton)
                            }
                            
                        }
                    }
                    Spacer()
                }
                .padding()
                .onTapGesture {
                    hideKeyboard()
                }
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                
                .onAppear {
                    if let user = Auth.auth().currentUser {
                        print("✅ Firebase connected: signed in as \(user.uid)")
                    } else {
                        print("✅ Firebase connected: no user signed in")
                    }
                }
        }
    }
}

#Preview {
    SignInView()
        .environmentObject(AuthViewModel())
}
