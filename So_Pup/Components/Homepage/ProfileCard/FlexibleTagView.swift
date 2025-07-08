import SwiftUI

struct FlexibleTagView: View {
    let tags: [String]
    let showSeeMore: Bool
    let onSeeMoreTapped: (() -> Void)?
    let columns = [GridItem(.adaptive(minimum: 100), spacing: 2)]
    
    var body: some View {
        LazyVGrid(columns: columns, alignment: .leading, spacing: 8) {
            ForEach(displayedTags, id: \.self) { tag in
                Text(tag)
                    .font(.footnote)
                    .padding(.horizontal, 8)
                    .padding(.vertical, 8)
                    .frame(minWidth: 100)
                    .background(Color.socialAccent)
                    .foregroundColor(Color.socialText)
                    .cornerRadius(21)
            }
            if showSeeMore && tags.count > 8 {
                Button(action: {
                    onSeeMoreTapped?()
                }) {
                    Text("See more...")
                        .font(.caption)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 8)
                        .frame(minWidth: 100)
                        .background(Color.socialAccent)
                        .foregroundColor(.blue)
                        .cornerRadius(21)
                }
            }
        }
    }
    
    
    private var displayedTags: [String] {
        if showSeeMore && tags.count > 8 {
            return Array(tags.prefix(8))
        } else {
            return tags
        }
    }
}

#Preview {
    FlexibleTagView(
        tags: [
            "Chaser", "Wrestler", "Tugger", "Mouthy", "Parks", "Indoors",
            "High Energy", "Sensitive", "Ball-Obsessed", "Other"
        ],
        showSeeMore: true,
        onSeeMoreTapped: {
            print("Navigate to full profile")
        }
    )
    .padding()
}

