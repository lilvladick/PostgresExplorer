import Combine
import Foundation

@MainActor
class ConnectionViewModel: ObservableObject {
    @Published var service: PostgresService?
    @Published var errorMessage: String?
    @Published var connectionStatus: ConnectionStatus? = nil
    
    @Published var databases: [String] = []
    @Published var tablesByDatabase: [String: [String]] = [:]
    @Published var loadingTables: Set<String> = []
    
    @Published var selectedDatabase: String?
    @Published var selectedTable: String?
    @Published var tableColumns: [String] = []
    @Published var tableRows: [[String]] = []

    enum ConnectionStatus {
        case success
        case failure(String)
    }

    func connect(host: String, port: Int, user: String, password: String, database: String) {
        do {
            let service = PostgresService(
                host: host,
                port: port,
                database: database,
                user: user,
                password: password
            )
            try service.testConnection()
            self.service = service

            let dbs = try service.fetchDatabases()
            self.databases = dbs

            connectionStatus = .success
        } catch {
            self.errorMessage = error.localizedDescription
            connectionStatus = .failure(errorMessage ?? "")
        }
    }

    func fetchTables(for database: String, force: Bool = false) {
        guard let service else { return }
        if !force, tablesByDatabase[database] != nil { return }

        Task {
            loadingTables.insert(database)
            defer { loadingTables.remove(database) }

            do {
                let tables = try service.fetchTables(database: database)
                self.tablesByDatabase[database] = tables
            } catch {
                self.tablesByDatabase[database] = []
                self.errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    func fetchTableData(database: String, table: String) {
        guard let service else { return }
        Task {
            do {
                let result = try service.fetchTableData(database: database, table: table)
                self.tableColumns = result.columns
                self.tableRows = result.rows
                self.selectedDatabase = database
                self.selectedTable = table
            } catch {
                self.errorMessage = "Error: \(error.localizedDescription)"
                self.tableColumns = []
                self.tableRows = []
            }
        }
    }
}
