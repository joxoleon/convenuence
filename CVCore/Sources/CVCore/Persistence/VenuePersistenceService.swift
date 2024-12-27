import Foundation

// MARK: - VenuePersistenceService Protocol

/// A protocol defining the operations for persisting venue-related data.
public protocol VenuePersistenceService {
    /**
     Saves a venue ID to the list of favorites.
     
     - Parameter venueId: The ID of the venue to save.
     - Throws: An error if the save operation fails.
     */
    func saveFavorite(_ venueId: VenueId) async throws

    /**
     Fetches the list of favorite venue IDs.
     
     - Returns: An array of favorite venue IDs.
     - Throws: An error if the fetch operation fails.
     */
    func fetchFavorites() async throws -> [VenueId]

    /**
     Removes a venue ID from the list of favorites.
     
     - Parameter venueId: The ID of the venue to remove.
     - Throws: An error if the delete operation fails.
     */
    func removeFavorite(_ venueId: VenueId) async throws

    /**
     Checks if a venue ID is in the list of favorites.
     
     - Parameter venueId: The ID of the venue to check.
     - Returns: A boolean indicating whether the venue is a favorite.
     - Throws: An error if the fetch operation fails.
     */
    func isFavorite(_ venueId: VenueId) async throws -> Bool

    /**
     Saves search results for a given search request.
     
     - Parameters:
       - request: The search request.
       - venues: The list of venues to save.
     - Throws: An error if the save operation fails.
     */
    func saveSearchResults(for request: SearchVenuesRequest, venues: [Venue]) async throws

    /**
     Fetches search results for a given search request.
     
     - Parameter request: The search request.
     - Returns: An optional array of venues matching the search request.
     - Throws: An error if the fetch operation fails.
     */
    func fetchSearchResults(for request: SearchVenuesRequest) async throws -> [Venue]?

    /**
     Clears all saved search results.
     
     - Throws: An error if the delete operation fails.
     */
    func clearSearchResults() async throws

    /**
     Saves the details of a venue.
     
     - Parameter venueDetail: The details of the venue to save.
     - Throws: An error if the save operation fails.
     */
    func saveVenueDetail(_ venueDetail: VenueDetail) async throws

    /**
     Fetches the details of a venue by its ID.
     
     - Parameter id: The ID of the venue to fetch.
     - Returns: An optional venue detail object.
     - Throws: An error if the fetch operation fails.
     */
    func fetchVenueDetail(by id: VenueId) async throws -> VenueDetail?

    // Clear venue detail
    /**
    Clears the details of a venue by its ID.
    
    - Parameter id: The ID of the venue to clear.
    - Throws: An error if the delete operation fails.
    */
    func clearVenueDetail(by id: VenueId) async throws

}

// MARK: - VenuePersistenceServiceImpl Implementation

/// An implementation of the `VenuePersistenceService` protocol.
public final class VenuePersistenceServiceImpl<
    FavoritesPersistence: PersistenceService,
    SearchResultsPersistence: PersistenceService,
    VenueDetailsPersistence: PersistenceService
>: VenuePersistenceService
where
    FavoritesPersistence.EntityType == [VenueId],
    SearchResultsPersistence.EntityType == [String: [Venue]],
    VenueDetailsPersistence.EntityType == VenueDetail
{

    // MARK: - Properties

    private let favoritesPersistence: FavoritesPersistence
    private let searchResultsPersistence: SearchResultsPersistence
    private let venueDetailsPersistence: VenueDetailsPersistence

    // MARK: - Initializer

    public init(
        favoritesPersistence: FavoritesPersistence,
        searchResultsPersistence: SearchResultsPersistence,
        venueDetailsPersistence: VenueDetailsPersistence
    ) {
        self.favoritesPersistence = favoritesPersistence
        self.searchResultsPersistence = searchResultsPersistence
        self.venueDetailsPersistence = venueDetailsPersistence
    }

    // MARK: - Favorites Operations

    public func saveFavorite(_ venueId: VenueId) async throws {
        var favorites = try await fetchFavorites()
        if !favorites.contains(venueId) {
            favorites.append(venueId)
            try await favoritesPersistence.save(entity: favorites, forKey: "favorites")
        }
    }

    public func fetchFavorites() async throws -> [VenueId] {
        return try await favoritesPersistence.fetch(forKey: "favorites") ?? []
    }

    public func removeFavorite(_ venueId: VenueId) async throws {
        var favorites = try await fetchFavorites()
        favorites.removeAll { $0 == venueId }
        try await favoritesPersistence.save(entity: favorites, forKey: "favorites")
    }

    public func isFavorite(_ venueId: VenueId) async throws -> Bool {
        let favorites = try await fetchFavorites()
        return favorites.contains(venueId)
    }

    // MARK: - Search Results Operations

    public func saveSearchResults(for request: SearchVenuesRequest, venues: [Venue]) async throws {
        var allResults = try await fetchAllSearchResults()
        allResults[request.query] = venues
        try await searchResultsPersistence.save(entity: allResults, forKey: "searchResults")
    }

    public func fetchSearchResults(for request: SearchVenuesRequest) async throws -> [Venue]? {
        let allResults = try await fetchAllSearchResults()
        return allResults[request.query]
    }

    public func clearSearchResults() async throws {
        try await searchResultsPersistence.delete(forKey: "searchResults")
    }

    // MARK: - Venue Details Operations

    public func saveVenueDetail(_ venueDetail: VenueDetail) async throws {
        try await venueDetailsPersistence.save(entity: venueDetail, forKey: venueDetail.id)
    }

    public func fetchVenueDetail(by id: VenueId) async throws -> VenueDetail? {
        return try await venueDetailsPersistence.fetch(forKey: id)
    }

    public func clearVenueDetail(by id: VenueId) async throws {
        try await venueDetailsPersistence.delete(forKey: id)
    }

    // MARK: - Private Helpers

    private func fetchAllSearchResults() async throws -> [String: [Venue]] {
        return try await searchResultsPersistence.fetch(forKey: "searchResults") ?? [:]
    }
}
