import SwiftUI

// MARK: - Social Mode Unlock Section
struct SocialModeUnlockSection: View {
    @ObservedObject var dogModeSwitcher: DogModeSwitcherViewModel
    
    var body: some View {
        VStack(spacing: 16) {
            // Switch to Social Mode Button
            Button(action: {
                Task {
                    await dogModeSwitcher.switchToSocialMode()
                }
            }) {
                HStack {
                    if dogModeSwitcher.isUpdating {
                        ProgressView()
                            .scaleEffect(0.8)
                            .foregroundColor(.black)
                    } else {
                        Image(systemName: dogModeSwitcher.readyToSwitchMode ? "lock.open.fill" : "lock.fill")
                            .font(.title3)
                    }
                    Text("Switch to Social Mode")
                        .font(.headline)
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(dogModeSwitcher.readyToSwitchMode ? Color.socialAccent : Color.gray.opacity(0.3))
                .foregroundColor(dogModeSwitcher.readyToSwitchMode ? .black : .gray)
                .cornerRadius(16)
            }
            .disabled(!dogModeSwitcher.readyToSwitchMode || dogModeSwitcher.isUpdating)
            
            // Requirement message
            if !dogModeSwitcher.readyToSwitchMode {
                VStack(spacing: 4) {
                    Text("you must complete core vaccination")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    
                    Text("to unlock Social Mode")
                        .font(.subheadline)
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                }
                .foregroundColor(Color.socialText)
            }
        }
        .alert("Mode Switch Error", isPresented: $dogModeSwitcher.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(dogModeSwitcher.errorMessage)
        }
        .alert("🎉 Welcome to Social Mode!", isPresented: $dogModeSwitcher.showModeChangeAlert) {
            Button("Let's Go!") {
                Task {
                    await dogModeSwitcher.handleModeChangeSuccess()
                }
            }
        } message: {
            Text("Your pup is now ready to socialize! You can connect with other dogs and their owners in your area.")
        }
    }
}


