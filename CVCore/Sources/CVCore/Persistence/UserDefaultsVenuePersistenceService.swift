import Foundation

/// A concrete implementation of `VenuePersistenceService` using `UserDefaults`.
public final class UserDefaultsVenuePersistenceService: VenuePersistenceService {
    
    // MARK: - Properties
    
    private let userDefaults: UserDefaults
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    // Keys for UserDefaults
    private let favoritesKey = "favoriteVenueIds"
    private let venueDetailsKeyPrefix = "venueDetail_"
    private let searchResultsKey = "searchResults"
    private let venueKeyPrefix = "venue_"
    
    // In-memory caches
    private var favoriteIdsCache: [VenueId]?
    private var venueDetailsCache: [VenueId: VenueDetail] = [:]
    private var venuesCache: [VenueId: Venue] = [:]
    private var searchResultsCache: [String: [VenueId]]?
    
    // MARK: - Initializer
    
    public init(userDefaults: UserDefaults = .standard) {
        self.userDefaults = userDefaults
        // Initial fetch to populate caches
        self.favoriteIdsCache = userDefaults.array(forKey: favoritesKey) as? [VenueId]
        self.searchResultsCache = (try? fetchAllSearchResults()) ?? [:]
        self.venueDetailsCache = (try? fetchAllVenueDetails().reduce(into: [:]) { $0[$1.id] = $1 }) ?? [:]
        self.venuesCache = (try? fetchAllVenues().reduce(into: [:]) { $0[$1.id] = $1 }) ?? [:]
    }
    
    // MARK: - Favorites Operations
    
    public func saveFavorite(venueId: VenueId) async throws {
        var favoriteIds = try await fetchFavoriteIds()
        if (!favoriteIds.contains(venueId)) {
            favoriteIds.append(venueId)
            try saveFavoriteIds(favoriteIds)
        }

        // These updates should be done in a single transaction
        try updateVenueDetailsFavoriteFlag(venueId: venueId, isFavorite: true)
        try updateVenueFavoriteFlag(venueId: venueId, isFavorite: true)
    }
    
    public func removeFavorite(venueId: VenueId) async throws {
        var favoriteIds = try await fetchFavoriteIds()
        favoriteIds.removeAll { $0 == venueId }
        try saveFavoriteIds(favoriteIds)

        // These updates should be done in a single transaction
        try updateVenueDetailsFavoriteFlag(venueId: venueId, isFavorite: false)
        try updateVenueFavoriteFlag(venueId: venueId, isFavorite: false)
    }
    
    public func fetchFavoriteIds() async throws -> [VenueId] {
        if let cachedFavoriteIds = favoriteIdsCache {
            return cachedFavoriteIds
        }
        let favoriteIds = userDefaults.array(forKey: favoritesKey) as? [VenueId] ?? []
        favoriteIdsCache = favoriteIds
        return favoriteIds
    }
    
    public func fetchFavoriteVenues() async throws -> [Venue] {
        let favoriteIds = try await fetchFavoriteIds()
        return try await fetchVenues(by: favoriteIds)
    }
    
    // MARK: - Venue Detail Operations
    
    public func saveVenueDetail(_ venueDetail: VenueDetail) async throws {
        let key = "\(venueDetailsKeyPrefix)\(venueDetail.id)"
        let data = try encoder.encode(venueDetail)
        userDefaults.set(data, forKey: key)
        venueDetailsCache[venueDetail.id] = venueDetail
    }
    
    public func fetchVenueDetail(by id: VenueId) async throws -> VenueDetail? {
        if let cachedDetail = venueDetailsCache[id] {
            return cachedDetail
        }
        let key = "\(venueDetailsKeyPrefix)\(id)"
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let venueDetail = try decoder.decode(VenueDetail.self, from: data)
        venueDetailsCache[id] = venueDetail
        return venueDetail
    }
    
    public func fetchVenueDetails(by ids: [VenueId]?) async throws -> [VenueDetail] {
        if let ids = ids {
            let fetchTasks = ids.map { id in
                Task { [weak self] in
                    return try await self?.fetchVenueDetail(by: id)
                }
            }

            let venueDetails = try await withThrowingTaskGroup(of: VenueDetail?.self) { group in
                for task in fetchTasks {
                    group.addTask {
                        return try await task.value
                    }
                }

                var results: [VenueDetail] = []
                for try await detail in group {
                    if let detail = detail {
                        results.append(detail)
                    }
                }
                return results
            }

            return venueDetails
        } else {
            return try fetchAllVenueDetails()
        }
    }
    
    // MARK: - Venue Operations
    
    public func saveVenue(_ venue: Venue) async throws {
        let key = "\(venueKeyPrefix)\(venue.id)"
        let data = try encoder.encode(venue)
        userDefaults.set(data, forKey: key)
        venuesCache[venue.id] = venue
    }

