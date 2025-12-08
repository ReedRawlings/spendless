//
//  ShieldAnalytics.swift
//  SpendLess
//
//  Shared utility for logging and managing shield interaction analytics
//  Accessible by extensions and main app via App Group
//

import Foundation

/// Singleton utility for shield analytics logging and data management
final class ShieldAnalytics {
    
    // MARK: - Singleton
    
    static let shared = ShieldAnalytics()
    
    // MARK: - App Group
    
    private let appGroupID = "group.com.spendless.data"
    private var sharedDefaults: UserDefaults? {
        return UserDefaults(suiteName: appGroupID)
    }
    
    // MARK: - UserDefaults Keys
    
    private enum Keys {
        static let shieldInteractionEvents = "shieldInteractionEvents"
        static let temporaryAccessSessions = "temporaryAccessSessions"
        static let currentAccessSession = "currentAccessSession"
        static let analyticsEnabled = "analyticsEnabled"
        static let lastBypassTimestamp = "lastBypassTimestamp"
    }
    
    // MARK: - Initialization
    
    private init() {
        // Enable analytics by default if not set
        if sharedDefaults?.object(forKey: Keys.analyticsEnabled) == nil {
            sharedDefaults?.set(true, forKey: Keys.analyticsEnabled)
            sharedDefaults?.synchronize()
        }
    }
    
    // MARK: - Analytics Enabled
    
    var isAnalyticsEnabled: Bool {
        get {
            return sharedDefaults?.bool(forKey: Keys.analyticsEnabled) ?? true
        }
        set {
            sharedDefaults?.set(newValue, forKey: Keys.analyticsEnabled)
            sharedDefaults?.synchronize()
        }
    }
    
    // MARK: - Shield Interaction Events
    
    /// Log a shield appearance (partial event, no user action yet)
    func logShieldAppearance(
        appName: String,
        appBundleID: String? = nil
    ) {
        guard isAnalyticsEnabled else { return }
        
        let currentStreak = getCurrentStreak()
        let daysSinceLastBypass = getDaysSinceLastBypass()
        
        let event = ShieldInteractionEvent.appearance(
            appName: appName,
            appBundleID: appBundleID,
            currentStreak: currentStreak,
            daysSinceLastBypass: daysSinceLastBypass
        )
        
        // Store partial event for completion later
        savePartialEvent(event)
    }
    
    /// Complete a shield interaction event with user action
    func logShieldInteraction(action: ShieldUserAction) {
        guard isAnalyticsEnabled else { return }
        
        guard let partialEvent = loadPartialEvent() else {
            print("[ShieldAnalytics] No partial event found to complete")
            return
        }
        
        let completedEvent = partialEvent.withAction(action, at: Date())
        saveEvent(completedEvent)
        clearPartialEvent()
    }
    
    /// Get all shield interaction events
    func getAllEvents() -> [ShieldInteractionEvent] {
        var allEvents: [ShieldInteractionEvent] = []
        
        // First, try to load as JSON-encoded array (from main app)
        if let data = sharedDefaults?.data(forKey: Keys.shieldInteractionEvents),
           let events = try? JSONDecoder().decode([ShieldInteractionEvent].self, from: data) {
            allEvents = events
        }
        
        // Also process JSON string events from extensions
        if let jsonStrings = sharedDefaults?.array(forKey: "shieldInteractionEvents") as? [String] {
            for jsonString in jsonStrings {
                if let jsonData = jsonString.data(using: .utf8),
                   let eventDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
                   let event = parseEventFromDict(eventDict) {
                    allEvents.append(event)
                }
            }
            
            // After processing, convert to proper format and clear the string array
            if !jsonStrings.isEmpty {
                sharedDefaults?.removeObject(forKey: "shieldInteractionEvents")
                // Save as proper JSON-encoded array
                if let data = try? JSONEncoder().encode(allEvents) {
                    sharedDefaults?.set(data, forKey: Keys.shieldInteractionEvents)
                    sharedDefaults?.synchronize()
                }
            }
        }
        
        return allEvents
    }
    
