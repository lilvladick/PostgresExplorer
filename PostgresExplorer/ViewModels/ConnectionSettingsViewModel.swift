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
    
    @Published var consoleOutput: String = ""

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
    
    func deleteDatabase(_ db: String) {
        guard let service else { return }
        Task {
            do {
                try service.deleteDatabase(db)
                databases.removeAll { $0 == db }
                tablesByDatabase.removeValue(forKey: db)
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }

    func deleteTable(database: String, table: String) {
        guard let service else { return }
        Task {
            do {
                try service.deleteTable(database: database, table: table)
                tablesByDatabase[database]?.removeAll { $0 == table }
            } catch {
                errorMessage = "Error: \(error.localizedDescription)"
            }
        }
    }
    
    func runSQLConsole(database: String, sql: String) {
        guard let service else { return }

        Task {
            do {
                let result = try service.executeSQL(database: database, sql: sql)

                if result.rows.isEmpty {
                    consoleOutput = "Query executed successfully"
                } else {
                    let header = result.columns.joined(separator: " | ")
                    let body = result.rows.map { $0.joined(separator: " | ") }.joined(separator: "\n")
                    consoleOutput = "\(header)\n\(body)"
                }
                
                let lowered = sql.lowercased()
                if lowered.contains("create database") || lowered.contains("drop database") {
                    let dbs = try service.fetchDatabases()
                    self.databases = dbs
                } else if lowered.contains("create table") || lowered.contains("drop table") {
                    if let currentDB = self.selectedDatabase {
                        let tables = try service.fetchTables(database: currentDB)
                        self.tablesByDatabase[currentDB] = tables
                    }
                }
            } catch {
                consoleOutput = "Error: \(error.localizedDescription)"
            }
        }
    }
}
