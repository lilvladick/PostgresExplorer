import SwiftUI

struct SidebarView: View {
    @State var selectedTabs: Tabs = .databases
   
    var body: some View {
        TabView(selection: $selectedTabs) {
            Tab("Databases", systemImage: "list.bullet.rectangle.fill", value: .databases) {
                EmptyView()
            }
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    SidebarView()
}
