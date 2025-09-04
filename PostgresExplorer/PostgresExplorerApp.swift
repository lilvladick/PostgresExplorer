//
//  PostgresExplorerApp.swift
//  PostgresExplorer
//
//  Created by Владислав Кириллов on 03.09.2025.
//

import SwiftUI

@main
struct PostgresExplorerApp: App {
    @StateObject private var connectionVM = ConnectionViewModel()
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            TabBarView()
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .environmentObject(connectionVM)
                .tint(Color.indigo)
        }
        Window("SQL Console", id: "sqlConsole") {
            SQLConsoleView()
                .environmentObject(connectionVM)
                .preferredColorScheme(isDarkMode ? .dark : .light)
                .tint(Color.indigo)
        }.defaultSize(width: 600, height: 400)
    }
}
