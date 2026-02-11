import SwiftUI
import SwiftData

@main
struct UtkonApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    Task {
                        await NotificationManager.shared.requestAuthorization()
                    }
                }
        }
        .modelContainer(for: [Pet.self, CareTask.self])
    }
}
