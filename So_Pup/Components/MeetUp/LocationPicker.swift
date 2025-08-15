import SwiftUI
import MapKit
import CoreLocation

struct LocationPicker: View {
    @Environment(\.dismiss) var dismiss
    @Binding var selectedLocation: LocationData?
    
    @State private var locationService = LocationService()
    @State private var searchText = ""
    @State private var searchResults: [MKMapItem] = []
    @State private var isSearching = false
    @State private var showCurrentLocation = false
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Search Bar
                HStack {
                    Image(systemName: "magnifyingglass")
                        .foregroundColor(.gray)
                    
                    TextField("Enter Location", text: $searchText)
                        .textFieldStyle(PlainTextFieldStyle())
                        .onChange(of: searchText) { _, newValue in
                            Task {
                                await performSearch(query: newValue)
                            }
                        }
                    
                    if !searchText.isEmpty {
                        Button("Clear") {
                            searchText = ""
                            searchResults = []
                        }
                        .foregroundColor(.blue)
                    }
                }
                .padding()
                .background(Color(.systemGray6))
                .cornerRadius(10)
                .padding(.horizontal)
                
                // Current Location Option
                Button {
                    Task {
                        await selectCurrentLocation()
                    }
                } label: {
                    HStack {
                        Image(systemName: "location.fill")
                            .foregroundColor(.blue)
                            .frame(width: 24, height: 24)
                        
                        VStack(alignment: .leading) {
                            Text("Current Location")
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text("Use your current location")
                                .font(.caption)
                                .foregroundColor(.secondary)
                        }
                        
                        Spacer()
                    }
                    .padding()
                }
                .buttonStyle(PlainButtonStyle())
                .background(Color(.systemBackground))
                
                Divider()
                
                // Search Results
                if isSearching {
                    HStack {
                        ProgressView()
                            .scaleEffect(0.8)
                        Text("Searching...")
                            .foregroundColor(.secondary)
                    }
                    .padding()
                } else if !searchResults.isEmpty {
                    List(searchResults, id: \.self) { mapItem in
                        Button {
                            selectLocation(mapItem)
                        } label: {
                            HStack {
                                Image(systemName: "mappin.circle.fill")
                                    .foregroundColor(.red)
                                    .frame(width: 24, height: 24)
                                
                                VStack(alignment: .leading, spacing: 4) {
                                    Text(mapItem.name ?? "Unknown Location")
                                        .font(.headline)
                                        .foregroundColor(.primary)
                                    
                                    if let address = mapItem.placemark.title {
                                        Text(address)
                                            .font(.caption)
                                            .foregroundColor(.secondary)
                                            .lineLimit(2)
                                    }
                                }
                                
                                Spacer()
                            }
                        }
                        .buttonStyle(PlainButtonStyle())
                    }
                } else if !searchText.isEmpty && !isSearching {
                    VStack(spacing: 16) {
                        Image(systemName: "magnifyingglass")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("No locations found")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Try a different search term")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                } else {
                    VStack(spacing: 16) {
                        Image(systemName: "mappin.and.ellipse")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        
                        Text("Search for a location")
                            .font(.headline)
                            .foregroundColor(.primary)
                        
                        Text("Enter a place name, address, or landmark")
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                Spacer()
            }
            .navigationTitle("Select Location")
            .navigationBarTitleDisplayMode(.inline)
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    private func performSearch(query: String) async {
        guard !query.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            searchResults = []
            return
        }
        
        isSearching = true
        
        do {
            let results = try await locationService.searchLocations(query: query)
            await MainActor.run {
                searchResults = results
                isSearching = false
            }
        } catch {
            await MainActor.run {
                searchResults = []
                isSearching = false
            }
            print("Location search failed: \(error)")
        }
    }
    
    private func selectCurrentLocation() async {
        do {
            let mapItem = try await locationService.getCurrentLocationMapItem()
            await MainActor.run {
                selectedLocation = LocationData(
                    name: mapItem.name ?? "Current Location",
                    coordinate: mapItem.placemark.coordinate,
                    address: mapItem.placemark.title
                )
                dismiss()
            }
        } catch {
            print("Failed to get current location: \(error)")
        }
    }
    
    private func selectLocation(_ mapItem: MKMapItem) {
        selectedLocation = LocationData(
            name: mapItem.name ?? "Selected Location",
            coordinate: mapItem.placemark.coordinate,
            address: mapItem.placemark.title
        )
        dismiss()
    }
}

// MARK: - Location Data Model
struct LocationData: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let coordinate: CLLocationCoordinate2D
    let address: String?
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: LocationData, rhs: LocationData) -> Bool {
        lhs.id == rhs.id
    }
}

#Preview {
    LocationPicker(selectedLocation: .constant(nil))
}


