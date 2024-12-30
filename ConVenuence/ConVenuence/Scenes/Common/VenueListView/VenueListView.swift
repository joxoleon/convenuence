import SwiftUI
import CVCore
import CoreLocation

struct VenueListView: View {
    let venues: [Venue]
    let currentLocation: CLLocation

    // I know that the API can sort this, but in case of offline acces, I still want to display the correct distance and ordering
    var sortedVenues: [Venue] {
        venues.sorted { (v2, v1) -> Bool in
            v1.distance(from: currentLocation) > v2.distance(from: currentLocation)
        }
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                ForEach(sortedVenues, id: \ .id) { venue in
                    VenueCellView(venue: venue, currentLocation: currentLocation)
                        .padding(.horizontal)
                }
            }
        }
        .padding(.top)
    }
}

struct VenueListView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()

            VenueListView(
                venues: [
                    Venue.sample1,
                    Venue.sample2,
                    Venue.sample3
                ],
                currentLocation: CLLocation(latitude: 40.7128, longitude: -74.0060)
            )
        }
    }
}
