import SwiftUI
import SwiftData
//
//  Displays the main homepage where users can browse potential dog matches.
//
//  - Banner at the top
//  - Sticky filter bar to open filter sheet
//  - Match list (with loading and empty states)
//  - Navigation to full dog profile details
//  - Filter sheet for refining match results
//
struct HomeView: View {
    @State private var showFilterSheet = false                  // controls filter sheet presentation
    @State private var filterSettings = DogFilterSettings()     // local copy of filter settings
    @State private var selectedProfile: MatchProfile? = nil     // track selected profile for navigation
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel
    @EnvironmentObject var matchingVM: MatchingViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                ScrollView {
                    LazyVStack(spacing: 0, pinnedViews: [.sectionHeaders]) {
                        
                        // MARK: - Top Banner
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
                                    FilterBarView(filterSettings: filterSettings) {
                                        showFilterSheet = true
                                    }
                                    .padding(.horizontal)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                }
                                .frame(maxWidth: .infinity)
                                .background(Color.white)
                                .zIndex(1) // keep header above content
                        ) {
                            // MARK: - Match State Handling
                            
                            if matchingVM.isLoading {
                                // Loading spinner while matches are being fetched
                                VStack(spacing: 12) {
                                    ProgressView().controlSize(.large)
                                    Text("Finding matches…")
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 56)
                            }
                            else if matchingVM.matchedProfiles.isEmpty && matchingVM.hasLoadedOnce {
                                // Empty state after data has loaded at least once
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
                            }
                            else if let viewerCoordinate = matchingVM.userCoordinate {
                                // Show match list if profiles exist
                                ForEach(matchingVM.matchedProfiles, id: \.dog.id) { profile in
                                    Button { selectedProfile = profile } label: {
                                        ProfileMatchCard(
                                            dog: profile.dog,
                                            owner: profile.owner,
                                            userCoordinate: Coordinate(from: viewerCoordinate)
                                        )
                                    }
                                    .buttonStyle(.plain)
                                    .padding(.horizontal)
                                    .padding(.top, 16)
                                }
                            }
                            else {
                                // Waiting for user’s location
                                VStack(spacing: 12) {
                                    ProgressView().controlSize(.regular)
                                    Text("Fetching your location…")
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 32)
                            }
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
                        userCoordinate: Coordinate(from: viewerCoordinate)
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
                if !matchingVM.hasLoadedOnce || matchingVM.filterSettings != savedFilter {
                    await matchingVM.initialize(with: savedFilter)
                }            }
            
            // Smooth animation between loading/empty/match states
            .animation(.easeInOut, value: matchingVM.isLoading)
            .animation(.easeInOut, value: matchingVM.matchedProfiles.count)
        }
    }
    
    private var filterService: DogFilterStorageService {
        DogFilterStorageService(context: modelContext)
    }
}
