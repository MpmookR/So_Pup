import SwiftUI

struct LanguageSelector: View {
    @Binding var selectedLanguages: [String]
    let allLanguages: [String]
    let allowCustomLanguage: Bool
    var maxSelection: Int? = nil

    @State private var showLanguageMenu = false
    @State private var showCustomLanguageInput = false
    @State private var customLanguageText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("What languages do you speak?")
                .font(.body)

            FlowLayout(alignment: .leading, spacing: 12) {
                // Add Language Button
                Button {
                    showLanguageMenu = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle.fill")
                            .foregroundColor(Color.socialButton)
                        Text("add language")
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.socialAccent)
                    .cornerRadius(99)
                }

                // Language Chips
                ForEach(selectedLanguages, id: \.self) { language in
                    HStack(spacing: 8) {
                        Image(systemName: "minus.circle")
                        Text(language)
                    }
                    .padding(.horizontal)
                    .padding(.vertical, 8)
                    .background(Color.socialAccent.opacity(0.5))
                    .cornerRadius(99)
                    .onTapGesture {
                        selectedLanguages.removeAll { $0 == language }
                    }
                }
            }
        }
        .confirmationDialog("Select Language", isPresented: $showLanguageMenu, titleVisibility: .visible) {
            ForEach(allLanguages.filter { !selectedLanguages.contains($0) }, id: \.self) { language in
                Button(language) {
                    if maxSelection == nil || selectedLanguages.count < maxSelection! {
                        selectedLanguages.append(language)
                    }
                }
            }

            if allowCustomLanguage {
                Button("Other") {
                    showCustomLanguageInput = true
                }
            }
        }
        .alert("Enter language", isPresented: $showCustomLanguageInput) {
            TextField("Language", text: $customLanguageText)
            Button("Add") {
                let trimmed = customLanguageText.trimmingCharacters(in: .whitespacesAndNewlines)
                if !trimmed.isEmpty && !selectedLanguages.contains(trimmed) {
                    selectedLanguages.append(trimmed)
                }
                customLanguageText = ""
            }
            Button("Cancel", role: .cancel) {
                customLanguageText = ""
            }
        }
    }
}

struct FlowLayout<Content: View>: View {
    let alignment: HorizontalAlignment
    let spacing: CGFloat
    let content: () -> Content

    init(alignment: HorizontalAlignment = .leading, spacing: CGFloat = 8, @ViewBuilder content: @escaping () -> Content) {
        self.alignment = alignment
        self.spacing = spacing
        self.content = content
    }

    var body: some View {
        LazyVGrid(columns: [GridItem(.adaptive(minimum: 140), spacing: spacing)], alignment: alignment, spacing: spacing) {
            content()
        }
    }
}
