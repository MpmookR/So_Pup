import SwiftUI

// MARK: - Education Hub Section
struct EducationHubSection: View {
    let dogMode: DogMode
    @Binding var showAlert: Bool
    
    var body: some View {
        HStack(spacing: 16) {
            // Education Icon
            Image("edSection")
                .resizable()
                .aspectRatio(contentMode: .fit)
            .frame(width: 80, height: 80)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(Color.gray.opacity(0.3), lineWidth: 2)
                    .fill(dogMode == .puppy ? Color.puppyLight : Color.socialLight)
            )
            
            VStack(alignment: .leading, spacing: 4) {
                Text("Education Hub")
                    .font(.title3)
                    .fontWeight(.semibold)
                    .foregroundColor(Color.socialText)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Build confidence through daily discovery")
                        .font(.caption)
                        .foregroundColor(Color.socialText)
                }
            }
            
            Spacer()
            
            Image(systemName: "chevron.right")
                .font(.title3)
                .foregroundColor(Color.socialText)
        }
        .padding(16)
        .background(dogMode == .puppy ? Color.puppyLight : Color.socialLight)
        .cornerRadius(16)
        .contentShape(Rectangle()) // Ensures the entire area is tappable
        .onTapGesture {
            print("Education Hub tapped - setting showAlert to true")
            showAlert = true
        }
    }
}

#Preview {
    EducationHubSection(dogMode: .social, showAlert: .constant(false))
        .padding()
}


