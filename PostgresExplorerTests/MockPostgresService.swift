import Foundation

struct MockPostgresService: PostgresServiceProtocol {
    var shouldThrow = false
    
    func testConnection() throws {
        if shouldThrow { throw NSError(domain: "MockError", code: 1) }
    }
    
    func fetchDatabases() throws -> [String] {
        if shouldThrow { throw NSError(domain: "MockError", code: 2) }
        return ["postgres", "testdb"]
    }
    
    func fetchTables(database: String) throws -> [String] {
        if shouldThrow { throw NSError(domain: "MockError", code: 3) }
        return ["users", "orders"]
    }
    
    func fetchTableData(database: String, table: String) throws -> (rows: [[String]], columns: [String]) {
        if shouldThrow { throw NSError(domain: "MockError", code: 4) }
        return (
            rows: [["1", "Alice"], ["2", "Bob"]],
            columns: ["id", "name"]
        )
    }
    
    func deleteDatabase(_ database: String) throws {
        if shouldThrow { throw NSError(domain: "MockError", code: 5) }
    }
    
    func deleteTable(database: String, table: String) throws {
        if shouldThrow { throw NSError(domain: "MockError", code: 6) }
    }
    
    func executeSQL(database: String, sql: String) throws -> (rows: [[String]], columns: [String]) {
        if shouldThrow { throw NSError(domain: "MockError", code: 7) }
        
        if sql.lowercased().starts(with: "select") {
            return (rows: [["1"]], columns: ["result"])
        } else {
            return (rows: [], columns: [])
        }
    }
}
