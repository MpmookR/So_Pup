import SwiftUI

struct OnboardingProgressBar: View {
    
    var progress: CGFloat // value from 0 to 1
    var showBackButton: Bool
    var onBack: (() -> Void)?
    
    var body: some View {
        HStack(alignment: .center, spacing: 16) {
            if showBackButton {
                Button(action: onBack ?? {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.black)
                }
            }
            
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.socialButton.opacity(0.3))
                        .frame(height: 4)
                    
                    Capsule()
                        .fill(Color.socialButton)
                        .frame(width: geometry.size.width * progress, height: 4)
                }
            }
            .frame(height: 4) // capsule height
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .frame(height: 32)
    }
}

#Preview {
    OnboardingProgressBar(
        progress: 0.5,
        showBackButton: true,
        onBack: {
            print("Back tapped")
        }
    )
    .padding(.horizontal)
    
}


