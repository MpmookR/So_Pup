import SwiftUI

struct ProfileView: View {
    
    @EnvironmentObject var authVM : AuthViewModel
    var body: some View {
        
        VStack{
            Button("Logout") {
                authVM.signOut()
            }
            .foregroundColor(Color.socialBorder)
        }
    }
}

#Preview {
    ProfileView()
}
