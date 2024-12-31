import SwiftUI
import Kingfisher
import CoreLocation
import CVCore

struct VenueCellView: View {
    let venue: Venue
    let currentLocation: CLLocation
    weak var favoriteRepositoryDelegate: FavoriteRepositoryDelegate?
    
    init(venue: Venue, currentLocation: CLLocation, favoriteRepositoryDelegate: FavoriteRepositoryDelegate?) {
        self.venue = venue
        self.currentLocation = currentLocation
        self.favoriteRepositoryDelegate = favoriteRepositoryDelegate
    }

    var body: some View {
        ZStack {
            // Background using ThemeConstants
            ThemeConstants.venueCellBackground
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            HStack {
                // Category Icon with Caching
                if let imageUrl = venue.categoryIconUrl(resolution: 64) {
                    KFImage(imageUrl)
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .retry(maxCount: 3, interval: .seconds(1))
                        .cacheOriginalImage()
                        .onFailure { _ in
                            print("Failed to load image for URL: \(imageUrl)")
                        }
                        .frame(width: 64, height: 64)
                        .cornerRadius(8)
                        .padding(.leading)
                } else {
                    // Fallback for no URL
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 64, height: 64)
                        .cornerRadius(8)
                        .padding(.leading)
                }
                
                // Venue Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(venue.name)
                        .font(.title)
                        .foregroundColor(.white)
                    
                    Text(venue.address)
                        .font(.subheadline)
                        .foregroundColor(.secondaryText)
                    
                    Text(venue.distanceString(from: currentLocation))
                        .font(.subheadline)
                        .foregroundColor(.primaryText)
                        .fontWeight(.semibold)
                }
                .padding(.leading, 8)
                
                Spacer()
                
                // Favorite Star
                FavoriteStarView(venueId: venue.id, isFavorite: venue.isFavorite, delegate: favoriteRepositoryDelegate)
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
        }
    }
}


// MARK: - Preview

struct VenueCellView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack {
                VenueCellView(
                    venue: Venue.sample1,
                    currentLocation: CLLocation(latitude: 40.7128, longitude: -74.0060),
                    favoriteRepositoryDelegate: nil
                )
                .previewLayout(.sizeThatFits)
                .padding()
                
                VenueCellView(
                    venue: Venue.sample2,
                    currentLocation: CLLocation(latitude: 40.7128, longitude: -74.0060),
                    favoriteRepositoryDelegate: nil
                )
                .previewLayout(.sizeThatFits)
                .padding()
            }
        }
    }
}
