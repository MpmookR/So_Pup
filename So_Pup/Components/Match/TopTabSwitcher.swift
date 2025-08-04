import SwiftUI

struct TopTabSwitcher: View {
    let tabs: [String]
    @Binding var selectedTab: String
    var backgroundColor: Color = Color(Color.socialLight)
    var activeColor: Color = .black
    var inactiveColor: Color = .gray
    var underlineColor: Color = Color.socialAccent
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(tabs, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Text(tab)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(selectedTab == tab ? activeColor : inactiveColor)

                        Rectangle()
                            .frame(height: 2)
                            .foregroundColor(selectedTab == tab ? underlineColor : .clear)
                    }
                    .frame(maxWidth: .infinity)
                }
            }
        }
        .padding(.vertical, 12)
        .background(backgroundColor)
    }
}

#Preview {
    StatefulPreviewWrapper("Chat") { selectedTab in
        TopTabSwitcher(
            tabs: ["Chat", "Meet-up"],
            selectedTab: selectedTab
        )
        .padding()
        .background(Color.white)
    }
}

struct StatefulPreviewWrapper<Value, Content: View>: View {
    @State private var value: Value
    private let content: (Binding<Value>) -> Content

    init(_ initialValue: Value, @ViewBuilder content: @escaping (Binding<Value>) -> Content) {
        self._value = State(initialValue: initialValue)
        self.content = content
    }

    var body: some View {
        content($value)
    }
}




