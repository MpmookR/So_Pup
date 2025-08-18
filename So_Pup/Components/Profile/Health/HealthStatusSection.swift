import SwiftUI

// MARK: - Health Status Section (DogProfileEditorViewModel-based)
struct HealthStatusSection: View {
    @ObservedObject var vm: DogProfileEditorViewModel

    // Derive a verification status from current draft dates
    private var isVerified: Bool {
        vm.fleaTreatmentDate != nil || vm.wormingTreatmentDate != nil
    }
    private var statusText: String { isVerified ? "Verified" : "Unverified" }
    private var statusColor: Color { isVerified ? .green : .red }
    private var statusIcon: String { isVerified ? "checkmark.circle.fill" : "exclamationmark.triangle" }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Health Status:")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)

                Text(statusText)
                    .font(.subheadline)
                    .foregroundColor(statusColor)

                Spacer()

                Image(systemName: statusIcon)
                    .font(.title3)
                    .foregroundColor(statusColor)
            }

            HStack(spacing: 16) {
                Image(systemName: "cross.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color.socialText)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.socialLight))

                VStack(spacing: 12) {
                    HealthDatePicker(
                        title: "Flea Treatment",
                        subtitle: reminderText(for: vm.fleaTreatmentDate, reminderDays: 2),
                        date: vm.fleaTreatmentDate,
                        onDateSelected: { selectedDate in
                            Task { await vm.setFleaTreatmentDate(selectedDate) }
                        }
                    )
                    .disabled(vm.isSavingHealth)

                    HealthDatePicker(
                        title: "Worming Treatment",
                        subtitle: reminderText(for: vm.wormingTreatmentDate, reminderDays: 81),
                        date: vm.wormingTreatmentDate,
                        onDateSelected: { selectedDate in
                            Task { await vm.setWormingTreatmentDate(selectedDate) }
                        }
                    )
                    .disabled(vm.isSavingHealth)
                }
            }

            if vm.isSavingHealth {
                HStack {
                    ProgressView().scaleEffect(0.8)
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
        .alert("Health Update Error", isPresented: $vm.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(vm.errorMessage ?? "Unknown error")
        }
    }

    private func reminderText(for date: Date?, reminderDays: Int) -> String {
        guard let date else { return "Not completed" }
        let daysSince = Calendar.current.dateComponents([.day], from: date, to: Date()).day ?? 0
        let daysUntilReminder = reminderDays - daysSince
        return daysUntilReminder <= 0 ? "Due now" : "Reminder: Due in \(daysUntilReminder) days"
    }
}
