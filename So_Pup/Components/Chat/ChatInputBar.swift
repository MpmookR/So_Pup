import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    var onSend: (String) -> Void
    var onCreateMeetup: () -> Void
    @FocusState private var isFocused: Bool
    
    var body: some View {
        HStack(spacing: 4) {
            // Text field
            TextField("message...", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
                .padding(.horizontal, 14)
                .padding(.vertical, 10)
                .background(Color.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .stroke(Color.socialText, lineWidth: 1)
                )
                .cornerRadius(21)
                .foregroundColor(Color.socialText)
                .focused($isFocused)
                .submitLabel(.send)
                .onSubmit { trySend() }

            // Create Meet-up button
            Button(action: onCreateMeetup) {
                Image(systemName: "calendar")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
            .foregroundColor(Color.socialAccent)
            .accessibilityLabel("Create meet-up")

            // Send button
            Button(action: trySend) {
                Image(systemName: "arrow.up.circle.fill")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
            .foregroundColor(canSend ? Color.socialAccent : .gray)
            .disabled(!canSend)
            .accessibilityLabel("Send message")
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.white)
    }

    private var canSend: Bool {
        !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private func trySend() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        print("🟢 ChatInputBar.trySend fired with '\(trimmed)'") // temp debug
        onSend(trimmed)
        isFocused = false
    }
}
