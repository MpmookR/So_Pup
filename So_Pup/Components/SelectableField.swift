import SwiftUI
//Features
/// Secure input, icon, toggle, border and fill field
///

struct SelectableField: View {
    let label: String
    @Binding var value: String
    var placeholder: String = "Select..."
    var filled: Bool = false
    
    var isSecure: Bool = false
    var showToggle: Bool = false

    /// Optional right-hand icon (e.g. eye, pencil, chevron.down)
    var trailingIcon: String? = nil
    var trailingAction: (() -> Void)? = nil
    
    @State private var isSecureVisible: Bool = false
    @FocusState private var isFocused: Bool

    var body: some View {
            VStack(alignment: .leading, spacing: 8) {
                Text(label)
                    .font(.body)
                    .foregroundColor(Color.socialText)

                HStack {
                    Group {
                        if isSecure {
                            if isSecureVisible {
                                TextField(placeholder, text: $value)
                                    .focused($isFocused)
                            } else {
                                SecureField(placeholder, text: $value)
                                    .focused($isFocused)
                            }
                        } else {
                            TextField(placeholder, text: $value)
                                .focused($isFocused)
                        }
                    }
                    .font(.body)
                    .foregroundColor(.black)
                    .disableAutocorrection(true)
                    .textInputAutocapitalization(.none)

                    if showToggle && isSecure {
                        Button(action: {
                            isSecureVisible.toggle()
                        }) {
                            Image(systemName: isSecureVisible ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    } else if let icon = trailingIcon {
                        Button(action: {
                            trailingAction?()
                        }) {
                            Image(systemName: icon)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 10)
                .background(filled ? Color.socialAccent : Color.white)
                .cornerRadius(99)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(Color.gray.opacity(0.4), lineWidth: filled ? 0 : 1)
                )
            }
        }
    }

#Preview {
    VStack(spacing: 24) {
        // 1. Plain editable field
        SelectableField(
            label: "Email Address",
            value: .constant("demo@example.com"),
            placeholder: "Your email",
            filled: false
        )

        // 2. Secure field with eye toggle
        SelectableField(
            label: "Password",
            value: .constant("Secret123"),
            placeholder: "••••••••",
            filled: true,
            isSecure: true,
            showToggle: true
        )

        // 3. Static text with trailing chevron
        SelectableField(
            label: "Breed",
            value: .constant("Shiba Inu"),
            placeholder: "Select a breed",
            filled: true,
            trailingIcon: "chevron.down",
            trailingAction: {
                print("Chevron tapped")
            }
        )
    }
    .padding()
    .background(Color.socialLight)
}



