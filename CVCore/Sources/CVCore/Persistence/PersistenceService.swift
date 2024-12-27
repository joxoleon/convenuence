import Foundation

// MARK: - Persistence Protocol

protocol PersistenceService {
    associatedtype EntityType: Codable & Equatable

    /**
     Saves an entity to the persistence layer.
     
     - Parameter entity: The entity to save.
     - Throws: An error if the save operation fails.
     */
    func save(entity: EntityType) async throws

    /**
     Fetches all entities from the persistence layer.
     
     - Returns: An array of all entities.
     - Throws: An error if the fetch operation fails.
     */
    func fetchAll() async throws -> [EntityType]

    /**
     Fetches entities matching the given predicate.
     
     - Parameter predicate: A closure used to filter the entities.
     - Returns: An array of entities matching the predicate.
     - Throws: An error if the fetch operation fails.
     */
    func fetch(predicate: ((EntityType) -> Bool)?) async throws -> [EntityType]

    /**
     Deletes a specific entity from the persistence layer.
     
     - Parameter entity: The entity to delete.
     - Throws: An error if the delete operation fails.
     */
    func delete(entity: EntityType) async throws

    /**
     Deletes all entities from the persistence layer.
     
     - Throws: An error if the delete operation fails.
     */
    func deleteAll() async throws
}

// MARK: - PersistenceError

enum PersistenceError: Error {
    case saveFailed(Error)
    case fetchFailed(Error)
    case deleteFailed(Error)
}

// MARK: - UserDefaultsPersistence

final class UserDefaultsPersistenceService<EntityType: Codable & Equatable>: PersistenceService {

    // MARK: - Properties

    private let key: String
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - Initializer

    init(key: String) {
        self.key = key
    }

    // MARK: - Persistence Implementation

    func save(entity: EntityType) async throws {
        do {
            var entities = try await fetchAll()
            if !entities.contains(entity) {
                entities.append(entity)
                let data = try encoder.encode(entities)
                UserDefaults.standard.set(data, forKey: key)
            }
        } catch {
            throw PersistenceError.saveFailed(error)
        }
    }

    func fetchAll() async throws -> [EntityType] {
        do {
            guard let data = UserDefaults.standard.data(forKey: key) else {
                return []
            }
            return try decoder.decode([EntityType].self, from: data)
        } catch {
            throw PersistenceError.fetchFailed(error)
        }
    }

    func fetch(predicate: ((EntityType) -> Bool)?) async throws -> [EntityType] {
        do {
            let entities = try await fetchAll()
            guard let predicate = predicate else {
                return entities
            }
            return entities.filter(predicate)
        } catch {
            throw PersistenceError.fetchFailed(error)
        }
    }

    func delete(entity: EntityType) async throws {
        do {
            var entities = try await fetchAll()
            entities.removeAll { $0 == entity }
            let data = try encoder.encode(entities)
            UserDefaults.standard.set(data, forKey: key)
        } catch {
            throw PersistenceError.deleteFailed(error)
        }
    }

    func deleteAll() async throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}

// MARK: - Core Data Persistence
// I will get to implementing this later in case I have enough time to play around with it.