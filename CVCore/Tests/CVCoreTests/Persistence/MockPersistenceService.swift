@testable import CVCore

final class MockPersistenceService<EntityType: Codable & Equatable>: PersistenceService {

    private var storage: [EntityType] = []

    func save(entity: EntityType) async throws {
        storage.append(entity)
    }

    func fetchAll() async throws -> [EntityType] {
        return storage
    }

    func fetch(predicate: ((EntityType) -> Bool)?) async throws -> [EntityType] {
        guard let predicate = predicate else {
            return storage
        }
        return storage.filter(predicate)
    }

    func delete(entity: EntityType) async throws {
        storage.removeAll { $0 == entity }
    }

    func deleteAll() async throws {
        storage.removeAll()
    }
}