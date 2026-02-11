import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            PetListView()
                .tabItem {
                    Label("Pets", systemImage: "pawprint.fill")
                }
                .tag(0)

            TasksOverviewView()
                .tabItem {
                    Label("Tasks", systemImage: "checklist")
                }
                .tag(1)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(2)
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [Pet.self, CareTask.self], inMemory: true)
}
