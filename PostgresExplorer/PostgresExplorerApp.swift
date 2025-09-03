//
//  PostgresExplorerApp.swift
//  PostgresExplorer
//
//  Created by Владислав Кириллов on 03.09.2025.
//

import SwiftUI

@main
struct PostgresExplorerApp: App {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    
    var body: some Scene {
        WindowGroup {
            SidebarView().preferredColorScheme(isDarkMode ? .dark : .light)
        }
    }
}
