import SwiftUI

struct SocialModeUnlockSection: View {
    @ObservedObject var dogModeSwitcher: DogModeSwitcherViewModel
    @Binding var modeChanged: Bool

    var body: some View {
        VStack(spacing: 16) {
            Button {
                Task {
                    await dogModeSwitcher.switchToSocialMode()
                    // If the backend confirmed and the VM updated the dog, flip the parent flag
                    if dogModeSwitcher.dog.mode == .social {
                        modeChanged = true
                    }
                }
            } label: {
                HStack {
                    if dogModeSwitcher.isUpdating {
                        ProgressView().scaleEffect(0.8).foregroundColor(.black)
                    } else {
                        Image(systemName: dogModeSwitcher.readyToSwitchMode ? "lock.open.fill" : "lock.fill")
                            .font(.title3)
                    }
                    Text("Switch to Social Mode")
                        .font(.headline).fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(dogModeSwitcher.readyToSwitchMode ? Color.socialAccent : Color.gray.opacity(0.3))
                .foregroundColor(dogModeSwitcher.readyToSwitchMode ? .black : .gray)
                .cornerRadius(16)
            }
            .disabled(!dogModeSwitcher.readyToSwitchMode || dogModeSwitcher.isUpdating)

            if !dogModeSwitcher.readyToSwitchMode {
                VStack(spacing: 4) {
                    Text("you must complete core vaccination")
                        .font(.subheadline).fontWeight(.medium)
                        .multilineTextAlignment(.center)
                    Text("to unlock Social Mode")
                        .font(.subheadline).fontWeight(.medium)
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
    }
}
