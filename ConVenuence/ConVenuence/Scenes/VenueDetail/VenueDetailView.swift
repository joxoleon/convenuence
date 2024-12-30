import SwiftUI
import CoreLocation
import Combine
import CVCore

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
        fetchVenueDetail()
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
            } catch {
                errorMessage = error.localizedDescription
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

struct VenueDetailView: View {

    // MARK: - Properties

    @StateObject private var viewModel: VenueDetailViewModel

    // MARK: - Initializers

    init(viewModel: VenueDetailViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    // MARK: - Body

    var body: some View {
        VStack(spacing: 16) {
            if viewModel.isLoading {
                CenteredProgressView()
            } else if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .foregroundColor(.red)
                    .padding()
            } else if let venueDetail = viewModel.venueDetail {
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        Text(venueDetail.name)
                            .font(.largeTitle)
                            .fontWeight(.bold)

                        if !venueDetail.description.isEmpty {
                            Text(venueDetail.description)
                                .font(.body)
                                .foregroundColor(.secondary)
                        }

                        HStack {
                            Image(systemName: "mappin.and.ellipse")
                                .foregroundColor(.accentBlue)
                            Text(venueDetail.formattedAddress)
                                .font(.subheadline)
                                .foregroundColor(.primaryText)
                        }

                        if let location = venueDetail.clLocation {
                            Text("Distance: \(viewModel.distanceFromCurrentLocation(to: location))")
                                .font(.subheadline)
                                .foregroundColor(.primaryText)
                        }

                        PhotoGalleryView(photoUrls: venueDetail.photoUrls)
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
