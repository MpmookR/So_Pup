import SwiftUI

struct RegisterView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    
    var body: some View {
        NavigationStack{
            ZStack {
                Image("bgSignUp")
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
                VStack {
                    Spacer() // Push content to bottom
                    
                    // MARK: - Sign-In Buttons
                    VStack(spacing: 16) {
                        AppleSignInButtonView()
                            .environmentObject(authViewModel)
                        
                        GoogleSignInButtonView()
                            .environmentObject(authViewModel)
                        
                        NavigationLink(destination: EmailSignUpView().environmentObject(authViewModel)) {
                            EmailSignUpButtonView()
                                .environmentObject(authViewModel)
                        }


                    }
                    .padding(.horizontal)
                    
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
                    .padding(.bottom, 48)
                    .padding(.horizontal)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottom)
                .navigationBarBackButtonHidden(true)
                .navigationBarHidden(true)
                .onTapGesture { hideKeyboard() }
                
            }
        }
    }
}

#Preview {
    NavigationStack {
        RegisterView()
            .environmentObject(AuthViewModel())
    }
}
