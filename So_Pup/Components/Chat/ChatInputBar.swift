import SwiftUI

struct ChatInputBar: View {
    @Binding var text: String
    var onSend: (String) -> Void
    var onCreateMeetup: () -> Void
    var isMeetupAllowed: Bool = true
    @FocusState private var isFocused: Bool
    @State private var showPuppyModeAlert = false
    
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
            Button(action: {
                if isMeetupAllowed {
                    onCreateMeetup()
                } else {
                    showPuppyModeAlert = true
                }
            }) {
                Image(systemName: isMeetupAllowed ? "calendar" : "calendar.badge.exclamationmark")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
            .foregroundColor(isMeetupAllowed ? Color.socialAccent : .gray)

            // Send button
            Button(action: trySend) {
                Image(systemName: "arrow.up.circle.fill")
                    .imageScale(.large)
                    .frame(width: 44, height: 44)
            }
            .foregroundColor(canSend ? Color.socialAccent : .gray)
            .disabled(!canSend)
        }
        .padding(.horizontal, 8)
        .padding(.vertical, 6)
        .background(.white)
        .alert("🚫 Meet-up is not available", isPresented: $showPuppyModeAlert) {
            Button("OK") {
                showPuppyModeAlert = false
            }
            .foregroundColor(Color.socialText)
        } message: {
            Text("One of the chatroom members is in puppy mode.Puppies under 12 weeks should avoid in-person interactions until fully vaccinated.\nYou'll be able to schedule meet-ups once both dogs are in Social Mode")
        }
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
