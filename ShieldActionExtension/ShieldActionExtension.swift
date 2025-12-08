//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Extension that handles user actions on the shield screen
//

import ManagedSettings
import ManagedSettingsUI
import Foundation
import DeviceActivity
import UserNotifications

// MARK: - Shield User Action (local enum for extension)

enum ShieldUserAction: String, Codable {
    case primaryButton = "primaryButton"
    case secondaryButton = "secondaryButton"
    case dismissed = "dismissed"
}

/// Extension that handles user actions on the shield screen
nonisolated class ShieldActionExtension: ShieldActionDelegate {
    
    // App group for shared data
    let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
    
    // Settings store for managing shields
    let store = ManagedSettingsStore()
    
    // DeviceActivityCenter for scheduling
    let deviceActivityCenter = DeviceActivityCenter()
    
    // MARK: - Shield Actions
    
    /// Handle primary button tap (e.g., "Access for 10 min")
    nonisolated override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // User wants temporary access - grant 10 minutes
            handleTemporaryAccess(for: application, completionHandler: completionHandler)
            
        case .secondaryButtonPressed:
            // User chose to stay protected
            handleStayProtected(completionHandler: completionHandler)
            
        @unknown default:
            completionHandler(.close)
        }
    }
    
    /// Handle actions for application categories
    nonisolated override func handle(
        action: ShieldAction,
        for category: ActivityCategoryToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        // Same handling as individual apps
        switch action {
        case .primaryButtonPressed:
            handleTemporaryAccess(for: category, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleStayProtected(completionHandler: completionHandler)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    /// Handle actions for web domains
    nonisolated override func handle(
        action: ShieldAction,
        for webDomain: WebDomainToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            handleTemporaryAccess(for: webDomain, completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleStayProtected(completionHandler: completionHandler)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Action Handlers
    
    /// Handle temporary access request (10 minutes)
    private func handleTemporaryAccess(
        for token: Any,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        // Complete shield interaction event
        completeShieldInteraction(action: .primaryButton)
        
        // Get app name from partial event or use default
        let appName = getAppNameFromPartialEvent() ?? "Blocked App"
        
        // Create temporary access session
        let startTime = Date()
        let endTime = startTime.addingTimeInterval(TimeInterval(10 * 60)) // 10 minutes
        
        // Save session to App Group (as JSON since we can't import main app models)
        saveSession(
            id: UUID().uuidString,
            startTimestamp: startTime,
            scheduledEndTimestamp: endTime,
            triggeringAppName: appName
        )
        
        // Remove shield to allow access
        store.shield.applications = nil
        store.shield.applicationCategories = nil
        store.shield.webDomains = nil
        
        // Schedule DeviceActivityMonitor for restoration
        scheduleRestoration(endTime: endTime)
        
        // Schedule notification for restoration
        scheduleRestoreNotification(appName: appName)
        
        // Request Live Activity start (main app will handle this)
        requestLiveActivityStart(appName: appName, startTime: startTime, endTime: endTime)
        
        // Mark bypass occurred for analytics
        markBypassOccurred()
        
        // Close shield to allow access
        completionHandler(.close)
    }
    
    /// Handle "Stay Protected" action
    private func handleStayProtected(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Complete shield interaction event
        completeShieldInteraction(action: .secondaryButton)
        
        // Log intercept
        logIntercept(outcome: "stayProtected")
        
        // Close shield (keep blocking)
        completionHandler(.close)
    }
    
    // MARK: - Helpers
    
    private func completeShieldInteraction(action: ShieldUserAction) {
        // Load partial event from App Group
        guard let jsonString = sharedDefaults?.string(forKey: "partialShieldEvent"),
              let jsonData = jsonString.data(using: .utf8),
              let eventDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            print("[ShieldAction] No partial event found")
            return
        }
        
        // Create completed event data
        var completedEvent = eventDict
        completedEvent["userAction"] = action.rawValue
        completedEvent["actionTimestamp"] = ISO8601DateFormatter().string(from: Date())
        
        if let timestampString = eventDict["timestamp"] as? String,
           let timestamp = ISO8601DateFormatter().date(from: timestampString) {
            let duration = Date().timeIntervalSince(timestamp)
            completedEvent["interactionDuration"] = duration
        }
        
        // Save completed event (main app will process it)
        if let completedData = try? JSONSerialization.data(withJSONObject: completedEvent),
           let completedString = String(data: completedData, encoding: .utf8) {
            var events = sharedDefaults?.array(forKey: "shieldInteractionEvents") as? [String] ?? []
            events.append(completedString)
            sharedDefaults?.set(events, forKey: "shieldInteractionEvents")
            sharedDefaults?.synchronize()
        }
        
        // Clear partial event
        sharedDefaults?.removeObject(forKey: "partialShieldEvent")
        sharedDefaults?.synchronize()
    }
    
    private func getAppNameFromPartialEvent() -> String? {
        guard let jsonString = sharedDefaults?.string(forKey: "partialShieldEvent"),
              let jsonData = jsonString.data(using: .utf8),
              let eventDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any] else {
            return nil
        }
        return eventDict["appName"] as? String
    }
    
    private func saveSession(
        id: String,
        startTimestamp: Date,
        scheduledEndTimestamp: Date,
        triggeringAppName: String
    ) {
        // Create session dictionary (can't import main app models in extension)
        let sessionDict: [String: Any] = [
            "id": id,
            "startTimestamp": ISO8601DateFormatter().string(from: startTimestamp),
            "scheduledEndTimestamp": ISO8601DateFormatter().string(from: scheduledEndTimestamp),
            "triggeringAppName": triggeringAppName,
            "notificationDelivered": false,
            "notificationTapped": false,
            "userRestoredManually": false,
            "restoredViaDeviceActivity": false,
            "itemsLoggedDuringSession": 0,
            "itemsLoggedAfterSession": 0
        ]
        
        guard let data = try? JSONSerialization.data(withJSONObject: sessionDict),
              let jsonString = String(data: data, encoding: .utf8) else {
            print("[ShieldAction] Failed to encode session")
            return
        }
        
        sharedDefaults?.set(jsonString, forKey: "currentAccessSession")
        sharedDefaults?.synchronize()
    }
    
    private func scheduleRestoration(endTime: Date) {
        // Create a schedule that ends at the specified time
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: endTime)
        
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: components,
            repeats: false
        )
        
        let activityName = DeviceActivityName("temporaryAccess")
        
        do {
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            print("[ShieldAction] Scheduled DeviceActivityMonitor restoration for \(endTime)")
        } catch {
            print("[ShieldAction] Failed to schedule DeviceActivityMonitor: \(error)")
        }
    }
    
    private func scheduleRestoreNotification(appName: String) {
        let content = UNMutableNotificationContent()
        content.title = "Shield Restoration"
        content.body = "Your 10-minute access to \(appName) has ended. Shield will be restored."
        content.sound = .default
        content.categoryIdentifier = "SHIELD_RESTORE"
        content.userInfo = [
            "type": "shieldRestore",
            "appName": appName,
            "deepLink": "spendless://dashboard"
        ]
        
        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: TimeInterval(10 * 60), // 10 minutes
            repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: "shieldRestore",
            content: content,
            trigger: trigger
        )
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("[ShieldAction] Failed to schedule notification: \(error)")
            } else {
                print("[ShieldAction] Scheduled restoration notification")
            }
        }
    }
    
    private func requestLiveActivityStart(appName: String, startTime: Date, endTime: Date) {
        // Store session data for main app to start Live Activity
        let activityData: [String: Any] = [
            "appName": appName,
            "startTime": ISO8601DateFormatter().string(from: startTime),
            "endTime": ISO8601DateFormatter().string(from: endTime)
        ]
        
        if let data = try? JSONSerialization.data(withJSONObject: activityData),
           let jsonString = String(data: data, encoding: .utf8) {
            sharedDefaults?.set(jsonString, forKey: "pendingLiveActivityStart")
            sharedDefaults?.synchronize()
        }
    }
    
    private func markBypassOccurred() {
        sharedDefaults?.set(Date(), forKey: "lastBypassTimestamp")
        sharedDefaults?.synchronize()
    }
    
    private func logIntercept(outcome: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        
        // Store intercept for later syncing with main app
        var intercepts = sharedDefaults?.array(forKey: "pendingIntercepts") as? [[String: String]] ?? []
        intercepts.append([
            "timestamp": timestamp,
            "outcome": outcome
        ])
        sharedDefaults?.set(intercepts, forKey: "pendingIntercepts")
        sharedDefaults?.synchronize()
        
        print("[ShieldAction] Intercept logged: \(outcome)")
    }
}
