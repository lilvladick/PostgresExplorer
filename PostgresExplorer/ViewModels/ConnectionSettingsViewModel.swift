import SwiftUI
import PostgresClientKit
import Combine

@MainActor
class ConnectionViewModel: ObservableObject {
    @Published var service: PostgresService?
    @Published var errorMessage: String?
    @Published var connectionStatus: ConnectionStatus? = nil
    
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
            connectionStatus = .success
        } catch {
            self.errorMessage = error.localizedDescription
            connectionStatus = .failure(errorMessage ?? "")
        }
    }
}
