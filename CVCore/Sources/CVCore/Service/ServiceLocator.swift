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

    public lazy var userLocationService: UserLocationService = {
        return UserLocationServiceImpl()
    }()

    // MARK: - Private Properties

    private lazy var venueAPIClient: VenueAPIClient = {
        guard let authorizationHeader = getAuthorizationHeader() else {
            fatalError("API key not found")
        }
        return VenueAPIClientImpl(authorizationHeader: authorizationHeader)
    }()

    private lazy var venuePersistenceService: VenuePersistenceService = {
        return UserDefaultsVenuePersistenceService()
    }()

    // MARK: - Private Methods

    private func getAuthorizationHeader() -> String? {
        // TODO: Implement a secure way to store and retrieve the API key - DO NOT MERGE IN A HARD-CODED API KEY
        return nil // Return the real API key here when running the app
    }
}
