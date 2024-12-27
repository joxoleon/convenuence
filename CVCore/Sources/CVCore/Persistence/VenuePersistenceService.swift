import Foundation

// MARK: - VenuePersistenceService Protocol

protocol VenuePersistenceService {
    func saveFavorite(_ venue: FoursqareDTO.Venue) async throws
    func fetchFavorites() async throws -> [FoursqareDTO.Venue]
    func removeFavorite(_ venue: FoursqareDTO.Venue) async throws
    func isFavorite(_ venue: FoursqareDTO.Venue) async throws -> Bool

    func saveSearchResults(for query: String, venues: [FoursqareDTO.Venue]) async throws
    func fetchSearchResults(for query: String) async throws -> [FoursqareDTO.Venue]?
    func clearSearchResults() async throws
}

// MARK: - VenuePersistenceServiceImpl Implementation

final class VenuePersistenceServiceImpl<
    FavoritesPersistence: PersistenceService,
    SearchResultsPersistence: PersistenceService
>: VenuePersistenceService
where
    FavoritesPersistence.EntityType == FoursqareDTO.Venue,
    SearchResultsPersistence.EntityType == [String: [FoursqareDTO.Venue]]
{

    // MARK: - Properties

    private let favoritesPersistence: FavoritesPersistence
    private let searchResultsPersistence: SearchResultsPersistence

    // MARK: - Initializer

    init(
        favoritesPersistence: FavoritesPersistence,
        searchResultsPersistence: SearchResultsPersistence
    ) {
        self.favoritesPersistence = favoritesPersistence
        self.searchResultsPersistence = searchResultsPersistence
    }

    // MARK: - Favorites Operations

    func saveFavorite(_ venue: FoursqareDTO.Venue) async throws {
        try await favoritesPersistence.save(entity: venue)
    }

    func fetchFavorites() async throws -> [FoursqareDTO.Venue] {
        return try await favoritesPersistence.fetchAll()
    }

    func removeFavorite(_ venue: FoursqareDTO.Venue) async throws {
        try await favoritesPersistence.delete(entity: venue)
    }

    func isFavorite(_ venue: FoursqareDTO.Venue) async throws -> Bool {
        let favorites = try await fetchFavorites()
        return favorites.contains { $0.id == venue.id }
    }

    // MARK: - Search Results Operations

    func saveSearchResults(for query: String, venues: [FoursqareDTO.Venue]) async throws {
        var allResults = try await fetchAllSearchResults()
        allResults[query] = venues
        try await searchResultsPersistence.save(entity: allResults)
    }

    func fetchSearchResults(for query: String) async throws -> [FoursqareDTO.Venue]? {
        let allResults = try await fetchAllSearchResults()
        return allResults[query]
    }

    func clearSearchResults() async throws {
        try await searchResultsPersistence.deleteAll()
    }

    // MARK: - Private Helpers

    private func fetchAllSearchResults() async throws -> [String: [FoursqareDTO.Venue]] {
        return try await searchResultsPersistence.fetchAll().first ?? [:]
    }
}
