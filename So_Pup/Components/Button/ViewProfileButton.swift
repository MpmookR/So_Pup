import SwiftUI

struct ViewProfileButton: View {
    let dog: DogModel
    let owner: UserModel
    let viewerCoordinate: Coordinate?
    var title: String? = "view profile"

    var body: some View {
        NavigationLink {
            FullDogDetailsView(dog: dog, owner: owner, userCoordinate: viewerCoordinate)
        } label: {
            VStack(spacing: 4) {
                Image(systemName: "person.circle")
                    .font(.title3)
                    .foregroundColor(dog.mode == .puppy ? .puppyButton : .socialButton)

                if let title, !title.isEmpty {
                    Text(title)
                        .font(.caption)
                        .foregroundColor(.socialText)
                }
            }
            .contentShape(Rectangle())
        }
        .buttonStyle(.plain)
    }
}


#Preview {
  NavigationStack {
      ViewProfileButton(dog: MockDogData.dog1, owner: MockUserData.user1, viewerCoordinate: MockUserData.user2.coordinate)
  }
  .environmentObject(MatchRequestViewModel(authVM: AuthViewModel()))
}
