import SwiftUI
import CoreLocation
import Combine
import CVCore

@MainActor
class FavoriteVenuesViewModel: ObservableObject, FavoriteRepositoryDelegate {

    // MARK: - Bindable Properties

    @Published private(set) var favorites: [Venue] = []
    @Published private(set) var isLoading: Bool = false
    @Published private(set) var errorMessage: String?

    // MARK: - Properties

    private let venueRepositoryService: VenueRepositoryService
    private let userLocationService: UserLocationService
    private var cancellables: Set<AnyCancellable> = []

    // MARK: - Initializer

    init(venueRepositoryService: VenueRepositoryService, userLocationService: UserLocationService) {
        self.venueRepositoryService = venueRepositoryService
        self.userLocationService = userLocationService
        bindFavoriteChanges()
    }

    // MARK: - Public Methods

    func fetchFavorites() {
        isLoading = true
        errorMessage = nil

        Task {
            do {
                let favoriteVenues = try await venueRepositoryService.getFavorites()
                await updateFavorites(favoriteVenues)
            } catch {
                await updateErrorState(with: error.localizedDescription)
            }
        }
    }

    func setFavorite(for venueId: VenueId, to isFavorite: Bool) {
        Task {
            do {
                if isFavorite {
                    try await venueRepositoryService.saveFavorite(venueId: venueId)
                } else {
                    try await venueRepositoryService.removeFavorite(venueId: venueId)
                }
                fetchFavorites() // Refresh the list after a change
            } catch {
                await updateErrorState(with: error.localizedDescription)
            }
        }
    }
    
    var currentUserLocation: CLLocation {
        userLocationService.currentLocation
    }

    // MARK: - Private Methods

    private func bindFavoriteChanges() {
        venueRepositoryService.favoriteChangesPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] in
                self?.fetchFavorites()
            }
            .store(in: &cancellables)
    }

    private func updateFavorites(_ favorites: [Venue]) async {
        // Sort favorites by distance using userLocationService
        let sortedFavorites = favorites.sorted { lhs, rhs in
            let distance1 = lhs.distance(from: userLocationService.currentLocation)
            let distance2 = rhs.distance(from: userLocationService.currentLocation)
            return distance1 < distance2
        }
        self.favorites = sortedFavorites
        self.isLoading = false
    }

    private func updateErrorState(with message: String) async {
        self.errorMessage = message
        self.isLoading = false
    }
}

// MARK: - FavoritesView

struct FavoriteVenuesView: View {
    
    // MARK: - Properties
    
    @StateObject private var viewModel: FavoriteVenuesViewModel

    // MARK: - Initializers
    
    init(viewModel: FavoriteVenuesViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    // MARK: - Body

    var body: some View {
        ZStack {
            Color.primaryBackground
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                ZStack {
                    // Show loader only if the list is empty and still loading
                    if viewModel.isLoading && viewModel.favorites.isEmpty {
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
                            LazyVStack(spacing: 16) {
                                ForEach(viewModel.favorites, id: \ .id) { venue in
                                    NavigationLink(destination: VenueDetailView(viewModel: VenueDetailViewModel(
                                        venueId: venue.id,
                                        venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
                                        userLocationService: ServiceLocator.shared.userLocationService
                                    ))) {
                                        VenueCellView(
                                            venue: venue,
                                            currentLocation: viewModel.currentUserLocation,
                                            favoriteRepositoryDelegate: viewModel // Enable favorites toggling
                                        )
                                    }
                                    .padding(.horizontal)
                                    .transition(.opacity.combined(with: .slide)) // Smooth transitions
                                }
                            }
                            .padding(.top)
                        }
                        .animation(.default, value: viewModel.favorites) // Animate changes to the list
                    }
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
            }
        }
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
                venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
                userLocationService: ServiceLocator.shared.userLocationService
            )
        )
    }
}
