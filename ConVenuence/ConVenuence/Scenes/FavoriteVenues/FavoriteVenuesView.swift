import SwiftUI
import CoreLocation
import Combine
import CVCore

// MARK: - FavoritesViewModelProtocol
//@MainActor
//protocol FavoriteVenuesViewModelProtocol: ObservableObject {
//    var favorites: [Venue] { get }
//    var isLoading: Bool { get }
//    var errorMessage: String? { get }
//    func fetchFavorites()
//}

// MARK: - FavoritesViewModel
@MainActor
class FavoriteVenuesViewModel: ObservableObject {
    // MARK: - Bindable Properties

    @Published private(set) var favorites: [Venue] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Properties

    private let venueRepositoryService: VenueRepositoryService
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializer

    init(venueRepositoryService: VenueRepositoryService) {
        self.venueRepositoryService = venueRepositoryService
        bindFavoriteChanges()
    }

    // MARK: - Public Methods

    func fetchFavorites() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let favoriteVenues = try await venueRepositoryService.getFavorites()
                favorites = favoriteVenues
                isLoading = false
            } catch {
                print("Error fetching favorites: \(error)")
                errorMessage = error.localizedDescription
                isLoading = false
            }
        }
    }

    // MARK: - Private Methods

    private func bindFavoriteChanges() {
        venueRepositoryService.favoriteChangesPublisher
            .sink { [weak self] in
                self?.fetchFavorites()
            }
            .store(in: &cancellables)
    }
}

// MARK: - FavoritesView
struct FavoriteVenuesView: View {
    @StateObject private var viewModel: FavoriteVenuesViewModel

    init(viewModel: FavoriteVenuesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }

    var body: some View {
        VStack(spacing: 0) {
            ZStack {
                if viewModel.isLoading {
                    CenteredProgressView()
                } else if let errorMessage = viewModel.errorMessage {
                    Text(errorMessage)
                        .foregroundColor(.red)
                        .padding()
                } else if viewModel.favorites.isEmpty {
                    VStack {
                        Spacer()
                        Text("No Favorites")
                            .font(.title3)
                            .foregroundColor(.accentBlue)
                            .multilineTextAlignment(.center)
                            .opacity(0.6)
                        Spacer()
                    }
                } else {
                    ScrollView {
                        VStack(spacing: 16) {
                            ForEach(viewModel.favorites, id: \ .id) { venue in
                                VenueCellView(
                                    venue: venue,
                                    currentLocation: CLLocation(latitude: 0, longitude: 0), // Placeholder location
                                    favoriteRepositoryDelegate: nil // Not needed in FavoritesView
                                )
                                .padding(.horizontal)
                            }
                        }
                        .padding(.top)
                    }
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
        .onAppear {
            viewModel.fetchFavorites()
        }
    }
}

// MARK: - Preview
struct FavoritesView_Previews: PreviewProvider {
    static var previews: some View {
        FavoriteVenuesView(
            viewModel: FavoriteVenuesViewModel(
                venueRepositoryService: ServiceLocator.shared.venueRepositoryService
            )
        )
    }
}
