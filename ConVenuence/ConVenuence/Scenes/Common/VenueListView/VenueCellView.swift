import SwiftUI
import CVCore

struct VenueCellView: View {
    let venue: Venue
    
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
                    .frame(width: 60, height: 60)
                    .cornerRadius(8)
                    .padding(.leading)
                } else {
                    Rectangle()
                        .fill(Color.gray.opacity(0.5))
                        .frame(width: 60, height: 60)
                        .cornerRadius(8)
                        .padding(.leading)
                }
                
                // Venue Details
                VStack(alignment: .leading, spacing: 6) {
                    Text(venue.name)
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        if venue.isFavorite {
                            Image(systemName: "star.fill")
                                .foregroundColor(.accentPurple)
                                .font(.title3)
                                .shadow(color: Color.accentPurple.opacity(0.6), radius: 6, x: 0, y: 0)
                        } else {
                            Image(systemName: "star")
                                .foregroundColor(.secondaryText)
                                .font(.title3)
                        }
                    }
                }
                .padding(.leading, 8)
                
                Spacer()
            }
            .padding(.vertical, 12)
        }
        .padding(.horizontal)
    }
}

struct VenueCellView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack {
                VenueCellView(venue: Venue.sample1)
                    .previewLayout(.sizeThatFits)
                    .padding()
                    .background(Color.primaryBackground)
                
                VenueCellView(venue: Venue.sample2)
                    .previewLayout(.sizeThatFits)
                    .padding()
                    .background(Color.primaryBackground)
            }
        }

    }
}
