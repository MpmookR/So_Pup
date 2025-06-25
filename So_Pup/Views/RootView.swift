//
//  RootView.swift
//  So_Pup
//
//  Created by Mook Rattana on 24/06/2025.
//

import SwiftUI

struct RootView: View {
    @EnvironmentObject var authViewModel : AuthViewModel
    
    var body: some View {
        
        Group {
            if authViewModel.isLoggedIn {
                HomeView()
            } else {
                RegisterView()
            }
        }
    }
}

