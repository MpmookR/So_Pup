import SwiftUI

struct FilterBarView: View {
    var filterSettings: DogFilterSettings
    var onFilterTapped: () -> Void

    let columns = Array(repeating: GridItem(.flexible(), spacing: 12), count: 3)

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // Header
            HStack {
                Text("Match Filter")
                    .font(.body)

                Spacer()

                Button(action: onFilterTapped) {
                    Image(systemName: "slider.horizontal.3")
                        .foregroundColor(Color.socialText)
                        .padding(8)
                        .background(Color.socialAccent)
                        .clipShape(Circle())
                }
            }

            // Filter grid
            LazyVGrid(columns: columns, spacing: 8) {
                // Distance (always visible)
                FilterLabel(
                    title: "Distance",
                    value: "< \(filterSettings.maxDistanceInKm) km",
                    isVisible: true,
                    isCustomized: filterSettings.maxDistanceInKm != 60
                )

                // Other tags (only title shown if selected)
                FilterLabel(
                    title: "Gender",
                    value: nil,
                    isVisible: filterSettings.selectedGender != nil,
                    isCustomized: true
                )

                FilterLabel(
                    title: "Size",
                    value: nil,
                    isVisible: !filterSettings.selectedSizes.isEmpty,
                    isCustomized: true
                )

                FilterLabel(
                    title: "Play Style",
                    value: nil,
                    isVisible: !filterSettings.selectedPlayStyleTags.isEmpty,
                    isCustomized: true
                )

                FilterLabel(
                    title: "Environment",
                    value: nil,
                    isVisible: !filterSettings.selectedEnvironmentTags.isEmpty,
                    isCustomized: true
                )

                FilterLabel(
                    title: "Trigger",
                    value: nil,
                    isVisible: !filterSettings.selectedTriggerTags.isEmpty,
                    isCustomized: true
                )

                FilterLabel(
                    title: "Health",
                    value: nil,
                    isVisible: filterSettings.selectedHealthStatus != nil,
                    isCustomized: true
                )
            }
        }
        .padding(.bottom, 8)
    }
}

struct FilterLabel: View {
    let title: String
    let value: String?
    var isVisible: Bool = true
    var isCustomized: Bool = false

    var body: some View {
        if isVisible {
            HStack(spacing: 4) {
                Text(title)
                    .foregroundColor(.black)
                if let value = value {
                    Text(": \(value)")
                        .fontWeight(.bold)
                }
            }
            .font(.caption)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .frame(minWidth: 125, alignment: .center)
            .background(isCustomized ? Color.socialLight : Color.socialAccent)
            .clipShape(Capsule())
        }
    }
}

#Preview("Default") {
    FilterBarView(
        filterSettings: DogFilterSettings(),
        onFilterTapped: { print("Filter tapped") }
    )
    .padding()
}

#Preview("With Filters") {
    FilterBarView(
        filterSettings: DogFilterSettings(
            maxDistanceInKm: 10,
            selectedGender: .male,
            selectedSizes: [.medium],
            selectedPlayStyleTags: ["Chaser"],
            selectedEnvironmentTags: ["Enclosed Park"],
            selectedTriggerTags: ["Loud noises"],
            selectedHealthStatus: .verified
        ),
        onFilterTapped: { print("Filter tapped") }
    )
    .padding()
}
