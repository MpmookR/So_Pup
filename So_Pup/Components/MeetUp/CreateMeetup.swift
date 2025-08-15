import SwiftUI

struct CreateMeetup: View {
    @Environment(\.dismiss) var dismiss
    @ObservedObject var meetupVM: MeetupViewModel
    
    var onBack: () -> Void
    var chatRoomId: String
    var receiverId: String
    var receiverDogId: String
    var receiverDogName: String
    
    @State private var title: String = ""
    
    // Initialize title with receiver dog name
    private var defaultTitle: String {
        "Meet up with \(receiverDogName)"
    }
    @State private var location: String = ""
    @State private var selectedLocation: LocationData?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    
    // Ensure end date is always valid when start date changes
    private func updateEndDateIfNeeded() {
        if endDate <= startDate {
            endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
        }
    }
    @State private var message: String = "Hi! would you like to join me for a meetup? I've suggested time and place. See you there!"
    @State private var showLocationPicker = false
    
    var body: some View {
        ZStack {
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
                VStack(spacing: 0) {
                    TextField(defaultTitle, text: $title)
                        .onAppear {
                            if title.isEmpty {
                                title = defaultTitle
                            }
                        }
                        .padding()
                    
                    Divider()
                        .padding(.horizontal)
                    
                    Button {
                        showLocationPicker = true
                    } label: {
                        HStack {
                            if let selectedLocation = selectedLocation {
                                Text(selectedLocation.name)
                                    .foregroundColor(.primary)
                            } else {
                                Text("Location")
                                    .foregroundColor(.secondary)
                            }
                            
                            Spacer()
                        }
                        .padding()
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .background(Color.white)
                .cornerRadius(12)
                
                // Date/Time controls
                VStack(spacing: 16) {
                    HStack {
                        Text("Starts")
                        Spacer()
                        DatePicker("", selection: $startDate, in: Date()..., displayedComponents: [.date, .hourAndMinute])
                            .labelsHidden()
                            .onChange(of: startDate) { _, _ in
                                updateEndDateIfNeeded()
                            }
                    }
                    
                    Divider()
                    
                    HStack {
                        Text("Ends")
                        Spacer()
                        DatePicker("", selection: $endDate, in: startDate..., displayedComponents: [.date, .hourAndMinute])
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
                        .frame(minHeight: 180)
                        .background(Color.clear)
                        .overlay(
                            RoundedRectangle(cornerRadius: 21)
                                .stroke(Color.socialButton, lineWidth: 1.5)
                        )
                }
                
                NextButton(
                    title: meetupVM.isLoading ? "Creating..." : "Create Meet-Up",
                    onTap: {
                        Task {
                            await createMeetup()
                        }
                    }
                )
                .disabled(meetupVM.isLoading || title.isEmpty || selectedLocation == nil)
                
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal)
        }
        .alert("Error", isPresented: $meetupVM.showError) {
            Button("OK") { }
        } message: {
            Text(meetupVM.errorMessage)
        }
        .alert("Success", isPresented: $meetupVM.showSuccess) {
            Button("OK") {
                dismiss()
            }
        } message: {
            Text(meetupVM.successMessage)
        }
        .sheet(isPresented: $showLocationPicker) {
            LocationPicker(selectedLocation: $selectedLocation)
        }
    }
    
    private func createMeetup() async {
        guard let selectedLocation = selectedLocation else { return }
        
        let coordinate = Coordinate(
            latitude: selectedLocation.coordinate.latitude,
            longitude: selectedLocation.coordinate.longitude
        )
        
        await meetupVM.createMeetupRequest(
            chatRoomId: chatRoomId,
            proposedTime: startDate,
            locationName: selectedLocation.name,
            locationCoordinate: coordinate,
            meetUpMessage: message,
            receiverId: receiverId,
            receiverDogId: receiverDogId
        )
    }
}


