import SwiftUI

struct DatabaseView: View {
    @EnvironmentObject var connectionVM: ConnectionViewModel
    
    @State private var selectedDatabase: String?
    @State private var selectedTable: String?
    @State private var expandedDatabases: Set<String> = []
    
    @Environment(\.openWindow) private var openWindow

    var body: some View {
        NavigationSplitView {
            List {
                ForEach(connectionVM.databases, id: \.self) { db in
                    DisclosureGroup(
                        isExpanded: Binding(
                            get: { expandedDatabases.contains(db) },
                            set: { newValue in
                                if newValue {
                                    expandedDatabases.insert(db)
                                    connectionVM.fetchTables(for: db, force: false)
                                } else {
                                    expandedDatabases.remove(db)
                                }
                            }
                        )
                    ) {
                        if let tables = connectionVM.tablesByDatabase[db] {
                            if tables.isEmpty {
                                Text("No tables")
                            } else {
                                ForEach(tables, id: \.self) { table in
                                    Button {
                                        connectionVM.fetchTableData(database: db, table: table)
                                    } label: {
                                        Text(table)
                                    }
                                    .buttonStyle(.plain)
                                    .contextMenu {
                                        Button("Delete table") {
                                            connectionVM.deleteTable(database: db, table: table)
                                        }
                                    }
                                }
                            }
                        }
                    } label: {
                        Text(db)
                            .contextMenu {
                                Button("Refresh data") {
                                    connectionVM.fetchTables(for: db, force: true)
                                }
                                Button("Delete database") {
                                    connectionVM.deleteDatabase(db)
                                }
                            }
                    }
                }
            }
            .navigationTitle("Databases")
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Button("Open Console") {
                        openWindow(id: "sqlConsole")
                    }
                }
            }
        } detail: {
            if let selectedTable = connectionVM.selectedTable,
               let selectedDatabase = connectionVM.selectedDatabase {
                TableDetailsView(
                    columns: connectionVM.tableColumns,
                    rows: connectionVM.tableRows,
                    database: selectedDatabase,
                    table: selectedTable
                )
            }
        }
    }
}

#Preview {
    DatabaseView()
        .environmentObject(ConnectionViewModel())
}
