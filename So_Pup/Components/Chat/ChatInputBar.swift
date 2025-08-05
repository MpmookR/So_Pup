import SwiftUI

struct ChatInputBar: View {
    @State private var message: String = ""

    var body: some View {
        HStack{
            HStack(spacing: 12) {
                TextField("message...", text: $message)
                    .padding(12)
                    .background(Color.white)
                    .cornerRadius(24)
            }
            .padding(.horizontal, 12)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 21)
                    .stroke(Color.socialText, lineWidth: 1)
            )
            
            HStack(spacing: 12) {
                // button send create meet up
                Image(systemName: "calendar")
            }
            .foregroundColor(Color.orange)
        }
    }
}

#Preview{
    ChatInputBar()
}


