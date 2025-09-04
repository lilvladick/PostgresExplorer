protocol PostgresServiceProtocol {
    func testConnection() throws
    func fetchDatabases() throws -> [String]
    func fetchTables(database: String) throws -> [String]
    func fetchTableData(database: String, table: String) throws -> (rows: [[String]], columns: [String])
    func deleteDatabase(_ database: String) throws
    func deleteTable(database: String, table: String) throws
    func executeSQL(database: String, sql: String) throws -> (rows: [[String]], columns: [String])
}
