import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}
    
    func bootstrap() {
        UNUserNotificationCenter.current().getNotificationSettings { _ in }
    }
    
    func requestPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, _ in
            completion(granted)
        }
    }
    
    /// Планирует локальный пуш на завтра в 12:00 (локальное время устройства)
    func scheduleNoonTomorrowReminder() {
        // Сначала очистим старые, чтобы не копить
        cancelAll()
        
        var date = Date()
        let calendar = Calendar.current
        if let tomorrow = calendar.date(byAdding: .day, value: 1, to: date) {
            date = tomorrow
        }
        var comps = calendar.dateComponents([.year, .month, .day], from: date)
        comps.hour = 12
        comps.minute = 0
        comps.second = 0
        
        let content = UNMutableNotificationContent()
        content.title = NSLocalizedString("notif_title", comment: "")
        content.body = NSLocalizedString("notif_body", comment: "")
        content.sound = .default
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: comps, repeats: false)
        let req = UNNotificationRequest(identifier: "noon_tomorrow_reminder", content: content, trigger: trigger)
        UNUserNotificationCenter.current().add(req, withCompletionHandler: nil)
    }
    
    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        UNUserNotificationCenter.current().removeAllDeliveredNotifications()
    }
}
