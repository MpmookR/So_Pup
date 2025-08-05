import SwiftUI

struct MeetupCardBubble: View {
//    let title: String
//    let time: String
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack(spacing: 8) {
                Image(systemName: "calendar")
                Text("title")
                    .fontWeight(.semibold)
            }

            Text("time")
                .font(.footnote)

            Button("view meet-up") {
                // handle navigation
            }
            .font(.caption)
            .foregroundColor(.gray)
        }
        .padding()
        .background(Color.socialAccent)
        .cornerRadius(16)
        .frame(maxWidth: 350, alignment: .leading)
        .padding(.horizontal, 60)
    }
}

#Preview {
    MeetupCardBubble()
}

