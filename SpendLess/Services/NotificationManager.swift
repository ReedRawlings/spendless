//
//  NotificationManager.swift
//  SpendLess
//
//  Manages local notifications for shield restoration and waiting list reminders
//

import Foundation
import UserNotifications

final class NotificationManager: NSObject {
    
    // MARK: - Singleton
    
    static let shared = NotificationManager()
    
    // MARK: - Initialization
    
    private override init() {
        super.init()
        registerNotificationCategories()
    }
    
    // MARK: - Request Permission
    
    /// Request notification permission
    func requestPermission() async -> Bool {
        do {
            let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .sound, .badge])
            return granted
        } catch {
            return false
        }
    }
    
    /// Check if notification permission is granted
    func checkPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    /// Get current authorization status
    func getAuthorizationStatus() async -> UNAuthorizationStatus {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus
    }
    
    // MARK: - Register Categories
    
    private func registerNotificationCategories() {
        // Shield restore category
        let restoreAction = UNNotificationAction(
            identifier: "RESTORE_ACTION",
            title: "Restore Shield",
            options: [.foreground]
        )
        
        let shieldRestoreCategory = UNNotificationCategory(
            identifier: AppConstants.shieldRestoreNotificationCategory,
            actions: [restoreAction],
            intentIdentifiers: [],
            options: []
        )
        
        // Waiting list check-in category (Day 3) with background actions
        let keepOnListAction = UNNotificationAction(
            identifier: AppConstants.WaitingListNotificationActions.keepOnList,
            title: "Keep on List",
            options: [.authenticationRequired] // Background action, no .foreground
        )
        
        let buryItAction = UNNotificationAction(
            identifier: AppConstants.WaitingListNotificationActions.buryIt,
            title: "Bury It",
            options: [.authenticationRequired, .destructive] // Background action, destructive styling
        )
        
        let waitingListCheckinCategory = UNNotificationCategory(
            identifier: AppConstants.waitingListCheckinNotificationCategory,
            actions: [keepOnListAction, buryItAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([
            shieldRestoreCategory,
            waitingListCheckinCategory
        ])
    }
    
    // MARK: - Notification Preferences
    
    /// Check if waiting list reminders are enabled (default: true)
    var isWaitingListRemindersEnabled: Bool {
        get {
            let defaults = UserDefaults.standard
            // If key doesn't exist, default to true
            if defaults.object(forKey: AppConstants.NotificationPreferenceKeys.waitingListRemindersEnabled) == nil {
                return true
            }
            return defaults.bool(forKey: AppConstants.NotificationPreferenceKeys.waitingListRemindersEnabled)
        }
        set {
            UserDefaults.standard.set(newValue, forKey: AppConstants.NotificationPreferenceKeys.waitingListRemindersEnabled)
        }
    }
    
    // MARK: - Shield Restoration Notifications
    
    /// Schedule a notification for shield restoration after 10 minutes
    func scheduleRestoreNotification(appName: String, in minutes: Int = 10) {
        let content = UNMutableNotificationContent()
        content.title = "Shield Restoration"
        content.body = "Your 10-minute access to \(appName) has ended. Shield has been restored."
        content.sound = .default
        content.categoryIdentifier = AppConstants.shieldRestoreNotificationCategory
        content.userInfo = [
            "type": "shieldRestore",
            "appName": appName,
            "sessionID": UUID().uuidString
        ]
        
        // Deep link to dashboard
        content.userInfo["deepLink"] = "spendless://dashboard"
        
        // Schedule for 10 minutes from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: AppConstants.shieldRestoreNotificationID,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }
    
    /// Cancel the restoration notification
    func cancelRestoreNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [AppConstants.shieldRestoreNotificationID]
        )
    }
    
    // MARK: - Waiting List Notifications
    
    /// Schedule Day 3 and Day 6 notifications for a waiting list item
    /// - Parameter itemID: The UUID of the waiting list item
    /// - Parameter itemName: The name of the item
    /// - Parameter addedAt: When the item was added to the waiting list
    func scheduleWaitingListNotifications(itemID: UUID, itemName: String, addedAt: Date) {
        // Check if notifications are enabled
        guard isWaitingListRemindersEnabled else {
            return
        }
        
        let calendar = Calendar.current
        
        // Day 3 notification (interactive with background actions)
        if let day3Date = calendar.date(byAdding: .day, value: 3, to: addedAt) {
            scheduleDay3Notification(itemID: itemID, itemName: itemName, triggerDate: day3Date)
        }
        
        // Day 6 notification (informational, expires tomorrow)
        if let day6Date = calendar.date(byAdding: .day, value: 6, to: addedAt) {
            scheduleDay6Notification(itemID: itemID, itemName: itemName, triggerDate: day6Date)
        }
    }
    
    /// Schedule Day 3 check-in notification with interactive actions
    private func scheduleDay3Notification(itemID: UUID, itemName: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Still want \(itemName)?"
        content.body = "You added this 3 days ago. Keep it on your list or bury it?"
        content.sound = .default
        content.categoryIdentifier = AppConstants.waitingListCheckinNotificationCategory
        content.userInfo = [
            "type": "waitingListCheckin",
            "itemID": itemID.uuidString,
            "itemName": itemName,
            "day": 3
        ]
        
        // Create trigger for the specific date
        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = "\(AppConstants.waitingListNotificationPrefix)-day3-\(itemID.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }

    /// Schedule Day 6 informational notification
    private func scheduleDay6Notification(itemID: UUID, itemName: String, triggerDate: Date) {
        let content = UNMutableNotificationContent()
        content.title = "\(itemName) expires tomorrow"
        content.body = "This item will be buried tomorrow if you don't decide. Tap to view."
        content.sound = .default
        content.userInfo = [
            "type": "waitingListReminder",
            "itemID": itemID.uuidString,
            "itemName": itemName,
            "day": 6,
            "deepLink": "spendless://waitinglist/\(itemID.uuidString)"
        ]
        
        // Create trigger for the specific date
        let triggerComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute],
            from: triggerDate
        )
        let trigger = UNCalendarNotificationTrigger(dateMatching: triggerComponents, repeats: false)
        
        let identifier = "\(AppConstants.waitingListNotificationPrefix)-day6-\(itemID.uuidString)"
        let request = UNNotificationRequest(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request)
    }

    /// Cancel all notifications for a waiting list item (when buried or bought)
    func cancelWaitingListNotifications(for itemID: UUID) {
        let day3ID = "\(AppConstants.waitingListNotificationPrefix)-day3-\(itemID.uuidString)"
        let day6ID = "\(AppConstants.waitingListNotificationPrefix)-day6-\(itemID.uuidString)"

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [day3ID, day6ID]
        )
    }

    /// Cancel just the Day 6 notification (when user takes action on Day 3)
    func cancelDay6Notification(for itemID: UUID) {
        let day6ID = "\(AppConstants.waitingListNotificationPrefix)-day6-\(itemID.uuidString)"

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [day6ID]
        )
    }
    
    // MARK: - Pending Actions Storage
    
    /// Store a pending waiting list action to be processed on next app launch
    /// - Parameter itemID: The item ID
    /// - Parameter action: Either "keepOnList" or "buryIt"
    func storePendingWaitingListAction(itemID: String, action: String) {
        let key = "\(AppConstants.PendingWaitingListActionKeys.prefix)-\(itemID)"
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(action, forKey: key)
        sharedDefaults?.synchronize()
    }
    
    /// Get and clear a pending waiting list action
    /// - Parameter itemID: The item ID
    /// - Returns: The pending action if any ("keepOnList" or "buryIt")
    func getPendingWaitingListAction(for itemID: String) -> String? {
        let key = "\(AppConstants.PendingWaitingListActionKeys.prefix)-\(itemID)"
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        
        guard let action = sharedDefaults?.string(forKey: key) else {
            return nil
        }
        
        // Clear the action after retrieving
        sharedDefaults?.removeObject(forKey: key)
        sharedDefaults?.synchronize()
        
        return action
    }
    
    /// Get all pending waiting list actions
    /// - Returns: Dictionary of itemID -> action
    func getAllPendingWaitingListActions() -> [String: String] {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let dict = sharedDefaults?.dictionaryRepresentation() else {
            return [:]
        }
        
        var pendingActions: [String: String] = [:]
        let prefix = AppConstants.PendingWaitingListActionKeys.prefix
        
        for (key, value) in dict {
            if key.hasPrefix(prefix), let action = value as? String {
                // Extract item ID from key (format: pendingWaitingListAction-{itemID})
                let itemID = String(key.dropFirst(prefix.count + 1)) // +1 for the "-"
                pendingActions[itemID] = action
            }
        }
        
        return pendingActions
    }
    
    /// Clear a specific pending action
    func clearPendingWaitingListAction(for itemID: String) {
        let key = "\(AppConstants.PendingWaitingListActionKeys.prefix)-\(itemID)"
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.removeObject(forKey: key)
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Handle Notification
    
    /// Handle notification tap (returns deep link if applicable)
    func handleNotification(userInfo: [AnyHashable: Any]) -> String? {
        guard let type = userInfo["type"] as? String else {
            return nil
        }
        
        switch type {
        case "shieldRestore":
            return userInfo["deepLink"] as? String
            
        case "waitingListReminder", "waitingListCheckin":
            // Return deep link to specific waiting list item
            if let deepLink = userInfo["deepLink"] as? String {
                return deepLink
            }
            // Construct deep link if not provided
            if let itemID = userInfo["itemID"] as? String {
                return "spendless://waitinglist/\(itemID)"
            }
            return "spendless://waitinglist"
            
        default:
            return nil
        }
    }
}

