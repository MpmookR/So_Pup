import SwiftUI

struct MeetupListSection: View {
    @EnvironmentObject var meetupVM: MeetupViewModel
    @State private var selectedTab: Int = 0
    
    var body: some View {
        MeetupListView()
    }
}

