import Foundation

// MARK: - Persistence Protocol

public protocol PersistenceService {
    associatedtype EntityType: Codable & Equatable

    /**
     Saves an entity to the persistence layer with a specific key.
     
     - Parameters:
       - entity: The entity to save.
       - key: The key to associate with the entity.
     - Throws: An error if the save operation fails.
     */
    func save(entity: EntityType, forKey key: String) async throws

    /**
     Fetches an entity from the persistence layer by key.
     
     - Parameter key: The key associated with the entity.
     - Returns: The entity associated with the key, or nil if not found.
     - Throws: An error if the fetch operation fails.
     */
    func fetch(forKey key: String) async throws -> EntityType?

    /**
     Deletes an entity from the persistence layer by key.
     
     - Parameter key: The key associated with the entity.
     - Throws: An error if the delete operation fails.
     */
    func delete(forKey key: String) async throws
}

// MARK: - PersistenceError

public enum PersistenceError: Error {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
}

// MARK: - UserDefaultsPersistence

public final class UserDefaultsPersistenceService<EntityType: Codable & Equatable>: PersistenceService {

    // MARK: - Properties

    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - Persistence Implementation

    public func save(entity: EntityType, forKey key: String) async throws {
        do {
            let data = try encoder.encode(entity)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            throw PersistenceError.saveFailed(error)
        }
    }

    public func fetch(forKey key: String) async throws -> EntityType? {
        do {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return nil
            }
            return try decoder.decode(EntityType.self, from: data)
        } catch {
            throw PersistenceError.fetchFailed(error)
        }
    }

    public func delete(forKey key: String) async throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Core Data Persistence
// I will get to implementing this later in case I have enough time to play around with it.