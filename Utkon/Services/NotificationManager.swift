import Foundation
import UserNotifications
import Observation

@Observable
@MainActor
final class NotificationManager {
    static let shared = NotificationManager()

    var isAuthorized = false

    private init() {
        Task {
            await checkAuthorization()
        }
    }

    func requestAuthorization() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
            isAuthorized = granted
            return granted
        } catch {
            return false
        }
    }

    func checkAuthorization() async {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        isAuthorized = settings.authorizationStatus == .authorized
    }

    func scheduleNotification(for task: CareTask, petName: String) async -> String? {
        if !isAuthorized {
            _ = await requestAuthorization()
            if !isAuthorized { return nil }
        }

        let content = UNMutableNotificationContent()
        content.title = "Pet Care Reminder"
        content.body = "\(task.displayType) for \(petName)"
        content.sound = .default
        content.badge = 1

        let triggerDate = Calendar.current.dateComponents([.year, .month, .day, .hour, .minute], from: task.scheduledDate)
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerDate, repeats: false)

        let identifier = UUID().uuidString
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)

        do {
            try await UNUserNotificationCenter.current().add(request)
            return identifier
        } catch {
            return nil
        }
    }

    func cancelNotification(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
    }

    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
    }

    func updateBadge(count: Int) {
        UNUserNotificationCenter.current().setBadgeCount(count)
    }
}