    public func saveVenues(_ venues: [Venue]) async throws {
        let encoder = JSONEncoder()

        // Fetch existing venues
        let allVenues = try fetchAllVenues() + venues

        // Create a dictionary to hold the encoded venues
        var encodedVenues: [String: Data] = [:]
        for venue in allVenues {
            let key = "\(venueKeyPrefix)\(venue.id)"
            let data = try encoder.encode(venue)
            encodedVenues[key] = data
            venuesCache[venue.id] = venue
        }

        // Save all encoded venues to UserDefaults in a single operation
        userDefaults.setValuesForKeys(encodedVenues)
    }
    
    public func fetchVenue(by id: VenueId) async throws -> Venue? {
        if let cachedVenue = venuesCache[id] {
            return cachedVenue
        }
        let key = "\(venueKeyPrefix)\(id)"
        guard let data = userDefaults.data(forKey: key) else { return nil }
        let venue = try decoder.decode(Venue.self, from: data)
        venuesCache[id] = venue
        return venue
    }

    public func fetchVenues(by ids: [VenueId]?) async throws -> [Venue] {
        if let ids = ids {
            let fetchTasks = ids.map { id in
                Task { [weak self] in
                    return try await self?.fetchVenue(by: id)
                }
            }

            let venues = try await withThrowingTaskGroup(of: Venue?.self) { group in
                for task in fetchTasks {
                    group.addTask {
                        return try await task.value
                    }
                }

                var results: [Venue] = []
                for try await venue in group {
                    if let venue = venue {
                        results.append(venue)
                    }
                }
                return results
            }

            return venues
        } else {
            return try fetchAllVenues()
        }
    }
    
    // MARK: - Search Result Operations
    
    public func saveSearchResults(for request: SearchVenuesRequest, venueIds: [VenueId]) async throws {
        var results = try fetchAllSearchResults()
        results[request.query] = venueIds
        try saveAllSearchResults(results)
        searchResultsCache = results
    }
    
    public func fetchSearchResults(for request: SearchVenuesRequest) async throws -> [VenueId]? {
        if let cachedResults = searchResultsCache {
            return cachedResults[request.query]
        }
        return try fetchAllSearchResults()[request.query]
    }
    
    // MARK: - Private Helpers

    private func updateVenueDetailsFavoriteFlag(venueId: VenueId, isFavorite: Bool) throws {
        guard let data = userDefaults.data(forKey: "\(venueDetailsKeyPrefix)\(venueId)"),
              let vd = try? decoder.decode(VenueDetail.self, from: data) else {
            return
        }

        let venueDetail = VenueDetail(venueDetail: vd, isFavorite: isFavorite)
        let newData = try encoder.encode(venueDetail)
        userDefaults.set(newData, forKey: "\(venueDetailsKeyPrefix)\(venueId)")
        venueDetailsCache[venueId] = venueDetail
    }
    
    private func updateVenueFavoriteFlag(venueId: VenueId, isFavorite: Bool) throws {
        guard let data = userDefaults.data(forKey: "\(venueKeyPrefix)\(venueId)"),
              let venue = try? decoder.decode(Venue.self, from: data) else {
            return
        }
        let newVenue = Venue(venue: venue, isFavorite: isFavorite)
        let newData = try encoder.encode(newVenue)
        userDefaults.set(newData, forKey: "\(venueKeyPrefix)\(venueId)")
        venuesCache[venueId] = newVenue
    }
    
    private func saveFavoriteIds(_ favoriteIds: [VenueId]) throws {
        userDefaults.set(favoriteIds, forKey: favoritesKey)
        favoriteIdsCache = favoriteIds
    }
    
    private func fetchAllVenueDetails() throws -> [VenueDetail] {
        var details: [VenueDetail] = []
        for (key, value) in userDefaults.dictionaryRepresentation() {
            if key.hasPrefix(venueDetailsKeyPrefix), let data = value as? Data, let detail = try? decoder.decode(VenueDetail.self, from: data) {
                details.append(detail)
                venueDetailsCache[detail.id] = detail
            }
        }
        return details
    }
    
    private func fetchAllVenues() throws -> [Venue] {
        var venues: [Venue] = []
        for (key, value) in userDefaults.dictionaryRepresentation() {
            if key.hasPrefix(venueKeyPrefix), let data = value as? Data, let venue = try? decoder.decode(Venue.self, from: data) {
                venues.append(venue)
                venuesCache[venue.id] = venue
            }
        }
        return venues
    }
    
    private func fetchAllSearchResults() throws -> [String: [VenueId]] {
        if let cachedResults = searchResultsCache {
            return cachedResults
        }
        guard let data = userDefaults.data(forKey: searchResultsKey),
              let results = try? decoder.decode([String: [VenueId]].self, from: data) else {
            return [:]
        }
        searchResultsCache = results
        return results
    }
    
    private func saveAllSearchResults(_ results: [String: [VenueId]]) throws {
        let data = try encoder.encode(results)
        userDefaults.set(data, forKey: searchResultsKey)
        searchResultsCache = results
    }
}