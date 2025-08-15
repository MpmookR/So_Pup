import SwiftUI

// MARK: - Vaccination Row
struct VaccinationRow: View {
    let title: String
    let date: Date?
    let isCompleted: Bool
    let onDateSelected: (Date) -> Void
    
    @State private var showDatePicker = false
    @State private var selectedDate = Date()
    
    var body: some View {
        HStack {
            Text(title)
                .font(.subheadline)
                .foregroundColor(Color.socialText)
            
            Spacer()
            
            Button(action: {
                selectedDate = date ?? Date()
                showDatePicker = true
            }) {
                if isCompleted, let date = date {
                    Text(DateFormatter.shortDate.string(from: date))
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.socialLight)
                        .foregroundColor(.black)
                        .cornerRadius(8)
                } else {
                    Text("mm dd, yyyy")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(Color.socialLight)
                        .foregroundColor(.gray)
                        .cornerRadius(8)
                }
            }
        }
        .sheet(isPresented: $showDatePicker) {
            NavigationView {
                VStack(spacing: 20) {
                    Text("Select \(title) Date")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .padding(.top)
                    
                    DatePicker(
                        "Vaccination Date",
                        selection: $selectedDate,
                        in: ...Date(),
                        displayedComponents: .date
                    )
                    .datePickerStyle(.wheel)
                    .labelsHidden()
                    
                    Spacer()
                }
                .padding()
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Cancel") {
                            showDatePicker = false
                        }
                    }
                    
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Save") {
                            onDateSelected(selectedDate)
                            showDatePicker = false
                        }
                        .fontWeight(.semibold)
                    }
                }
            }
            .presentationDetents([.medium])
        }
    }
}

