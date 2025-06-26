struct ConfirmLocationView: View {
    @StateObject private var locationManager = LocationManager()

    var body: some View {
        VStack {
            if let coordinate = locationManager.currentLocation {
                Map(coordinateRegion: .constant(
                    MKCoordinateRegion(
                        center: coordinate,
                        span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
                    )
                ), annotationItems: [coordinate]) { coord in
                    MapMarker(coordinate: coord)
                }
                .frame(height: 300)
            } else {
                ProgressView("Fetching location...")
            }

            Text("Detected City: \(locationManager.cityName)")
                .padding()

            Button("Confirm") {
                // Save locationManager.currentLocation and locationManager.cityName
            }
            .buttonStyle(.borderedProminent)
        }
        .onAppear {
            // request location on appear
        }
    }
}

//Preview
struct ConfirmLocationView_Previews: PreviewProvider {
    class MockLocationManager: LocationManager {
        override init() {
            super.init()
            self.currentLocation = CLLocationCoordinate2D(latitude: 51.5074, longitude: -0.1278) // London
            self.cityName = "London"
        }
    }

    static var previews: some View {
        ConfirmLocationView()
            .environmentObject(MockLocationManager())
    }
}

