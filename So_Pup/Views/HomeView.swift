import SwiftUI

struct HomeView: View {
    @State private var showFilterSheet = false
    @State private var filterSettings = DogFilterSettings()
    
    @StateObject private var matchingVM = MatchingViewModel()
    
    
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
                        
                    ){
                        ForEach(matchingVM.matchedProfiles, id: \.dog.id) { profile in
                            ProfileMatchCard(dog: profile.dog, owner: profile.owner)
                                .padding(.horizontal)
                                .padding(.top, 16)
                        }
                    }
                }
            }
            .sheet(isPresented: $showFilterSheet) {
                FilterDetailSheet(
                    filterSettings: $filterSettings,
                    onDismiss: {
                        showFilterSheet = false
                        matchingVM.applyMatching(using: filterSettings)
                    }
                )
            }
            
            // MARK: fetch from fireStore
            .task {
                await matchingVM.load()
            }
        }
    }
}

#Preview {
    HomeView()
}


