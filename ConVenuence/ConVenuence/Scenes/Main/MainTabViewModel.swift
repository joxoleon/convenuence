import SwiftUI
import CVCore

@MainActor
class MainTabViewModel: ObservableObject {
    let searchVenuesViewModel: SearchVenuesViewModel
    let favoriteVenuesViewModel: FavoriteVenuesViewModel

    init() {
        self.searchVenuesViewModel = SearchVenuesViewModel(
            venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
            userLocationService: ServiceLocator.shared.userLocationService
        )
        
        self.favoriteVenuesViewModel = FavoriteVenuesViewModel(
            venueRepositoryService: ServiceLocator.shared.venueRepositoryService
        )
    }
}

