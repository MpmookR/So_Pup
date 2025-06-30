import SwiftUI

struct CustomDatePicker: View {
    enum DateRule {
        case noPast, noFuture, any
    }
    
    let title: String
    let placeholder: String
    @Binding var selectedDate: Date
    var dateRule: DateRule = .any
    var includeTime: Bool = false
    
    @State private var showPicker = false
    
    private var dateRange: ClosedRange<Date> {
        let now = Date()
        switch dateRule {
        case .noPast:
            return now...Date.distantFuture
        case .noFuture:
            return Date.distantPast...now
        case .any:
            return Date.distantPast...Date.distantFuture
        }
    }
    
    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        if includeTime {
            formatter.timeStyle = .short
        }
        return formatter.string(from: selectedDate)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.body)
                .foregroundColor(Color.socialText)
            
            Button(action: {
                withAnimation { showPicker.toggle() }
            }) {
                HStack {
                    Text(showPicker ? placeholder : formattedDate)
                        .foregroundColor(.primary)
                    Spacer()
                    Image(systemName: showPicker ? "chevron.up" : "chevron.down")
                        .foregroundColor(.gray)
                }
                .padding()
                .background(Color.socialAccent)
                .cornerRadius(99)
            }
            
            if showPicker {
                DatePicker(
                    "",
                    selection: $selectedDate,
                    in: dateRange,
                    displayedComponents: includeTime ? [.date, .hourAndMinute] : [.date]
                )
                .datePickerStyle(WheelDatePickerStyle())
                .labelsHidden()
                .frame(maxWidth: .infinity)
                .clipped()
                .transition(.opacity.combined(with: .slide))
            }
        }
    }
}

struct CustomDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 40) {
            CustomDatePicker(
                title: "Puppy DOB",
                placeholder: "Select date...",
                selectedDate: .constant(Date()),
                dateRule: .noFuture,
                includeTime: false
            )
            
            CustomDatePicker(
                title: "Meet-up Date & Time",
                placeholder: "Select date & time...",
                selectedDate: .constant(Date()),
                dateRule: .noPast,
                includeTime: true
            )
        }
        .padding()
        .previewLayout(.sizeThatFits)
    }
}
