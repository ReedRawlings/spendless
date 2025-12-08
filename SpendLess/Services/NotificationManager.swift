//
//  NotificationManager.swift
//  SpendLess
//
//  Manages local notifications for shield restoration
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
            print("[NotificationManager] Failed to request permission: \(error)")
            return false
        }
    }
    
    /// Check if notification permission is granted
    func checkPermission() async -> Bool {
        let settings = await UNUserNotificationCenter.current().notificationSettings()
        return settings.authorizationStatus == .authorized
    }
    
    // MARK: - Register Categories
    
    private func registerNotificationCategories() {
        let restoreAction = UNNotificationAction(
            identifier: "RESTORE_ACTION",
            title: "Restore Shield",
            options: [.foreground]
        )
        
        let category = UNNotificationCategory(
            identifier: AppConstants.shieldRestoreNotificationCategory,
            actions: [restoreAction],
            intentIdentifiers: [],
            options: []
        )
        
        UNUserNotificationCenter.current().setNotificationCategories([category])
    }
    
    // MARK: - Schedule Notification
    
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
        // TODO: Navigation design needs to be finalized - currently navigates to dashboard
        content.userInfo["deepLink"] = "spendless://dashboard"
        
        // Schedule for 10 minutes from now
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: TimeInterval(minutes * 60), repeats: false)
        
        let request = UNNotificationRequest(
            identifier: AppConstants.shieldRestoreNotificationID,
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[NotificationManager] Failed to schedule notification: \(error)")
            } else {
                print("[NotificationManager] Scheduled restoration notification for \(minutes) minutes")
            }
        }
    }
    
    /// Cancel the restoration notification
    func cancelRestoreNotification() {
        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [AppConstants.shieldRestoreNotificationID]
        )
    }
    
    // MARK: - Handle Notification
    
    /// Handle notification tap
    func handleNotification(userInfo: [AnyHashable: Any]) -> String? {
        guard let type = userInfo["type"] as? String,
              type == "shieldRestore" else {
            return nil
        }
        
        // Return deep link for navigation
        return userInfo["deepLink"] as? String
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
        
        // Get deep link from notification
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
        
        if response.actionIdentifier == "RESTORE_ACTION" {
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

