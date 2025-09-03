import SwiftUI

struct ConnectionSettingsView: View {
    @State private var host: String = "localhost"
    @State private var port: String = "5432"
    @State private var user: String = "admin"
    @State private var password: String = "admin"
    @State private var database: String = "postgres"
    
    @State private var testResult: String = ""
    @State private var connectionSuccess: Bool? = nil
    
    var body: some View {
        Form {
            Section() {
                TextField("Host", text: $host)
                TextField("Port", text: $port)
                TextField("User", text: $user)
                SecureField("Password", text: $password)
                TextField("Database", text: $database)
            }
            
            Section {
                Button("Connect") {
                    makeConnection()
                }
                .padding()
                .foregroundStyle(buttonColor())
            }
        }
        .navigationTitle("Connection Settings")
        .padding()
        .frame(width: 300, height: 250)
    }
    
    private func buttonColor() -> Color {
        if let success = connectionSuccess {
            return success ? .green : .red
        } else {
            return .indigo
        }
    }
    
    private func makeConnection() {
        do {
            let service = PostgresService(
                host: host,
                port: Int(port) ?? 5432,
                database: database,
                user: user,
                password: password
            )
            try service.testConnection()
            testResult = "Successful"
            connectionSuccess = true
        } catch {
            testResult = "Error: \(error)"
            connectionSuccess = false
        }
    }
}

#Preview {
    ConnectionSettingsView()
}
