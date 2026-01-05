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
    @State private var showRetry = false                        // show a retry button when first load fails / returns empty
    
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @EnvironmentObject var matchRequestVM: MatchRequestViewModel
    @EnvironmentObject var matchingVM: MatchingViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()
                
                //  Pull-to-refresh to re-run scoring without killing the app
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
                            else if matchingVM.userCoordinate == nil {
                                // Waiting for user’s location (first launch)
                                VStack(spacing: 12) {
                                    ProgressView()
                                    //                                    ProgressView().controlSize(.regular)
                                    Text("Fetching your location…")
                                        .foregroundColor(.gray)
                                }
                                .padding(.top, 32)
                            }
                            
                            else if let viewerCoordinate = matchingVM.userCoordinate,
                                    !matchingVM.matchedProfiles.isEmpty {
                                // Prefer positive path first: show list when we have items + coordinate
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
                            
                            else if matchingVM.hasLoadedOnce {
                                // Empty/error state after data has loaded at least once
                                VStack(spacing: 12) {
                                    Text("No matches found 🐾")
                                        .font(.title3).fontWeight(.bold)
                                        .foregroundColor(Color.socialText)
                                    Text("Try expanding the distance or changing preferences.")
                                        .foregroundColor(.gray)
                                        .multilineTextAlignment(.center)
                                    
                                    // One-tap retry covers token refresh / cold start / location race
                                    Button {
                                        Task {
                                            await matchingVM.applyScoring(using: filterSettings)
                                        }
                                    } label: {
                                        Text("Retry search")
                                    }
                                    .buttonStyle(.bordered)
                                }
                                .padding(.top, 56)
                                .padding(.horizontal)
                            }
                            
                        }
                    }
                }
            }
            //  Native pull-to-refresh to re-run with current filters
            .refreshable {
                await matchingVM.applyScoring(using: filterSettings)
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
                    // Re-run scoring when filters are dismissed (keeps view in sync)
                    Task { await matchingVM.applyScoring(using: filterSettings) }
                },
                onApply: { scoredDogs in
                    // Keeps instant feedback when the sheet runs local scoring
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
            
            // Avoid duplicate work if a load is already in progress
            if !matchingVM.isLoading,
               (!matchingVM.hasLoadedOnce || matchingVM.filterSettings != savedFilter) {
                await matchingVM.initialize(with: savedFilter)
            }
        }
        
        // Smooth animation between loading/empty/match states
        .animation(.easeInOut, value: matchingVM.isLoading)
        .animation(.easeInOut, value: matchingVM.matchedProfiles.count)
    }
    
    private var filterService: DogFilterStorageService {
        DogFilterStorageService(context: modelContext)
    }
}

