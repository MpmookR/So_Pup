import SwiftUI

struct ConnectButton: View {
    var label: String
    var alreadyConnected: Bool
    var action: () -> Void
    
    var body: some View {
        
        Button(action: action) {
            Text(label)
                .font(.body)
                .foregroundColor(alreadyConnected ? Color.gray : Color.socialText)
                .frame(maxWidth: .infinity)
                .padding()
                .background(alreadyConnected ? Color.socialLight : Color.socialAccent)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(alreadyConnected ? Color.socialBorder : Color.socialButton)
                )
                .cornerRadius(99)
        }
        .disabled(alreadyConnected)
    }
}

#Preview {
    VStack(spacing: 20) {
        ConnectButton(
            label: "Request sent", alreadyConnected: true, action: {})
        
        ConnectButton(
            label: "Let's connect", alreadyConnected: false, action: {})
    }
    .padding()
    .background(Color.gray.opacity(0.5))
}