    /// Parse event from dictionary (for extension JSON strings)
    private func parseEventFromDict(_ dict: [String: Any]) -> ShieldInteractionEvent? {
        guard let id = dict["id"] as? String,
              let timestampString = dict["timestamp"] as? String,
              let timestamp = ISO8601DateFormatter().date(from: timestampString),
              let appName = dict["appName"] as? String,
              let currentStreak = dict["currentStreak"] as? Int else {
            return nil
        }
        
        let appBundleID = dict["appBundleID"] as? String
        let userActionString = dict["userAction"] as? String
        let userAction = userActionString.flatMap { ShieldUserAction(rawValue: $0) }
        let actionTimestampString = dict["actionTimestamp"] as? String
        let actionTimestamp = actionTimestampString.flatMap { ISO8601DateFormatter().date(from: $0) }
        let interactionDuration = dict["interactionDuration"] as? TimeInterval
        let daysSinceLastBypass = dict["daysSinceLastBypass"] as? Int
        let timeOfDay = dict["timeOfDay"] as? String
        let dayOfWeek = dict["dayOfWeek"] as? String
        
        return ShieldInteractionEvent(
            id: id,
            timestamp: timestamp,
            appName: appName,
            appBundleID: appBundleID,
            userAction: userAction,
            actionTimestamp: actionTimestamp,
            interactionDuration: interactionDuration,
            currentStreak: currentStreak,
            daysSinceLastBypass: daysSinceLastBypass,
            timeOfDay: timeOfDay,
            dayOfWeek: dayOfWeek
        )
    }
    
