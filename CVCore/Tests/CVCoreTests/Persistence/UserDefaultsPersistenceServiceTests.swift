import XCTest
@testable import CVCore

final class UserDefaultsPersistenceServiceTests: XCTestCase {

    private var persistenceService: UserDefaultsPersistenceService<TestEntity>!
    private let testKey = "testKey"

    override func setUp() {
        super.setUp()
        persistenceService = UserDefaultsPersistenceService<TestEntity>(key: testKey)
        UserDefaults.standard.removeObject(forKey: testKey)
    }

    override func tearDown() {
        UserDefaults.standard.removeObject(forKey: testKey)
        persistenceService = nil
        super.tearDown()
    }

    func testSaveEntity() async throws {
        let entity = TestEntity(id: "1", name: "Test Entity")
        try await persistenceService.save(entity: entity)

        let fetchedEntities = try await persistenceService.fetchAll()
        XCTAssertEqual(fetchedEntities, [entity])
    }

    func testFetchAllEntities() async throws {
        let entity1 = TestEntity(id: "1", name: "Test Entity 1")
        let entity2 = TestEntity(id: "2", name: "Test Entity 2")
        try await persistenceService.save(entity: entity1)
        try await persistenceService.save(entity: entity2)

        let fetchedEntities = try await persistenceService.fetchAll()
        XCTAssertEqual(fetchedEntities, [entity1, entity2])
    }

    func testFetchEntitiesWithPredicate() async throws {
        let entity1 = TestEntity(id: "1", name: "Test Entity 1")
        let entity2 = TestEntity(id: "2", name: "Test Entity 2")
        try await persistenceService.save(entity: entity1)
        try await persistenceService.save(entity: entity2)

        let fetchedEntities = try await persistenceService.fetch { $0.id == "1" }
        XCTAssertEqual(fetchedEntities, [entity1])
    }

    func testDeleteEntity() async throws {
        let entity = TestEntity(id: "1", name: "Test Entity")
        try await persistenceService.save(entity: entity)
        try await persistenceService.delete(entity: entity)

        let fetchedEntities = try await persistenceService.fetchAll()
        XCTAssertTrue(fetchedEntities.isEmpty)
    }

    func testDeleteAllEntities() async throws {
        let entity1 = TestEntity(id: "1", name: "Test Entity 1")
        let entity2 = TestEntity(id: "2", name: "Test Entity 2")
        try await persistenceService.save(entity: entity1)
        try await persistenceService.save(entity: entity2)
        try await persistenceService.deleteAll()

        let fetchedEntities = try await persistenceService.fetchAll()
        XCTAssertTrue(fetchedEntities.isEmpty)
    }
}

// MARK: - TestEntity

struct TestEntity: Codable, Equatable {
    let id: String
    let name: String
}
