import SwiftUI
import CVCore

struct VenueCellView: View {
    let venue: Venue

    var body: some View {
        HStack {
            if let imageUrl = URL(string: "https://via.placeholder.com/60") { // Example image placeholder
                AsyncImage(url: imageUrl) { image in
                    image.resizable()
                } placeholder: {
                    ProgressView()
                }
                .frame(width: 60, height: 60)
                .cornerRadius(8)
            }
            VStack(alignment: .leading) {
                Text(venue.name)
                    .font(.headline)
                if venue.isFavorite {
                    Text("Favorite")
                        .font(.caption)
                        .foregroundColor(.yellow)
                }
            }
        }
    }
}

struct VenueCellView_Previews: PreviewProvider {
    static var previews: some View {
        VenueCellView(venue: Venue(id: "1", name: "Venue 1", isFavorite: true))
    }
}
