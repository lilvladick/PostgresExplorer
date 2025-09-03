import SwiftUI

struct SettingsView: View {
    @AppStorage("isDarkMode") private var isDarkMode: Bool = false
    @State private var showConnectionSettings = false

    var body: some View {
        VStack(spacing: 20) {
            Toggle(isOn: $isDarkMode) {
                Text("Dark Mode")
                    .fontWeight(.medium)
            }
            .toggleStyle(SwitchToggleStyle(tint: .blue))
            
            Button(action: {
                showConnectionSettings = true
            }) {
                Text("Connection Settings")
            }
            .sheet(isPresented: $showConnectionSettings) {
                ConnectionSettingsView()
            }

        }
        .padding()
        .frame(minWidth: 400, minHeight: 300)
        .navigationTitle("Settings")
    }
}

#Preview {
    SettingsView()
        .frame(width: 400, height: 350)
}
