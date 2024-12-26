import Foundation

// MARK: - Persistence Protocol

protocol Persistence {
    associatedtype EntityType: Codable & Equatable

    /**
     Saves an entity to the persistence layer.
     
     - Parameter entity: The entity to save.
     - Throws: An error if the save operation fails.
     */
    func save(entity: EntityType) throws

    /**
     Fetches all entities from the persistence layer.
     
     - Returns: An array of all entities.
     - Throws: An error if the fetch operation fails.
     */
    func fetchAll() throws -> [EntityType]

    /**
     Fetches entities matching the given predicate.
     
     - Parameter predicate: A closure used to filter the entities.
     - Returns: An array of entities matching the predicate.
     - Throws: An error if the fetch operation fails.
     */
    func fetch(predicate: ((EntityType) -> Bool)?) throws -> [EntityType]

    /**
     Deletes a specific entity from the persistence layer.
     
     - Parameter entity: The entity to delete.
     - Throws: An error if the delete operation fails.
     */
    func delete(entity: EntityType) throws

    /**
     Deletes all entities from the persistence layer.
     
     - Throws: An error if the delete operation fails.
     */
    func deleteAll() throws
}

// MARK: - UserDefaultsPersistence

final class UserDefaultsPersistence<EntityType: Codable & Equatable>: Persistence {

    // MARK: - Properties

    private let key: String
    private let decoder = JSONDecoder()
    private let encoder = JSONEncoder()

    // MARK: - Initializer

    init(key: String) {
        self.key = key
    }

    // MARK: - Persistence Implementation

    func save(entity: EntityType) throws {
        var entities = try fetchAll()
        if !entities.contains(entity) {
            entities.append(entity)
            let data = try encoder.encode(entities)
            UserDefaults.standard.set(data, forKey: key)
        }
    }

    func fetchAll() throws -> [EntityType] {
        guard let data = UserDefaults.standard.data(forKey: key) else {
            return []
        }
        return try decoder.decode([EntityType].self, from: data)
    }

    func fetch(predicate: ((EntityType) -> Bool)?) throws -> [EntityType] {
        let entities = try fetchAll()
        guard let predicate = predicate else {
            return entities
        }
        return entities.filter(predicate)
    }

    func delete(entity: EntityType) throws {
        var entities = try fetchAll()
        entities.removeAll { $0 == entity }
        let data = try encoder.encode(entities)
        UserDefaults.standard.set(data, forKey: key)
    }

    func deleteAll() throws {
        UserDefaults.standard.removeObject(forKey: key)
    }
}