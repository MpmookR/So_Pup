import SwiftUI

struct CustomNavBar: View {
    var title: String?
    var showBack: Bool = false
    var backIcon: String = "chevron.left"
    var onBackTap: (() -> Void)? = nil
    var backgroundColor: Color = .white

    var body: some View {
        HStack {
            if showBack {
                Button(action: {
                    onBackTap?()
                }) {
                    HStack(spacing: 4) {
                        Image(systemName: backIcon)
                            .font(.system(size: 18, weight: .medium))
                        
                        Text("Back")
                            .font(.system(size: 16))
                    }
                    .foregroundColor(.black)
                    .padding(.leading, 8)
                }
            } else {
                Spacer().frame(width: 44)
            }

            Spacer()

            if let title = title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.black)
            }

            Spacer()

            Spacer().frame(width: 44) // right-side spacer
        }
        .padding(.vertical, 12)
        .background(backgroundColor.opacity(0.95))
    }
}

#Preview {
    VStack(spacing: 24) {
        CustomNavBar(
            title: "Edit Profile",
            showBack: true,
            onBackTap: { print("Back tapped") },
            backgroundColor: .yellow.opacity(0.3)
        )

        CustomNavBar(
            title: nil,
            showBack: true,
            backgroundColor: Color.puppyLight
        )

        CustomNavBar(
            title: "SoPup",
            showBack: false,
            backgroundColor: .white
        )
    }
    .padding()
    .background(Color.gray.opacity(0.1))
}

