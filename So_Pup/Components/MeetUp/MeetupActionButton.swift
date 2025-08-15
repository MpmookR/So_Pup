import SwiftUI

enum MeetupAction {
    case accept
    case decline
    case cancel
    case complete
    case review
}

struct MeetupActionStyle {
    let title: String
    let iconName: String?
    let background: Color
    let foreground: Color
    let border: Color?
}

private extension MeetupAction {
    var style: MeetupActionStyle {
        switch self {
        case .accept:
            return .init(title: "Accept",
                         iconName: nil,
                         background: Color.socialAccent,
                         foreground: Color.socialText,
                         border: nil)
        case .decline:
            return .init(title: "Decline",
                         iconName: nil,
                         background: .white,
                         foreground: .black,
                         border: .red)
        case .cancel:
            return .init(title: "Cancel Meetup",
                         iconName: "trash",
                         background: .white,
                         foreground: .black,
                         border: .red)
        case .complete:
            return .init(title: "Mark as Complete",
                         iconName: "checkmark.circle.fill",
                         background: Color.puppyAccent,
                         foreground: .black,
                         border: nil)
        case .review:
            return .init(title: "Leave a Review",
                         iconName: "pencil",
                         background: Color.socialAccent,
                         foreground: Color.socialText,
                         border: nil)
        }
    }
}

struct MeetupActionButton: View {
    let actionType: MeetupAction
    var isEnabled: Bool = true
    var onTap: () -> Void

    var body: some View {
        let s = actionType.style

        SubmitButton(
            title: s.title,
            iconName: s.iconName,
            backgroundColor: s.background,
            foregroundColor: s.foreground,
            borderColor: s.border,
            action: onTap
        )
        .disabled(!isEnabled)                 // prefer this for a11y + consistency
        .opacity(isEnabled ? 1 : 0.6)         // optional visual hint
        .accessibilityLabel(Text(s.title))
    }
}
