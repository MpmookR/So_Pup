import SwiftUI

struct SubmitButton: View {
    let title: String
    var iconName: String? = nil
    var backgroundColor: Color = .blue
    var foregroundColor: Color = .white
    var borderColor: Color? = nil
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                if let iconName = iconName {
                    Image(systemName: iconName)
                        .font(.system(size: 16, weight: .semibold))
                }

                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .frame(maxWidth: .infinity, minHeight: 32)
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(backgroundColor)
            .foregroundColor(foregroundColor)
            .cornerRadius(99)
            .overlay(
                RoundedRectangle(cornerRadius: 99)
                    .stroke(borderColor ?? backgroundColor, lineWidth: 1)
            )
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        SubmitButton(
            title: "Sign Up",
            backgroundColor: .socialButton,
            foregroundColor: .socialText,
            borderColor: .socialBorder,
            action: {}
        )

        SubmitButton(
            title: "log session",
            iconName: "plus",
            backgroundColor: .puppyButton,
            foregroundColor: .socialText,
            borderColor: .puppyBorder,
            action: {}
        )
    }
    .padding()
}