    /// Clear all events
    func clearAllEvents() {
        sharedDefaults?.removeObject(forKey: Keys.shieldInteractionEvents)
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Temporary Access Sessions
    
    /// Save current access session
    func saveCurrentSession(_ session: TemporaryAccessSession) {
        guard let data = try? JSONEncoder().encode(session) else {
            print("[ShieldAnalytics] Failed to encode session")
            return
        }
        
        sharedDefaults?.set(data, forKey: Keys.currentAccessSession)
        sharedDefaults?.synchronize()
        
        // Also add to history
        var sessions = getAllSessions()
        sessions.append(session)
        saveAllSessions(sessions)
    }
    
    /// Get current access session
    func getCurrentSession() -> TemporaryAccessSession? {
        // Try to load as JSON string first (from extensions)
        if let jsonString = sharedDefaults?.string(forKey: Keys.currentAccessSession),
           let jsonData = jsonString.data(using: .utf8),
           let sessionDict = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
           let id = sessionDict["id"] as? String,
           let startTimeString = sessionDict["startTimestamp"] as? String,
           let endTimeString = sessionDict["scheduledEndTimestamp"] as? String,
           let startTime = ISO8601DateFormatter().date(from: startTimeString),
           let endTime = ISO8601DateFormatter().date(from: endTimeString),
           let appName = sessionDict["triggeringAppName"] as? String {
            
            // Convert dictionary to TemporaryAccessSession
            let actualEndTimestamp: Date? = (sessionDict["actualEndTimestamp"] as? String).flatMap { ISO8601DateFormatter().date(from: $0) }
            
            return TemporaryAccessSession(
                id: id,
                startTimestamp: startTime,
                scheduledEndTimestamp: endTime,
                actualEndTimestamp: actualEndTimestamp,
                triggeringAppName: appName,
                notificationDelivered: sessionDict["notificationDelivered"] as? Bool ?? false,
                notificationTapped: sessionDict["notificationTapped"] as? Bool ?? false,
                userRestoredManually: sessionDict["userRestoredManually"] as? Bool ?? false,
                restoredViaDeviceActivity: sessionDict["restoredViaDeviceActivity"] as? Bool ?? false,
                itemsLoggedDuringSession: sessionDict["itemsLoggedDuringSession"] as? Int ?? 0,
                itemsLoggedAfterSession: sessionDict["itemsLoggedAfterSession"] as? Int ?? 0
            )
        }
        
        // Fallback: try to load as data (from main app)
        if let data = sharedDefaults?.data(forKey: Keys.currentAccessSession),
           let session = try? JSONDecoder().decode(TemporaryAccessSession.self, from: data) {
            return session
        }
        
        return nil
    }
    
    /// Update current session
    func updateCurrentSession(_ session: TemporaryAccessSession) {
        saveCurrentSession(session)
    }
    
    /// Clear current session
    func clearCurrentSession() {
        sharedDefaults?.removeObject(forKey: Keys.currentAccessSession)
        sharedDefaults?.synchronize()
    }
    
    /// Get all sessions
    func getAllSessions() -> [TemporaryAccessSession] {
        guard let data = sharedDefaults?.data(forKey: Keys.temporaryAccessSessions),
              let json = try? JSONDecoder().decode([TemporaryAccessSession].self, from: data) else {
            return []
        }
        return json
    }
    
    /// Clear all sessions
    func clearAllSessions() {
        sharedDefaults?.removeObject(forKey: Keys.temporaryAccessSessions)
        sharedDefaults?.removeObject(forKey: Keys.currentAccessSession)
        sharedDefaults?.synchronize()
    }
    
    // MARK: - Private Helpers
    
    private func saveEvent(_ event: ShieldInteractionEvent) {
        var events = getAllEvents()
        events.append(event)
        
        // Cleanup old events (90-day retention)
        let cutoffDate = Date().addingTimeInterval(-90 * 24 * 60 * 60)
        events = events.filter { $0.timestamp >= cutoffDate }
        
        guard let data = try? JSONEncoder().encode(events) else {
            print("[ShieldAnalytics] Failed to encode events")
            return
        }
        
        sharedDefaults?.set(data, forKey: Keys.shieldInteractionEvents)
        sharedDefaults?.synchronize()
    }
    
    private func savePartialEvent(_ event: ShieldInteractionEvent) {
        guard let data = try? JSONEncoder().encode(event) else {
            print("[ShieldAnalytics] Failed to encode partial event")
            return
        }
        
        sharedDefaults?.set(data, forKey: "partialShieldEvent")
        sharedDefaults?.synchronize()
    }
    
    private func loadPartialEvent() -> ShieldInteractionEvent? {
        guard let data = sharedDefaults?.data(forKey: "partialShieldEvent"),
              let event = try? JSONDecoder().decode(ShieldInteractionEvent.self, from: data) else {
            return nil
        }
        return event
    }
    
    private func clearPartialEvent() {
        sharedDefaults?.removeObject(forKey: "partialShieldEvent")
        sharedDefaults?.synchronize()
    }
    
    private func saveAllSessions(_ sessions: [TemporaryAccessSession]) {
        // Cleanup old sessions (90-day retention)
        let cutoffDate = Date().addingTimeInterval(-90 * 24 * 60 * 60)
        let filteredSessions = sessions.filter { $0.startTimestamp >= cutoffDate }
        
        guard let data = try? JSONEncoder().encode(filteredSessions) else {
            print("[ShieldAnalytics] Failed to encode sessions")
            return
        }
        
        sharedDefaults?.set(data, forKey: Keys.temporaryAccessSessions)
        sharedDefaults?.synchronize()
    }
    
    private func getCurrentStreak() -> Int {
        return sharedDefaults?.integer(forKey: "currentStreak") ?? 0
    }
    
    private func getDaysSinceLastBypass() -> Int? {
        guard let timestamp = sharedDefaults?.object(forKey: Keys.lastBypassTimestamp) as? Date else {
            return nil
        }
        
        let days = Calendar.current.dateComponents([.day], from: timestamp, to: Date()).day
        return days
    }
    
    /// Mark that a bypass occurred (for tracking days since last bypass)
    func markBypassOccurred() {
        sharedDefaults?.set(Date(), forKey: Keys.lastBypassTimestamp)
        sharedDefaults?.synchronize()
    }
}

