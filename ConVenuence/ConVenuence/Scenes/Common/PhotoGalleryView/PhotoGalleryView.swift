import SwiftUI
import Kingfisher
import CVCore

struct PhotoGalleryView: View {
    let photoUrls: [URL]
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 16) {
                ForEach(photoUrls, id: \.self) { url in
                    KFImage(url)
                        .resizable()
                        .placeholder {
                            ProgressView()
                        }
                        .retry(maxCount: 3, interval: .seconds(1))
                        .cacheOriginalImage()
                        .onFailure { _ in
                            print("Failed to load image for URL: \(url)")
                        }
                        .scaledToFill()
                        .frame(width: 200, height: 150)
                        .clipped()
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 0, y: 2)
                }
            }
            .padding()
        }
    }
}

// MARK: - Preview

struct PhotoGalleryView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            PhotoGalleryView(photoUrls:
                FoursquareDTO.Photo.samplePhotos.map { $0.photoUrlHalfRes }
            )
        }
    }
}
