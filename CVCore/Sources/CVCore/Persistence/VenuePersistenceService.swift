import Foundation

// MARK: - VenuePersistenceService Protocol

/** 

A protocol defining the operations for persisting venue-related data.
It should definitely be implemented by a concrete class persisting it via CoreData or SQLite.
I will probably only do it in UserDefaults because I don't want to was too much time on this project.
But the API is designed in a way that it can be easily extended to support other persistence mechanisms.
*/
public protocol VenuePersistenceService {

    // MARK: - Favorites Operations

    /**
     Saves a venue ID to the list of favorites.
     
     - Parameter venueId: The ID of the venue to save.
     - Throws: An error if the save operation fails.
     */
    func saveFavorite(venueId: VenueId) async throws

    /**
     Removes a venue ID from the list of favorites.
     
     - Parameter venueId: The ID of the venue to remove.
     - Throws: An error if the delete operation fails.
     */
    func removeFavorite(venueId: VenueId) async throws

    /**
     Fetches the list of favorite venue IDs.
     
     - Returns: An array of favorite venue IDs.
     - Throws: An error if the fetch operation fails.
     */
    func fetchFavoriteIds() async throws -> [VenueId]

    /**
     Fetches the list of favorite venues.
     
     - Returns: An array of favorite venues.
     - Throws: An error if the fetch operation fails.
     */
    func fetchFavoriteVenues() async throws -> [Venue]

    // MARK: - Venue Detail Operations

    /**
     Saves VenueDetail objects.
     
     - Parameter venueDetail: The details of the venue to save.
     - Throws: An error if the save operation fails.
     */
    func saveVenueDetail(_ venueDetail: VenueDetail) async throws

    /**
     Fetches VenueDetail objects by their ID.
     
     - Parameter id: The ID of the venue to fetch.
     - Returns: An optional venue detail object.
     - Throws: An error if the fetch operation fails.
     */
    func fetchVenueDetail(by id: VenueId) async throws -> VenueDetail?

    /**
     Fetches VenueDetail objects by their IDs.
     
     - Parameter ids: The IDs of the venues to fetch. If nil, fetches all venue details.
     - Returns: An array of venue details.
     - Throws: An error if the fetch operation fails.
     */
    func fetchVenueDetails(by ids: [VenueId]?) async throws -> [VenueDetail]

    // MARK: - Venue Operations

    /**
     Saves a venue entity.
     
     - Parameter venue: The venue entity to save.
     - Throws: An error if the save operation fails.
     */
    func saveVenue(_ venue: Venue) async throws


    /**
     Saves a list of venue entities.
     - Parameter venues: The list of venue entities to save.
     - Throws: An error if the save operation fails.
    */
    func saveVenues(_ venues: [Venue]) async throws

    /**
     Fetches a venue entity by its ID.
     
     - Parameter id: The ID of the venue to fetch.
     - Returns: An optional venue entity.
     - Throws: An error if the fetch operation fails.
     */
    func fetchVenue(by id: VenueId) async throws -> Venue?

    /**
     Fetches a list of venues by their IDs.
     
     - Parameter ids: The list of venue IDs to fetch. If nil, fetches all venues.
     - Returns: An array of venues.
     - Throws: An error if the fetch operation fails.
     */
    func fetchVenues(by ids: [VenueId]?) async throws -> [Venue]

    // MARK: - Search Result Operations

    /**
     Saves search results for a given search request.
     
     - Parameters:
       - request: The search request.
       - venueIds: The list of venue IDs to save.
     - Throws: An error if the save operation fails.
     */
    func saveSearchResults(for request: SearchVenuesRequest, venueIds: [VenueId]) async throws

    /**
     Fetches search results for a given search request.
     
     - Parameter request: The search request.
     - Returns: An optional array of venue IDs matching the search request.
     - Throws: An error if the fetch operation fails.
     */
    func fetchSearchResults(for request: SearchVenuesRequest) async throws -> [VenueId]?
}