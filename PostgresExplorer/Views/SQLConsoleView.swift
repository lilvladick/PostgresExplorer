import SwiftUI

struct SQLConsoleView: View {
    @EnvironmentObject var connectionVM: ConnectionViewModel
    @State private var sql: String = ""
    @State private var selectedDatabase: String = "postgres"
    @State private var showAlert: Bool = false

    var body: some View {
        VStack {
            Picker("Database", selection: $selectedDatabase) {
                ForEach(connectionVM.databases, id: \.self) { db in
                    Text(db).tag(db)
                }
            }
            .pickerStyle(.segmented)
            .padding()

            TextEditor(text: $sql)
                .font(.system(.body, design: .monospaced))
                .frame(minHeight: 150)
                .border(Color.gray.opacity(0.5))

            Button("Run SQL") {
                connectionVM.runSQLConsole(database: selectedDatabase, sql: sql)
                showAlert.toggle()
            }
            .buttonStyle(.borderedProminent)
            .padding()
            .alert("Command result", isPresented: $showAlert) {
                Button("OK", role: .cancel) {}
            } message: {
                if connectionVM.consoleOutput.isEmpty == true {
                    Text("Success")
                } else {
                    Text(connectionVM.consoleOutput)
                }
            }
        }
        .padding()
        .navigationTitle("SQL Console")
    }
}

#Preview {
    SQLConsoleView()
        .environmentObject(ConnectionViewModel())
}
