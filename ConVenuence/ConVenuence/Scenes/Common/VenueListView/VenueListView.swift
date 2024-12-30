import SwiftUI
import CVCore

struct VenueListView: View {
    let venues: [Venue]

    var body: some View {
        List(venues, id: \ .id) { venue in
            VenueCellView(venue: venue)
        }
    }
}
