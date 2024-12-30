import SwiftUI
import CVCore
import CoreLocation

struct VenueCellView: View {
    let venue: Venue
    let currentLocation: CLLocation
    
    var body: some View {
        ZStack {
            // Background using ThemeConstants
            ThemeConstants.venueCellBackground
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
            
            HStack {
                // Category Icon
                if let imageUrl = venue.categoryIconUrl(resolution: 64) {
                    AsyncImage(url: imageUrl) { image in
                        image.resizable()
                    } placeholder: {
                        ProgressView()
                    }
                    .frame(width: 64, height: 64)
                    .cornerRadius(8)
                    .padding(.leading)
                } else {
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
                FavoriteStarView(isFavorite: venue.isFavorite)
                    .padding(.trailing)
            }
            .padding(.vertical, 12)
        }
    }
}

struct FavoriteStarView: View {
    let isFavorite: Bool
    
    var body: some View {
        Image(systemName: isFavorite ? "star.fill" : "star")
            .foregroundColor(.accentPurple)
            .font(.title2)
            .shadow(color: isFavorite ? Color.accentPurple.opacity(0.6) : .clear, radius: 6, x: 0, y: 0)
    }
}


struct VenueCellView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack {
                VenueCellView(
                    venue: Venue.sample1,
                    currentLocation: CLLocation(latitude: 40.7128, longitude: -74.0060)
                )
                .previewLayout(.sizeThatFits)
                .padding()
                
                VenueCellView(
                    venue: Venue.sample2,
                    currentLocation: CLLocation(latitude: 40.7128, longitude: -74.0060)
                )
                .previewLayout(.sizeThatFits)
                .padding()
            }
        }
    }
}
