import SwiftUI
import CVCore

@MainActor
class MainTabViewModel: ObservableObject {
    let searchVenuesViewModel: SearchVenuesViewModel

    init() {
        self.searchVenuesViewModel = SearchVenuesViewModel(
            venueRepositoryService: ServiceLocator.shared.venueRepositoryService,
            userLocationService: ServiceLocator.shared.userLocationService
        )
    }
}

