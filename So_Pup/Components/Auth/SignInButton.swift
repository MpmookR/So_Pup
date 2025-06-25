import SwiftUI

struct SignInButton: View {
    let title: String
    let icon: Image
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(alignment: .center, spacing: 21) {
                icon
                    .resizable()
                    .scaledToFit()
                    .frame(width: 20, height: 20)
                Text(title)
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.black)
            }
            .padding(.horizontal, 15)
            .frame(maxWidth: .infinity, minHeight: 40, maxHeight: 40)
            .background(Color.white)
            .cornerRadius(21)
            .overlay(
                RoundedRectangle(cornerRadius: 21)
                    .stroke(Color.black, lineWidth: 1)
            )
        }
    }
}
