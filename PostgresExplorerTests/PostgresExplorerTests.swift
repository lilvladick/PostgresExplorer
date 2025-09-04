import Testing
@testable import PostgresExplorer

struct PostgresExplorerTests {

    @Test func testConnectionSuccess() throws {
        let service = MockPostgresService(shouldThrow: false)
        try service.testConnection()
    }
    
    @Test func testConnectionFailure() {
        let service = MockPostgresService(shouldThrow: true)
        #expect(throws: Error.self) {
            try service.testConnection()
        }
    }
    
    @Test func testFetchDatabasesSuccess() throws {
        let service = MockPostgresService(shouldThrow: false)
        let dbs = try service.fetchDatabases()
        #expect(dbs == ["postgres", "testdb"])
    }
    
    @Test func testFetchDatabasesFailure() {
        let service = MockPostgresService(shouldThrow: true)
        #expect(throws: Error.self) {
            _ = try service.fetchDatabases()
        }
    }
    
    @Test func testFetchTablesSuccess() throws {
        let service = MockPostgresService(shouldThrow: false)
        let tables = try service.fetchTables(database: "testdb")
        #expect(tables == ["users", "orders"])
    }
    
    @Test func testFetchTableDataSuccess() throws {
        let service = MockPostgresService(shouldThrow: false)
        let result = try service.fetchTableData(database: "testdb", table: "users")
        #expect(result.columns == ["id", "name"])
        #expect(result.rows.count == 2)
    }
    
    @Test func testDeleteDatabaseFailure() {
        let service = MockPostgresService(shouldThrow: true)
        #expect(throws: Error.self) {
            try service.deleteDatabase("testdb")
        }
    }
    
    @Test func testExecuteSQLSelect() throws {
        let service = MockPostgresService(shouldThrow: false)
        let result = try service.executeSQL(database: "testdb", sql: "SELECT 1;")
        #expect(result.columns == ["result"])
        #expect(result.rows == [["1"]])
    }
    
    @Test func testExecuteSQLNonSelect() throws {
        let service = MockPostgresService(shouldThrow: false)
        let result = try service.executeSQL(database: "testdb", sql: "CREATE TABLE foo (id INT);")
        #expect(result.columns.isEmpty)
        #expect(result.rows.isEmpty)
    }
}
