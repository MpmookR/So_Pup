import SwiftUI

struct NextButton: View {
    let title: String
    var isDisabled: Bool = false
    var backgroundColor: Color = .socialButton
    var foregroundColor: Color = .socialText
    var borderColor: Color? = .socialBorder
    var onTap: (() -> Void)? = nil

    var body: some View {
        Button(action: {
            if !isDisabled {
                onTap?()
            }
        }) {
            Text(title)
                .font(.system(size: 16, weight: .semibold))
                .frame(maxWidth: .infinity, minHeight: 32)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isDisabled ? Color.socialLight.opacity(0.4) : backgroundColor)
                .foregroundColor(isDisabled ? .gray : foregroundColor)
                .cornerRadius(99)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(
                            isDisabled ? Color.gray.opacity(0.4) : (borderColor ?? backgroundColor),
                            lineWidth: 1
                        )
                )
        }
        .disabled(isDisabled)
    }
}
