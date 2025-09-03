import SwiftUI

struct TabBarView: View {
    @State var selectedTabs: Tabs = .databases
   
    var body: some View {
        TabView(selection: $selectedTabs) {
            Tab("Databases", systemImage: "list.bullet.rectangle.fill", value: .databases) {
                DatabaseView()
            }
            Tab("Settings", systemImage: "gearshape", value: .settings) {
                SettingsView()
            }
        }
    }
}

#Preview {
    TabBarView()
}
