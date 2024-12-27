import Foundation

public final class ServiceLocator {

    // MARK: - Singleton Instance

    public static let shared = ServiceLocator()

    // MARK: - Initializers

    private init() {}

    // MARK: Services

    public lazy var venueRepositoryService: VenueRepositoryService = {
        return VenueRepositoryServiceImpl(apiClient: venueAPIClient, persistenceService: venuePersistenceService)
    }()


    // MARK: - Private Properties

    private lazy var venueAPIClient: VenueAPIClient = {
        guard let apiKey = getApiKey() else {
            fatalError("API key not found")
        }
        let authorizationHeader = "Bearer YOUR_API_KEY" // Replace with your actual API key
        return VenueAPIClientImpl(authorizationHeader: authorizationHeader)
    }()

    private lazy var venuePersistenceService: VenuePersistenceService = {
        return UserDefaultsVenuePersistenceService()
    }()

    // MARK: - Private Methods

    private func getApiKey() -> String? {
        return nil // Return the real API key here when running the app
    }
}
