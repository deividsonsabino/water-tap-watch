import Foundation
import UserNotifications

enum NotificationManager {
    static let summaryId = "water.summary"

    @discardableResult
    static func requestAuthorization() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    static func scheduleEndOfDaySummary(atHour hour: Int = 21, minute: Int = 0) async {
        let center = UNUserNotificationCenter.current()

        // Remove any pending summary request to avoid duplicates
        center.removePendingNotificationRequests(withIdentifiers: [summaryId])

        var date = DateComponents()
        date.hour = hour
        date.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: date, repeats: true)

        let content = UNMutableNotificationContent()
        content.title = "Daily summary"
        content.body = "How much water did you drink today?"
        content.sound = .default

        let request = UNNotificationRequest(identifier: summaryId, content: content, trigger: trigger)
        do {
            try await center.add(request)
        } catch {
            // Silently ignore for now; could log if needed
        }
    }

    static func cancelEndOfDaySummary() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [summaryId])
    }
}
