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
    }
}
