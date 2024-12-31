import SwiftUI
import CVCore
import CoreLocation

// When using navigation link, without a lazy view, all of the views are instantiated immediately.
// For a list of detail views navigation, that would mean that immediately network requests for all of the details would be made (both photos and get place details).
// SwiftUI navigation is the worst thing that has happened to **humanity**.
struct LazyView<Content: View>: View {
    let build: () -> Content

    init(_ build: @escaping () -> Content) {
        self.build = build
    }

    var body: Content {
        build()
    }
}

struct VenueListView: View {
    let venues: [Venue]
    let currentLocation: CLLocation
    weak var favoriteRepositoryDelegate: FavoriteRepositoryDelegate?

    init(venues: [Venue], currentLocation: CLLocation, favoriteRepositoryDelegate: FavoriteRepositoryDelegate?) {
        self.venues = venues
        self.currentLocation = currentLocation
        self.favoriteRepositoryDelegate = favoriteRepositoryDelegate
    }

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
            .frame(maxWidth: .infinity, maxHeight: .infinity)
        } else {
            ScrollView {
                VStack(spacing: 16) {
                    ForEach(sortedVenues, id: \.id) { venue in
                        NavigationLink(
                            destination: LazyView {
                                VenueDetailView(viewModel: VenueDetailViewModel(
                                    venueId: venue.id,
                                    venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
                                    userLocationService: ServiceLocator.shared.userLocationService
                                ))
                            }
                        ) {
                            VenueCellView(
                                venue: venue,
                                currentLocation: currentLocation,
                                favoriteRepositoryDelegate: favoriteRepositoryDelegate
                            )
                        }
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
