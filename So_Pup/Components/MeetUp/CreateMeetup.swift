import SwiftUI

struct CreateMeetup: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var meetupVM: MeetupViewModel

    var onBack: () -> Void
    var chatRoomId: String
    var receiverId: String
    var receiverDogId: String
    var receiverDogName: String

    @State private var title: String = ""
    @State private var selectedLocation: LocationData?
    @State private var startDate = Date()
    @State private var endDate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
    @State private var message: String = "Hi! would you like to join me for a meetup? I've suggested time and place. See you there!"
    @State private var showLocationPicker = false

    // Initialize title with receiver dog name
    private var defaultTitle: String { "Meet up with \(receiverDogName)" }

    private func updateEndDateIfNeeded() {
        if endDate <= startDate {
            endDate = Calendar.current.date(byAdding: .hour, value: 1, to: startDate) ?? startDate
        }
    }

    var body: some View {
        ZStack {
            Color.white.ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                CustomNavBar(
                    title: "Create Meet-Up",
                    showBack: true,
                    onBackTap: onBack,
                    backgroundColor: .white
                )

                // Scrollable form
                ScrollView {
                    VStack(spacing: 16) {

                        // Title + Location
                        VStack(spacing: 0) {
                            TextField(defaultTitle, text: $title)
                                .onAppear { if title.isEmpty { title = defaultTitle } }
                                .padding()

                            Divider().padding(.horizontal)

                            Button {
                                showLocationPicker = true
                            } label: {
                                HStack {
                                    Text(selectedLocation?.name ?? "Location")
                                        .foregroundColor(selectedLocation == nil ? .secondary : .primary)
                                    Spacer()
                                }
                                .padding()
                            }
                            .buttonStyle(.plain)
                        }
                        .background(Color.white)
                        .cornerRadius(12)

                        // Date/Time controls
                        VStack(spacing: 16) {
                            HStack {
                                Text("Starts")
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: $startDate,
                                    in: Date()...,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .labelsHidden()
                                .onChange(of: startDate) { _, _ in updateEndDateIfNeeded() }
                            }

                            Divider()

                            HStack {
                                Text("Ends")
                                Spacer()
                                DatePicker(
                                    "",
                                    selection: $endDate,
                                    in: startDate...,
                                    displayedComponents: [.date, .hourAndMinute]
                                )
                                .labelsHidden()
                            }
                        }
                        .padding()
                        .overlay(
                            RoundedRectangle(cornerRadius: 21)
                                .stroke(Color.socialButton, lineWidth: 1.5)
                        )

                        // Message
                        VStack(alignment: .leading, spacing: 16) {
                            Text("✍️ Write a quick message")
                                .font(.headline)

                            TextEditor(text: $message)
                                .frame(minHeight: 180)
                                .padding(12)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 21)
                                        .stroke(Color.socialButton, lineWidth: 1.5)
                                )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
                .scrollIndicators(.hidden)
                .scrollDismissesKeyboard(.interactively)
            }
        }
        // Pinned submit button at the bottom
        .safeAreaInset(edge: .bottom) {
            NextButton(
                title: meetupVM.isLoading ? "Creating..." : "Create Meet-Up",
                onTap: { Task { await createMeetup() } }
            )
            .disabled(meetupVM.isLoading || title.isEmpty || selectedLocation == nil)
            .padding(.horizontal)
            .padding(.vertical, 10)
            .background(.ultraThinMaterial)
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .onTapGesture { hideKeyboard() }

        // Alerts
        .alert("Error", isPresented: $meetupVM.showError) {
            Button("OK") { }
        } message: {
            Text(meetupVM.errorMessage)
        }
        .alert("Success", isPresented: $meetupVM.showSuccess) {
            Button("OK") { dismiss() }
        } message: {
            Text(meetupVM.successMessage)
        }

        // Location picker
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