// MARK: - UNUserNotificationCenterDelegate

extension NotificationManager: UNUserNotificationCenterDelegate {
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        let actionIdentifier = response.actionIdentifier
        
        // Handle waiting list notification actions
        if let type = userInfo["type"] as? String,
           (type == "waitingListCheckin" || type == "waitingListReminder"),
           let itemID = userInfo["itemID"] as? String {
            
            switch actionIdentifier {
            case AppConstants.WaitingListNotificationActions.keepOnList:
                // Store pending action for processing on app launch
                storePendingWaitingListAction(itemID: itemID, action: "keepOnList")
                // Cancel Day 6 notification since user responded
                if let uuid = UUID(uuidString: itemID) {
                    cancelDay6Notification(for: uuid)
                }

            case AppConstants.WaitingListNotificationActions.buryIt:
                // Store pending action for processing on app launch
                storePendingWaitingListAction(itemID: itemID, action: "buryIt")
                // Cancel Day 6 notification since item will be buried
                if let uuid = UUID(uuidString: itemID) {
                    cancelDay6Notification(for: uuid)
                }

            case UNNotificationDefaultActionIdentifier:
                // User tapped the notification itself - store deep link for navigation
                let deepLink = "spendless://waitinglist/\(itemID)"
                let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
                sharedDefaults?.set(deepLink, forKey: "pendingNotificationDeepLink")
                sharedDefaults?.synchronize()

            default:
                break
            }
            
            completionHandler()
            return
        }
        
        // Handle shield restore notifications (existing code)
        if let deepLink = userInfo["deepLink"] as? String {
            // Store deep link for app to process when it becomes active
            let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
            sharedDefaults?.set(deepLink, forKey: "pendingNotificationDeepLink")
            sharedDefaults?.synchronize()
        }
        
        // Mark notification as tapped in App Group for session manager to process
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "notificationTapped")
        sharedDefaults?.synchronize()
        
        if actionIdentifier == "RESTORE_ACTION" {
            // User tapped "Restore Shield" action
            // Deep link will be processed when app becomes active
        }
        
        completionHandler()
    }
    
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound, .badge])
    }
}
