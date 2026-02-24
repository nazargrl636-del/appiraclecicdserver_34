import SwiftUI

struct SettingsView: View {
    @State private var notificationManager = NotificationManager.shared
    @AppStorage("defaultNotificationEnabled") private var defaultNotificationEnabled = true
    @AppStorage("defaultRepeatInterval") private var defaultRepeatInterval = RepeatInterval.none.rawValue

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                Text("Settings")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundStyle(.white)
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 4)

                Form {
                    notificationSection
                        .listRowBackground(Color.darkSurface)
                    defaultsSection
                }
                .scrollContentBackground(.hidden)
            }
            .background(Color.darkBackground)
            .navigationBarHidden(true)
        }
    }

    private var notificationSection: some View {
        Section {
            HStack {
                Label("Notifications", systemImage: "bell.fill")
                Spacer()
                if notificationManager.isAuthorized {
                    Text("Enabled")
                        .foregroundStyle(.green)
                } else {
                    Button("Enable") {
                        Task {
                            await notificationManager.requestAuthorization()
                        }
                    }
                }
            }
        } header: {
            Text("Notifications")
        } footer: {
            Text("Enable notifications to receive reminders for pet care tasks")
        }
    }

    private var defaultsSection: some View {
        Section("Default Settings") {
            Toggle("Enable Reminders by Default", isOn: $defaultNotificationEnabled)
                .listRowBackground(Color.darkSurface)

            Picker("Default Repeat", selection: $defaultRepeatInterval) {
                ForEach(RepeatInterval.allCases, id: \.self) { interval in
                    Text(interval.rawValue).tag(interval.rawValue)
                }
            }
            .listRowBackground(Color.darkSurface)
        }
    }
}

#Preview {
    SettingsView()
}
