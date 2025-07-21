import SwiftUI

struct BehaviourSelection: View {
    let title: String
    let options: [String]
    @Binding var selectedOptions: Set<String>
    var allowsMultipleSelection: Bool = true
    var showToggle: Bool = false
    var allowCustomTags: Bool = true
    
    @State private var isExpanded: Bool = true
    @State private var showingAddField: Bool = false
    @State private var newTag: String = ""
    
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 12)]

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            if showToggle {
                HStack {
                    Text(title)
                        .font(.headline)
                    Spacer()
                    Button(action: { withAnimation { isExpanded.toggle() } }) {
                        Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                            .foregroundColor(.socialText)
                    }
                }
            } else {
                Text(title)
                    .font(.headline)
            }

            if !showToggle || isExpanded {
                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(options, id: \.self) { option in
                        optionButton(option)
                    }

                    if allowCustomTags {
                        ForEach(Array(selectedOptions.subtracting(options)), id: \.self) { custom in
                            optionButton(custom)
                        }
                    }
                }

                if allowCustomTags {
                    if showingAddField {
                        TextField("Custom...", text: $newTag, onCommit: addCustomTag)
                            .padding(8)
                            .background(Color(.systemGray5))
                            .cornerRadius(99)
                            .frame(maxWidth: .infinity)
                    } else {
                        Button(action: {
                            withAnimation { showingAddField = true }
                        }) {
                            Text("Other")
                                .font(.body)
                                .padding(8.0)
                                .frame(maxWidth: .infinity)
                                .foregroundColor(Color.socialText)
                                .background(Color.socialAccent)
                                .cornerRadius(99)
                        }
                    }
                }
            }
        }
    }

    private func optionButton(_ option: String) -> some View {
        Button(action: {
            toggle(option)
        }) {
            Text(option)
                .font(.body)
                .padding(8.0)
                .frame(maxWidth: .infinity)
                .foregroundColor(Color.socialText)
                .background(Color.socialAccent)
                .overlay(
                    RoundedRectangle(cornerRadius: 99)
                        .stroke(selectedOptions.contains(option) ? Color.black : Color.clear, lineWidth: 3)
                )
                .cornerRadius(99)
        }
    }

    private func toggle(_ option: String) {
        if allowsMultipleSelection {
            if selectedOptions.contains(option) {
                selectedOptions.remove(option)
            } else {
                selectedOptions.insert(option)
            }
        } else {
            selectedOptions = [option]
        }
    }

    private func addCustomTag() {
        let trimmed = newTag.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }
        selectedOptions.insert(trimmed)
        newTag = ""
        showingAddField = false
    }
}
