import SwiftUI

struct MeetupCard: View {
    let meetup: MeetupRequest
    
    // Computed border color based on active/completed
    var borderColor: Color {
        if meetup.status.isActive {
            return meetup.status == .pending ? Color.socialBorder : Color.green
        } else {
            return Color.gray
        }
    }
    
    var body: some View {
        VStack(spacing: 12) {
            // Main content
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Meet DogName") 
                        .fontWeight(.bold)
                    Spacer()
                    Text("Accepted")
                }
                
                Divider()
                
                HStack {
                    Text("Saturday, 15th of May, 2021")
                    Spacer()
                    Text("16.00 - 17.00")
                }
                
                HStack {
                    Text("Location:")
                    Text("Queen Elizabeth I Oak")
                        .foregroundColor(.red)
                }

                // Show "Leave a Review" button only if completed (met)
                if meetup.status.allowsComment {
                    SubmitButton(
                        title: "Leave a Review",
                        iconName: "pencil",
                        backgroundColor: .blue,
                        foregroundColor: .white,
                        borderColor: nil,
                        action: {
                            // Handle review action here
                        }
                    )
                    .frame(maxWidth: .infinity, alignment: .center)
                }
            }
            .padding()
            .frame(maxWidth: .infinity)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 21)
                    .stroke(borderColor, lineWidth: 2)
            )
            .clipShape(RoundedRectangle(cornerRadius: 21))
            .shadow(radius: 2)
        }
    }
}
    
#Preview {
    Group {
        MeetupCard(meetup: .mock(status: .pending))
        MeetupCard(meetup: .mock(status: .upcoming))
        MeetupCard(meetup: .mock(status: .declined))
    }
    .padding()
}

extension MeetupRequest {
    static func mock(status: MeetupStatus) -> MeetupRequest {
        .init(
            proposedTime: Date(),
            locationName: "Queen Elizabeth I Oak",
            locationCoordinate: Coordinate(latitude: 0, longitude: 0, geohash: nil),
            meetUpMessage: "Hello",
            status: status
        )
    }
}

