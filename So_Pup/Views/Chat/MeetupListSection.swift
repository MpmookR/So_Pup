import SwiftUI

struct MeetupListSection: View {
    var body: some View {
        VStack(spacing: 12) {
            Text("Meet-Up")
                .font(.headline)

            // Placeholder empty state
            RoundedRectangle(cornerRadius: 16)
                .fill(Color(.secondarySystemBackground))
                .frame(height: 120)
                .overlay(
                    VStack(spacing: 8) {
                        Image(systemName: "calendar.badge.plus")
                            .imageScale(.large)
                        Text("No meet-ups yet")
                            .foregroundColor(.secondary)
                        Text("Create or receive meet-up requests here.")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                )

            // Stub action (wire up later)
            Button {
                // TODO: navigate to Create Meet-Up flow
            } label: {
                Label("Create a meet-up", systemImage: "calendar.badge.plus")
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.vertical)
    }
}

