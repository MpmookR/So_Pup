import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showFilterSheet = false
    @State private var filterSettings = DogFilterSettings()
    
    @StateObject private var matchingVM = MatchingViewModel()
    @State private var selectedProfile: MatchProfile? = nil
    
    @Environment(\.modelContext) private var modelContext
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
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
                            .frame(maxWidth: .infinity, alignment: .leading)
                            
                        }) {
                            // MARK: - No Matches
                            if matchingVM.matchedProfiles.isEmpty {
                                VStack(alignment: .center) {
                                    Text("No matches found 🐾")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.socialText)
                                        .font(.title3)
                                    Text("try expanding the distance or changing preferences")
                                        .fontWeight(.light)
                                        .foregroundColor(Color.socialText)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 56)
                                .padding(.horizontal)
                                
                            }
                            // MARK: - Match List
                            else if let viewerCoordinate = matchingVM.userCoordinate {
                                ForEach(matchingVM.matchedProfiles, id: \.dog.id) { profile in
                                    Button(action: {
                                        selectedProfile = profile
                                    }) {
                                        ProfileMatchCard(
                                            dog: profile.dog,
                                            owner: profile.owner,
                                            userCoordinate: Coordinate(from: viewerCoordinate)
                                        )
                                    }
                                    .buttonStyle(PlainButtonStyle())
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                }
                            } else {
                                Text("Fetching your location...")
                                    .foregroundColor(.gray)
                                    .padding(.top, 32)
                            }
                        }
                    }
                }
                // MARK: - NavigationLink
                .navigationDestination(isPresented: Binding(
                    get: { selectedProfile != nil },
                    set: { if !$0 { selectedProfile = nil } }
                )) {
                    if let profile = selectedProfile,
                       let viewerCoordinate = matchingVM.userCoordinate {
                        FullDogDetailsView(
                            dog: profile.dog,
                            owner: profile.owner,
                            userCoordinate: Coordinate(from: viewerCoordinate),
                            reviews: [] // Load reviews when Firestore is connected
                        )
                    }
                }
                
                .sheet(isPresented: $showFilterSheet) {
                    FilterDetailSheet(
                        filterSettings: $filterSettings,
                        onDismiss: {
                            showFilterSheet = false
                            filterService.saveFilterSettings(filterSettings) // Save with SwiftData
                            matchingVM.applyMatching(using: filterSettings)
                        }
                    )
                }
                .task {
                    filterSettings = filterService.loadFilterSettings()
                    await matchingVM.load()
                    matchingVM.applyMatching(using: filterSettings)
                }
            }
        }
    }
    
    private var filterService: DogFilterStorageService {
        DogFilterStorageService(context: modelContext)
    }

    private var selectedProfileView: some View {
        Group {
            if let profile = selectedProfile,
               let viewerCoordinate = matchingVM.userCoordinate {
                FullDogDetailsView(
                    dog: profile.dog,
                    owner: profile.owner,
                    userCoordinate: Coordinate(from: viewerCoordinate),
                    reviews: [] // Replace with actual reviews when loaded
                )
            } else {
                EmptyView()
            }
        }
    }
}

#Preview {
    HomeView()
}
