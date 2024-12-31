import SwiftUI
import CoreLocation
import Combine
import CVCore
import Kingfisher

// MARK: - VenueDetailViewModel
@MainActor
class VenueDetailViewModel: ObservableObject {
    
    // MARK: - Bindable Properties

    @Published private(set) var venueDetail: VenueDetail?
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Properties

    private let venueRepositoryService: VenueRepositoryService
    private let userLocationService: UserLocationService
    private let venueId: VenueId

    // MARK: - Initializer

    init(venueId: VenueId, venueRepositoryService: VenueRepositoryService, userLocationService: UserLocationService) {
        self.venueId = venueId
        self.venueRepositoryService = venueRepositoryService
        self.userLocationService = userLocationService
    }

    // MARK: - Public Methods

    func fetchVenueDetail() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let detail = try await venueRepositoryService.getVenueDetails(id: venueId)
                venueDetail = detail
                isLoading = false
            } catch let error as APIClientError {
                errorMessage = error.userFriendlyMessage
                isLoading = false
            } catch {
                errorMessage = "An unexpected error occurred. Please try again later."
                isLoading = false
            }
        }
    }

    func distanceFromCurrentLocation(to location: CLLocation) -> String {
        let currentLocation = userLocationService.currentLocation
        let distance = currentLocation.distance(from: location)
        return distance < 1000 ? "\(Int(distance))m" : String(format: "%.1fkm", distance / 1000.0)
    }
}

extension VenueDetailViewModel: FavoriteRepositoryDelegate {
    func setFavorite(for venueId: VenueId, to isFavorite: Bool) {
        Task {
            do {
                if isFavorite {
                    try await venueRepositoryService.saveFavorite(venueId: venueId)
                } else {
                    try await venueRepositoryService.removeFavorite(venueId: venueId)
                }
                if let vd = venueDetail {
                    self.venueDetail = VenueDetail(venueDetail: vd, isFavorite: isFavorite)
                }
            } catch let error as APIClientError {
                print("Error setting favorite: \(error)")
                errorMessage = error.userFriendlyMessage
            } catch {
                print("Unexpected error setting favorite: \(error)")
                errorMessage = "An unexpected error occurred. Please try again later."
            }
        }
    }
}

struct VenueDetailView: View {

    // MARK: - Properties

    @StateObject private var viewModel: VenueDetailViewModel

    // MARK: - Initializers

    init(viewModel: VenueDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            if viewModel.isLoading {
                CenteredProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
                    .multilineTextAlignment(.center)
            } else if let venueDetail = viewModel.venueDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 24) {
                        // Title and Icon
                        HStack(spacing: 16) {
                            if let categoryIconUrl = venueDetail.categoryIconUrl(resolution: 64) {
                                KFImage(categoryIconUrl)
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 64, height: 64)
                                    .cornerRadius(8)
                            }
                            Text(venueDetail.name)
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.accentBlue)
                                .multilineTextAlignment(.leading)
                        }
                        
                        SeparatorView()
                        
                        // Favorite Star
                        HStack(spacing: 24) {
                            FavoriteStarView(
                                venueId: viewModel.venueDetail?.id ?? "",
                                isFavorite: viewModel.venueDetail?.isFavorite ?? false,
                                delegate: viewModel)
                            .frame(width: 32, height: 32)
                            
                            Text("Mark this venue as favorite to have quick access to it within the Favorite Venues Screen.")
                                .font(.subheadline)
                                .foregroundColor(.secondaryText)
                        }
                        
                        SeparatorView()

                        if !venueDetail.description.isEmpty {
                            Text(venueDetail.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        // Address and Distance
                        VStack(alignment: .leading, spacing: 24) {
                            HStack(spacing: 8) {
                                Image(systemName: "mappin.and.ellipse")
                                    .foregroundColor(.accentBlue)
                                Text(venueDetail.formattedAddress)
                                    .font(.subheadline)
                                    .foregroundColor(.secondaryText)
                            }

                            if let location = venueDetail.clLocation {
                                HStack(spacing: 8) {
                                    Image(systemName: "location.fill")
                                        .foregroundColor(.accentBlue)
                                    Text(viewModel.distanceFromCurrentLocation(to: location))
                                        .font(.subheadline)
                                        .fontWeight(.bold)
                                        .foregroundColor(.primaryText)
                                }
                            }
                        }

                        
                        SeparatorView()
                        
                        // Gallery
                        VStack(alignment: .leading, spacing: 16) {
                            Text("Photo Gallery")
                                .font(.title3)
                                .fontWeight(.bold)
                                .foregroundColor(.accentBlue)

                            PhotoGalleryView(photoUrls: venueDetail.photoUrls)
                                .frame(height: 300)
                                .cornerRadius(12)
                                .padding(.horizontal)
                                .background(Color.cardBackground)
                                .shadow(radius: 4)
                                .clipShape(RoundedRectangle(cornerRadius: 12))
                        }

                    }
                    .padding()
                }
            } else {
                Text("Venue details not available.")
                    .foregroundColor(.accentBlue)
                    .padding()
            }
        }
        .onAppear {
            viewModel.fetchVenueDetail()
        }
    }
}

// MARK: - Preview
struct VenueDetailView_Previews: PreviewProvider {
    static var previews: some View {
        VenueDetailView(
            viewModel: VenueDetailViewModel(
                venueId: "4ea1ad6fd3e32e6867a62ed9",
                venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
                userLocationService: ServiceLocator.shared.userLocationService
            )
        )
    }
}
