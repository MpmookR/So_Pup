import SwiftUI

struct HomeView: View {
    @State private var showFilterSheet = false
    @State private var filterSettings = DogFilterSettings()
    
    // Mock data
    let dogs: [DogModel] = [MockDogData.dog1, MockDogData.dog2, MockDogData.dog3, MockDogData.dog4]
    let owners: [UserModel] = [MockUserData.user1, MockUserData.user2, MockUserData.user3, MockUserData.user4]
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                    
                    // MARK: - Scrollable Banner
                    Image("banner2")
                        .resizable()
                        .scaledToFill()
                        .frame(height: 200)
                        .frame(maxWidth: .infinity)
                        .clipped()
                        .ignoresSafeArea(edges: .top)
                    
                    // MARK: - Sticky Filter Bar
                    Section(header:
                        ZStack {
                            Color(.systemBackground)
                                .frame(maxWidth: .infinity)
                            
                            FilterBarView(filterSettings: filterSettings) {
                                showFilterSheet = true
                            }
                            .padding(.horizontal)

                        }
                    ){ForEach(0..<dogs.count, id: \.self) { index in
                            ProfileMatchCard(dog: dogs[index], owner: owners[index])
                                .padding(.horizontal)
                                .padding(.top, 16)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterDetailSheet(
                    filterSettings: $filterSettings,
                    onDismiss: { showFilterSheet = false }
                )
            }
        }
    }
}

#Preview {
    HomeView()
}


