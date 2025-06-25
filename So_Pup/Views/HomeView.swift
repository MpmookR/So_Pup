//
//  HomeView.swift
//  So_Pup
//
//  Created by Mook Rattana on 24/06/2025.
//

import SwiftUI

struct HomeView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    var body: some View {
        VStack {
            Text("🎉 Welcome to the Home Page!")
                .font(.largeTitle)
                .padding()
            
            Text("User is logged in.")
                .foregroundColor(.green)
            
            Button(action: {
                authViewModel.signOut()
            }) {
                Text("Log Out")
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.red)
                    .cornerRadius(12)
            }
        }
    }
}

#Preview {
    HomeView()
}
