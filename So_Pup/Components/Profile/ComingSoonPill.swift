import SwiftUI

struct ComingSoonPill: View {
    @State private var show = false

    var body: some View {
        Button { show = true } label: {
            Image(systemName: "pencil")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color.socialText)
                .frame(width: 28, height: 28)
                .background(Color.white)
                .clipShape(Circle())
                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
        }
        .alert("Coming soon", isPresented: $show) {
            Button("OK", role: .cancel) {}
        } message: {
            Text("Profile editing isn’t available yet.")
        }
        .tint(nil)
    }
}

