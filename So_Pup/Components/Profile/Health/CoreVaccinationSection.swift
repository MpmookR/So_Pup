import SwiftUI

// MARK: - Core Vaccination Section
// Uses VaccinationRow component for individual vaccination entries
struct CoreVaccinationSection: View {
    @ObservedObject var dogModeSwitcher: DogModeSwitcherViewModel
    @State private var showVetNotice = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Pup's Core Vaccination")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                Spacer()
                
                Button(action: {
                    showVetNotice = true
                }) {
                    Image(systemName: "info.circle")
                        .font(.title3)
                        .foregroundColor(Color.socialText)
                }
            }
            
            HStack(spacing: 16) {
                // Vaccination Icon
                Image(systemName: "cross.fill")
                    .font(.largeTitle)
                    .foregroundColor(Color.socialText)
                    .frame(width: 60, height: 60)
                    .background(Circle().fill(Color.socialLight))
                
                VStack(spacing: 12) {
                    VaccinationRow(
                        title: "First Vaccination",
                        date: dogModeSwitcher.dog.coreVaccination1Date,
                        isCompleted: dogModeSwitcher.dog.coreVaccination1Date != nil,
                        onDateSelected: { selectedDate in
                            Task {
                                await dogModeSwitcher.updateFirstVaccination(date: selectedDate)
                            }
                        }
                    )
                    .disabled(dogModeSwitcher.isUpdating)
                    
                    VaccinationRow(
                        title: "Second Vaccination",
                        date: dogModeSwitcher.dog.coreVaccination2Date,
                        isCompleted: dogModeSwitcher.dog.coreVaccination2Date != nil,
                        onDateSelected: { selectedDate in
                            Task {
                                await dogModeSwitcher.updateSecondVaccination(date: selectedDate)
                            }
                        }
                    )
                    .disabled(dogModeSwitcher.isUpdating)
                    
                    if dogModeSwitcher.isUpdating {
                        HStack {
                            ProgressView()
                                .scaleEffect(0.8)
                            Text("Updating vaccination...")
                                .font(.caption)
                                .foregroundColor(Color.socialText)
                        }
                        .padding(.top, 4)
                    }
                }
            }
            

        }
        .padding(16)
        .background(Color.puppyLight)
        .cornerRadius(16)
        .alert("Veterinary Notice", isPresented: $showVetNotice) {
            Button("OK") { }
        } message: {
            Text("Please consult with your veterinarian for proper core vaccination dosage and schedule advice. Core vaccinations are essential for your puppy's health and protection against serious diseases.")
        }
        .alert("Vaccination Update Error", isPresented: $dogModeSwitcher.showErrorAlert) {
            Button("OK") { }
        } message: {
            Text(dogModeSwitcher.errorMessage)
        }

    }
}


