import SwiftUI

// MARK: - Health Status Section (DogProfileEditorViewModel-based)
struct HealthStatusSection: View {
    @ObservedObject var vm: DogProfileEditorViewModel

    // Derive a verification status from current draft dates
    private var isVerified: Bool {
        vm.fleaTreatmentDate != nil && vm.wormingTreatmentDate != nil
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
                        subtitle: reminderText(for: vm.fleaTreatmentDate, reminderDays: 30),
                        date: vm.fleaTreatmentDate,
                        onDateSelected: { selectedDate in
                            Task { await vm.setHealthDates(flea: selectedDate, worming: vm.wormingTreatmentDate)}
                        }
                    )
                    .disabled(vm.isSavingHealth)

                    HealthDatePicker(
                        title: "Worming Treatment",
                        subtitle: reminderText(for: vm.wormingTreatmentDate, reminderDays: 90),
                        date: vm.wormingTreatmentDate,
                        onDateSelected: { selectedDate in
                            Task { await vm.setHealthDates(flea: vm.fleaTreatmentDate, worming: selectedDate) }
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

    private func reminderText(for lastDate: Date?, reminderDays: Int) -> String {
        guard let lastDate else { return "Not completed" }
        let cal = Calendar.current
        let today = cal.startOfDay(for: Date())
        let last = cal.startOfDay(for: lastDate)

        guard let nextDue = cal.date(byAdding: .day, value: reminderDays, to: last) else { return "—" }
        let days = cal.dateComponents([.day], from: today, to: nextDue).day ?? 0

        switch days {
        case Int.min..<0:
            return "Overdue by \(-days) days"
        case 0:
            return "Due today"
        case 1:
            return "Due tomorrow"
        default:
            return "Due in \(days) days"
        }
    }

}
