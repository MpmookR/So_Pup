import SwiftUI

struct LabelTag: View {
    let text: String
    let icon: Image?
    let mode: DogMode
    var backgroundColor: Color? = nil
    var foregroundColor: Color? = nil

    var body: some View {
        HStack(spacing: 8) {
            if let icon = icon {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 16, height: 16)
            }
            
            Text(text)
        }
        .font(.subheadline)
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .frame(minWidth: 120, alignment: .leading)
        .background(backgroundColor ?? (mode == .puppy ? Color.puppyLight : Color.socialLight))
        .foregroundColor(foregroundColor ?? Color.socialText)
        .cornerRadius(21)
    }
}

#Preview{
    HStack {
        LabelTag(
            text: "Neutered",
            icon: Image(systemName: "shield.lefthalf.filled.badge.checkmark"),
            mode: .puppy,
            
        )
        
        LabelTag(
            text: "4 Years",
            icon: Image(systemName: "shield.lefthalf.filled.badge.checkmark"),
            mode: .social
        )
        
        LabelTag(
            text: "Shiba Inu",
            icon: Image(systemName: "pawprint"),
            mode: .social,
            backgroundColor: .red,
            foregroundColor: .white
            
        )
    }
    .padding(.horizontal)
}

