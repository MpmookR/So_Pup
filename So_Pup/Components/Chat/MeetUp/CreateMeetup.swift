import SwiftUI

struct CreateMeetup: View {
    @Environment(\.dismiss) var dismiss
    
    var onBack: () -> Void
    

    @State private var title: String = ""
    @State private var location: String = ""
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!

    @State private var message: String = "Hi! would you like to join me for a meetup? I've suggested time and place. See you there!"
    var body: some View {
        ZStack{
            Color.white.ignoresSafeArea()

            VStack(spacing: 16) {
                // Header with cancel/confirm
                CustomNavBar(
                    title: "Create Meet-Up",
                    showBack: true,
                    onBackTap: onBack,
                    backgroundColor: .white
                )
                
                
                // Title + location
                VStack(spacing: 16) {
                    TextField("Title", text: $title)
                    
                    Divider()

                    TextField("Location", text: $location)
                }
                .padding(.all)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .stroke(Color.socialButton, lineWidth: 1.5)
                    )
                
                // Date/Time controls
                VStack(spacing: 16) {
                    HStack {
                        Text("Starts")
                        Spacer()
                        DatePicker("", selection: $startDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                    
                    Divider()

                    HStack {
                        Text("Ends")
                        Spacer()
                        DatePicker("", selection: $endDate, displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                    }
                }
                .padding(.all)
                .background(Color.clear)
                .overlay(
                    RoundedRectangle(cornerRadius: 21)
                        .stroke(Color.socialButton, lineWidth: 1.5)
                    )
                
                // MARK: -add Mapkit/CoreLocation to project the location entered
                
                VStack(spacing: 16) {
                    Text("✍️ Write a quick message")
                        .font(.headline)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    TextEditor(text: $message)
                        .padding(12)
                        .frame(minHeight: 30)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 21)
                                .stroke(Color.socialButton, lineWidth: 1.5)
                        )
                }
                
                NextButton(
                    title: "Create Meet-Up",
                    onTap: {} // save to firebase + send to chat
                )
                Spacer()
                
            }
            .padding(.top)
        }
    }
}

#Preview {
    VStack {
        CreateMeetup(
            onBack: {}
        )
    }
    .padding(.horizontal)

}

