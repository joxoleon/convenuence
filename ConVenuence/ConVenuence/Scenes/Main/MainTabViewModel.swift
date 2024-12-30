import SwiftUI
import CVCore

class MainTabViewModel: ObservableObject {
    let searchVenuesViewModel: SearchVenuesViewModel

    init() {
        self.searchVenuesViewModel = SearchVenuesViewModel(venueRepositoryService: ServiceLocator.shared.venueRepositoryService)
    }
}

