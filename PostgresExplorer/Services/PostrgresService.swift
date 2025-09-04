import PostgresClientKit
import Foundation

struct PostgresService {
    private var config: PostgresClientKit.ConnectionConfiguration

    init(host: String, port: Int, database: String, user: String, password: String) {
        var configuration = PostgresClientKit.ConnectionConfiguration()
        configuration.host = host
        configuration.port = port
        configuration.database = database
        configuration.user = user
        configuration.credential = .scramSHA256(password: password)
        configuration.ssl = false
        self.config = configuration
    }
    
    func testConnection() throws {
        let connection = try PostgresClientKit.Connection(configuration: config)
        connection.close()
    }

    func fetchDatabases() throws -> [String] {
        let connection = try PostgresClientKit.Connection(configuration: config)
        defer { connection.close() }

        let statement = try connection.prepareStatement(
            text: "SELECT datname FROM pg_database WHERE datistemplate = false;"
        )
        defer { statement.close() }

        let cursor = try statement.execute()
        defer { cursor.close() }

        var databases: [String] = []
        for row in cursor {
            let columns = try row.get().columns
            let dbName = try columns[0].string()
            databases.append(dbName)
        }
        return databases
    }

    func fetchTables(database: String) throws -> [String] {
        var dbConfig = config
        dbConfig.database = database
        
        let connection = try PostgresClientKit.Connection(configuration: dbConfig)
        defer { connection.close() }

        let statement = try connection.prepareStatement(
            text: "SELECT table_name FROM information_schema.tables WHERE table_schema = 'public';"
        )
        defer { statement.close() }

        let cursor = try statement.execute()
        defer { cursor.close() }

        var tables: [String] = []
        for row in cursor {
            let columns = try row.get().columns
            let tableName = try columns[0].string()
            tables.append(tableName)
        }
        return tables
    }
    
    func fetchTableData(database: String, table: String) throws -> (rows: [[String]], columns: [String]) {
        var dbConfig = config
        dbConfig.database = database

        let connection = try PostgresClientKit.Connection(configuration: dbConfig)
        defer { connection.close() }

        let sql = "SELECT * FROM \(table);"

        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }

        let cursor = try statement.execute(retrieveColumnMetadata: true)
        defer { cursor.close() }

        let columns = (cursor.columns ?? []).map { $0.name }

        var rows: [[String]] = []
        for row in cursor {
            let cols = try row.get().columns
            let values = try cols.map { try $0.optionalString() ?? "NULL" }
            rows.append(values)
        }

        return (rows, columns)
    }
    
    func deleteDatabase(_ database: String) throws {
        var dbConfig = config
        dbConfig.database = "postgres" // без этого удаление не сработает, т.к. нельзя удалить базу к которой ты подключен

        let connection = try PostgresClientKit.Connection(configuration: dbConfig)
        defer { connection.close() }

        let sql = "DROP DATABASE \(quoteIdent(database));"
        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }
        _ = try statement.execute()
    }

    func deleteTable(database: String, table: String) throws {
        var dbConfig = config
        dbConfig.database = database

        let connection = try PostgresClientKit.Connection(configuration: dbConfig)
        defer { connection.close() }

        let sql = "DROP TABLE \(quoteIdent(table));"
        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }
        _ = try statement.execute()
    }
    
    func executeSQL(database: String, sql: String) throws -> (rows: [[String]], columns: [String]) {
        var dbConfig = config
        dbConfig.database = database

        let connection = try PostgresClientKit.Connection(configuration: dbConfig)
        defer { connection.close() }

        let statement = try connection.prepareStatement(text: sql)
        defer { statement.close() }

        let cursor = try statement.execute(retrieveColumnMetadata: true)
        defer { cursor.close() }

        let columns = (cursor.columns ?? []).map { $0.name }

        var rows: [[String]] = []
        for row in cursor {
            let cols = try row.get().columns
            let values = try cols.map { try $0.optionalString() ?? "NULL" }
            rows.append(values)
        }

        return (rows, columns)
    }
    
    // помогает если имя таблицы имеет пробелы и спецсимволы (постгря экранирует их в ковычки)
    private func quoteIdent(_ ident: String) -> String {
        "\"\(ident.replacingOccurrences(of: "\"", with: "\"\""))\""
    }
}
