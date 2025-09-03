import PostgresClientKit

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

    func fetchTables() throws -> [String] {
        let connection = try PostgresClientKit.Connection(configuration: config)
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
}
