import SwiftUI

struct ChatBubble: View {
    let text: String
    let isCurrentUser: Bool
    
    var body: some View {
        HStack {
            if isCurrentUser { Spacer() }
            
            Text(text)
                .padding()
                .background(isCurrentUser ? Color.socialLight : Color.white)
                .foregroundColor(.black)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .stroke(isCurrentUser ? Color.clear : Color.socialBorder, lineWidth: 2)
                )
                .cornerRadius(21)
                .frame(maxWidth: 260, alignment: isCurrentUser ? .trailing : .leading)
                .padding(isCurrentUser ? .leading : .trailing, 60)
                .padding(.vertical, 4)
            
            if !isCurrentUser { Spacer() }
        }
    }
}

#Preview {
    VStack {
        ChatBubble(text: "Hello, I am the first time dog owner", isCurrentUser: true)
        ChatBubble(text: "Hello", isCurrentUser: false)
    }
    .padding(.all)
}


