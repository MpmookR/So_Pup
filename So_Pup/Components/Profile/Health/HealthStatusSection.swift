import SwiftUI

// MARK: - Health Status Section
struct HealthStatusSection: View {
    @ObservedObject var profileEditVM: ProfileEditViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Status:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                Text(profileEditVM.dog.healthVerificationStatus.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(profileEditVM.dog.healthVerificationStatus == .verified ? .green : .red)
                
                Spacer()
                
                Image(systemName: profileEditVM.dog.healthVerificationStatus == .verified ? "checkmark.circle.fill" : "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundColor(profileEditVM.dog.healthVerificationStatus == .verified ? .green : .red)
            }
            
            HStack(spacing: 16) {
                // Health Icon
                Image(systemName: "cross.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color.socialText)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.socialLight))
                
                VStack(spacing: 12) {
                    HealthDatePicker(
                        title: "Flea Treatment",
                        subtitle: reminderText(for: profileEditVM.dog.healthStatus?.fleaTreatmentDate, reminderDays: 2),
                        date: profileEditVM.dog.healthStatus?.fleaTreatmentDate,
                        onDateSelected: { selectedDate in
                            Task {
                                await profileEditVM.updateFleaTreatmentDate(selectedDate)
                            }
                        }
                    )
                    .disabled(profileEditVM.isUpdating)
                    
                    HealthDatePicker(
                        title: "Worming Treatment",
                        subtitle: reminderText(for: profileEditVM.dog.healthStatus?.wormingTreatmentDate, reminderDays: 81),
                        date: profileEditVM.dog.healthStatus?.wormingTreatmentDate,
                        onDateSelected: { selectedDate in
                            Task {
                                await profileEditVM.updateWormingTreatmentDate(selectedDate)
                            }
                        }
                    )
                    .disabled(profileEditVM.isUpdating)
                }
            }
            
            if profileEditVM.isUpdating {
                HStack {
                    ProgressView()
                        .scaleEffect(0.8)
                    Text("Updating health status...")
                        .font(.caption)
                        .foregroundColor(Color.socialText)
                }
                .padding(.top, 4)
            }
        }
        .padding(16)
        .background(Color.socialLight)
        .cornerRadius(16)
        .alert("Health Update Error", isPresented: $profileEditVM.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(profileEditVM.errorMessage)
        }
    }
    
    private func reminderText(for date: Date?, reminderDays: Int) -> String {
        guard let date = date else { return "Not completed" }
        let daysSince = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        let daysUntilReminder = reminderDays - daysSince
        
        if daysUntilReminder <= 0 {
            return "Due now"
        } else {
            return "Reminder: Due in \(daysUntilReminder) days"
        }
    }
}

