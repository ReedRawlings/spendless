//
//  AnalyticsManager.swift
//  SpendLess
//
//  Processes and aggregates shield interaction analytics data
//

import Foundation

final class AnalyticsManager {
    
    // MARK: - Singleton
    
    static let shared = AnalyticsManager()
    
    // MARK: - Dependencies
    
    private let analytics = ShieldAnalytics.shared
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Aggregate Metrics
    
    /// Get total number of shield appearances
    func getTotalAppearances() -> Int {
        return analytics.getAllEvents().count
    }
    
    /// Get total number of bypasses (primary button presses)
    func getTotalBypasses() -> Int {
        return analytics.getAllEvents().filter { $0.userAction == .primaryButton }.count
    }
    
    /// Get total number of "Stay Protected" actions (secondary button presses)
    func getTotalStayProtected() -> Int {
        return analytics.getAllEvents().filter { $0.userAction == .secondaryButton }.count
    }
    
    /// Get bypass rate (bypasses / total appearances)
    func getBypassRate() -> Double {
        let total = getTotalAppearances()
        guard total > 0 else { return 0 }
        return Double(getTotalBypasses()) / Double(total)
    }
    
    // MARK: - Pattern Detection
    
    /// Get most common time of day for shield appearances
    func getMostCommonTimeOfDay() -> String? {
        let events = analytics.getAllEvents()
        guard !events.isEmpty else { return nil }
        
        let timeOfDayCounts = Dictionary(grouping: events, by: { $0.timeOfDay })
            .mapValues { $0.count }
        
        return timeOfDayCounts.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get most common day of week for shield appearances
    func getMostCommonDayOfWeek() -> String? {
        let events = analytics.getAllEvents()
        guard !events.isEmpty else { return nil }
        
        let dayOfWeekCounts = Dictionary(grouping: events, by: { $0.dayOfWeek })
            .mapValues { $0.count }
        
        return dayOfWeekCounts.max(by: { $0.value < $1.value })?.key
    }
    
    /// Get most frequently blocked app
    func getMostFrequentlyBlockedApp() -> String? {
        let events = analytics.getAllEvents()
        guard !events.isEmpty else { return nil }
        
        let appCounts = Dictionary(grouping: events, by: { $0.appName })
            .mapValues { $0.count }
        
        return appCounts.max(by: { $0.value < $1.value })?.key
    }
    
    // MARK: - Session Analytics
    
    /// Get total number of temporary access sessions
    func getTotalSessions() -> Int {
        return analytics.getAllSessions().count
    }
    
    /// Get average session duration
    func getAverageSessionDuration() -> TimeInterval {
        let sessions = analytics.getAllSessions()
        guard !sessions.isEmpty else { return 0 }
        
        let durations = sessions.compactMap { session -> TimeInterval? in
            guard let endTime = session.actualEndTimestamp else { return nil }
            return endTime.timeIntervalSince(session.startTimestamp)
        }
        
        guard !durations.isEmpty else { return 0 }
        return durations.reduce(0, +) / Double(durations.count)
    }
    
    /// Get restoration method statistics
    func getRestorationStats() -> (deviceActivity: Int, notification: Int, failsafe: Int, manual: Int) {
        let sessions = analytics.getAllSessions()
        
        var deviceActivity = 0
        var notification = 0
        var failsafe = 0
        var manual = 0
        
        for session in sessions {
            if session.restoredViaDeviceActivity {
                deviceActivity += 1
            } else if session.notificationTapped {
                notification += 1
            } else if session.userRestoredManually {
                manual += 1
            } else if session.actualEndTimestamp != nil {
                // Session ended but no specific method recorded = failsafe
                failsafe += 1
            }
        }
        
        return (deviceActivity, notification, failsafe, manual)
    }
    
    // MARK: - Data Export
    
    /// Export all analytics data as JSON
    func exportData() -> Data? {
        let events = analytics.getAllEvents()
        let sessions = analytics.getAllSessions()
        
        let exportData: [String: Any] = [
            "exportDate": ISO8601DateFormatter().string(from: Date()),
            "events": events.map { event in
                [
                    "id": event.id,
                    "timestamp": ISO8601DateFormatter().string(from: event.timestamp),
                    "appName": event.appName,
                    "appBundleID": event.appBundleID as Any,
                    "userAction": event.userAction?.rawValue as Any,
                    "actionTimestamp": event.actionTimestamp.map { ISO8601DateFormatter().string(from: $0) } as Any,
                    "interactionDuration": event.interactionDuration as Any,
                    "currentStreak": event.currentStreak,
                    "daysSinceLastBypass": event.daysSinceLastBypass as Any,
                    "timeOfDay": event.timeOfDay,
                    "dayOfWeek": event.dayOfWeek
                ]
            },
            "sessions": sessions.map { session in
                [
                    "id": session.id,
                    "startTimestamp": ISO8601DateFormatter().string(from: session.startTimestamp),
                    "scheduledEndTimestamp": ISO8601DateFormatter().string(from: session.scheduledEndTimestamp),
                    "actualEndTimestamp": session.actualEndTimestamp.map { ISO8601DateFormatter().string(from: $0) } as Any,
                    "triggeringAppName": session.triggeringAppName,
                    "notificationDelivered": session.notificationDelivered,
                    "notificationTapped": session.notificationTapped,
                    "userRestoredManually": session.userRestoredManually,
                    "restoredViaDeviceActivity": session.restoredViaDeviceActivity
                ]
            }
        ]
        
        return try? JSONSerialization.data(withJSONObject: exportData, options: .prettyPrinted)
    }
}

