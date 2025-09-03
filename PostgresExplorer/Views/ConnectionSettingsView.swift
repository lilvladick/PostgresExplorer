import SwiftUI

struct ConnectionSettingsView: View {
    @Environment(\.dismiss) private var dismiss
    @EnvironmentObject var connectionVM: ConnectionViewModel

    @State private var host: String = "localhost"
    @State private var port: String = "5432"
    @State private var user: String = "admin"
    @State private var password: String = "admin"
    @State private var database: String = "postgres"
    
    @State private var showAlert = false

    var body: some View {
        Form {
            Section {
                TextField("Host", text: $host)
                TextField("Port", text: $port)
                TextField("User", text: $user)
                SecureField("Password", text: $password)
                TextField("Database", text: $database)
            }
        }
        .navigationTitle("Connection Settings")
        .padding()
        .toolbar {
            ToolbarItem(placement: .cancellationAction) {
                Button("Close") { dismiss() }
            }
            ToolbarItem(placement: .confirmationAction) {
                Button("Connect") {
                    connectionVM.connect(
                        host: host,
                        port: Int(port) ?? 5432,
                        user: user,
                        password: password,
                        database: database
                    )
                    showAlert = true
                }
            }
        }
        .alert(isPresented: $showAlert) {
            switch connectionVM.connectionStatus {
            case .success:
                return Alert(title: Text("Success"),
                             message: Text("Connection established."),
                             dismissButton: .default(Text("OK")) {
                                 dismiss()
                             })
            case .failure(let message):
                return Alert(title: Text("Error"),
                             message: Text(message),
                             dismissButton: .default(Text("OK")))
            case .none:
                return Alert(title: Text("Unknown Error"),
                             message: Text("Unknown Error"),
                             dismissButton: .default(Text("OK")))
            }
        }
    }
}

#Preview {
    ConnectionSettingsView()
        .environmentObject(ConnectionViewModel())
}
