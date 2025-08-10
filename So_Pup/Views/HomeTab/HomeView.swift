import SwiftUI
import SwiftData

struct HomeView: View {
    @State private var showFilterSheet = false
    @State private var filterSettings = DogFilterSettings()
    
    @StateObject private var matchingVM = MatchingViewModel()
    @State private var selectedProfile: MatchProfile? = nil
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel
    
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
                        Section(
                            header:
                                ZStack {
                                    Color.white
                                    //                                        .frame(maxWidth: .infinity)
                                    
                                    FilterBarView(filterSettings: filterSettings) {
                                        showFilterSheet = true
                                    }
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color.white) // ensure no gaps
                                .zIndex(1)               // keep header above content
                        ){
                            // MARK: - No Matches
                            if matchingVM.matchedProfiles.isEmpty {
                                VStack(alignment: .center) {
                                    Text("No matches found 🐾")
                                        .fontWeight(.bold)
                                        .foregroundColor(Color.socialText)
                                        .font(.title3)
                                    Text("Try expanding the distance or changing preferences")
                                        .fontWeight(.light)
                                        .foregroundColor(Color.socialText)
                                        .font(.body)
                                        .multilineTextAlignment(.center)
                                }
                                .padding(.top, 56)
                                .padding(.horizontal)
                                
                            } else if let viewerCoordinate = matchingVM.userCoordinate {
                                // MARK: - Match List
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
                
                // MARK: - Navigation to FullDogDetailsView
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
                            reviews: [], // TODO: Load actual reviews from Firestore
                            matchRequestVM: matchRequestVM
                        )
                    }
                }
                
                // MARK: - Filter Sheet
                .sheet(isPresented: $showFilterSheet) {
                    FilterDetailSheet(
                        filterSettings: $filterSettings,
                        onDismiss: {
                            showFilterSheet = false
                            filterService.saveFilterSettings(filterSettings)
                        },
                        onApply: { scoredDogs in
                            matchingVM.updateScoredMatches(scoredDogs)
                        },
                        currentDog: matchingVM.currentDog,
                        candidateIds: matchingVM.candidateDogIds,
                        userCoordinate: matchingVM.userCoordinate.map(Coordinate.init)
                    )
                    .background(Color.white)
                }
                
                // MARK: - Load and Initialize Matching Data
                .task {
                    let savedFilter = filterService.loadFilterSettings()
                    filterSettings = savedFilter
                    await matchingVM.initialize(with: savedFilter)
                }
            }
        }
    }
    
    private var filterService: DogFilterStorageService {
        DogFilterStorageService(context: modelContext)
    }
}
