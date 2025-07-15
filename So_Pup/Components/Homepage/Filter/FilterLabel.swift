import SwiftUI

struct FilterLabel: View {
    let title: String
    let value: String?
    var isVisible: Bool = true
    var isCustomized: Bool = false
    
    var body: some View {
        if isVisible {
            HStack(spacing:1){
                Text(title)
                    .foregroundColor(.black)
                if let value = value {
                    Text(": \(value)")
                        .fontWeight(.bold)
                        .foregroundColor(.black)
                }
            }
            .font(.caption)
            .padding(.horizontal, 4)
            .padding(.vertical, 4)
            .frame(minWidth: 123, alignment: .center)
            .background(isCustomized ? Color.socialAccent : Color.socialLight)
            .clipShape(Capsule())
        }
    }
}
