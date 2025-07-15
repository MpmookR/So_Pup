import SwiftUI

struct ConnectButton: View {
    var alreadyConnected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(alreadyConnected ? "Request Sent" : "Let's Connect")
                .font(.headline)
                .foregroundColor(alreadyConnected ? Color.gray : Color.socialText)
                .frame(maxWidth: .infinity)
                .padding()
                .background(alreadyConnected ? Color.socialLight : Color.socialAccent)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(alreadyConnected ? Color.socialText: Color.socialButton)
                )
                .cornerRadius(99)
        }
        .disabled(alreadyConnected)
    }
}

#Preview {
    VStack(spacing: 20) {
        ConnectButton(alreadyConnected: false) {
            print("Request sent")
        }

        ConnectButton(alreadyConnected: true) {
            print("Request already sent")
        }
    }
    .padding()
    .background(Color.gray.opacity(0.5))
}

