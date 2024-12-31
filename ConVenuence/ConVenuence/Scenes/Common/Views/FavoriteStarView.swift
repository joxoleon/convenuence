import CVCore
import SwiftUI

@MainActor
protocol FavoriteRepositoryDelegate: AnyObject {
    func setFavorite(for venueId: VenueId, to isFavorite: Bool)
}

struct FavoriteStarView: View {
    let venueId: VenueId
    let isFavorite: Bool
    weak var delegate: FavoriteRepositoryDelegate?

    var body: some View {
        Button(action: {
            delegate?.setFavorite(for: venueId, to: !isFavorite)
        }) {
            Image(systemName: isFavorite ? "star.fill" : "star")
                .foregroundColor(.accentPurple)
                .font(.title2)
                .shadow(color: isFavorite ? Color.accentPurple.opacity(0.6) : .clear, radius: 6, x: 0, y: 0)
        }
    }
}
