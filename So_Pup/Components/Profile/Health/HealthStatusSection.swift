import SwiftUI

// MARK: - Health Status Section
struct HealthStatusSection: View {
    let dog: DogModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Status:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                Text(dog.healthVerificationStatus.rawValue.capitalized)
                    .font(.subheadline)
                    .foregroundColor(dog.healthVerificationStatus == .verified ? .green : .red)
                
                Spacer()
                
                Image(systemName: dog.healthVerificationStatus == .verified ? "checkmark.circle.fill" : "exclamationmark.triangle")
                    .font(.title3)
                    .foregroundColor(dog.healthVerificationStatus == .verified ? .green : .red)
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
                        subtitle: reminderText(for: dog.healthStatus?.fleaTreatmentDate, reminderDays: 2),
                        date: dog.healthStatus?.fleaTreatmentDate
                    )
                    
                    HealthDatePicker(
                        title: "Worming Treatment",
                        subtitle: reminderText(for: dog.healthStatus?.wormingTreatmentDate, reminderDays: 81),
                        date: dog.healthStatus?.wormingTreatmentDate
                    )
                }
            }
        }
        .padding(16)
        .background(Color.socialLight)
        .cornerRadius(16)
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

