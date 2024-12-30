import SwiftUI
import CVCore
import CoreLocation

struct VenueListView: View {
    let venues: [Venue]
    let currentLocation: CLLocation
    weak var favoriteRepositoryDelegate: FavoriteRepositoryDelegate?

    init(venues: [Venue], currentLocation: CLLocation, favoriteRepositoryDelegate: FavoriteRepositoryDelegate?) {
        self.venues = venues
        self.currentLocation = currentLocation
        self.favoriteRepositoryDelegate = favoriteRepositoryDelegate
    }

    // Sort venues by distance for offline access
    var sortedVenues: [Venue] {
        venues.sorted { (v2, v1) -> Bool in
            v1.distance(from: currentLocation) > v2.distance(from: currentLocation)
        }
    }

    var body: some View {
        if sortedVenues.isEmpty {
            VStack {
                Spacer()
                Text("No Search Results")
                    .font(.title3)
                    .foregroundColor(.accentBlue)
                    .multilineTextAlignment(.center)
                    .opacity(0.6)
                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity) // Ensure centering
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(sortedVenues, id: \.id) { venue in
                        VenueCellView(
                            venue: venue,
                            currentLocation: currentLocation,
                            favoriteRepositoryDelegate: favoriteRepositoryDelegate
                        )
                        .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
        }
    }
}

struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VenueListView(
                venues: [],
                currentLocation: CLLocation(latitude: 40.7128, longitude: -74.0060),
                favoriteRepositoryDelegate: nil
            )
        }
    }
}
