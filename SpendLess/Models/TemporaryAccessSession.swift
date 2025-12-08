//
//  TemporaryAccessSession.swift
//  SpendLess
//
//  Model for tracking 10-minute temporary access sessions
//

import Foundation

/// Tracks each 10-minute unlock session
struct TemporaryAccessSession: Codable, Identifiable {
    let id: String
    let startTimestamp: Date
    let scheduledEndTimestamp: Date
    var actualEndTimestamp: Date?
    let triggeringAppName: String
    var notificationDelivered: Bool
    var notificationTapped: Bool
    var userRestoredManually: Bool
    var restoredViaDeviceActivity: Bool
    var itemsLoggedDuringSession: Int
    var itemsLoggedAfterSession: Int
    var minutesUntilRestore: Int?
    
    init(
        id: String = UUID().uuidString,
        startTimestamp: Date = Date(),
        scheduledEndTimestamp: Date,
        actualEndTimestamp: Date? = nil,
        triggeringAppName: String,
        notificationDelivered: Bool = false,
        notificationTapped: Bool = false,
        userRestoredManually: Bool = false,
        restoredViaDeviceActivity: Bool = false,
        itemsLoggedDuringSession: Int = 0,
        itemsLoggedAfterSession: Int = 0,
        minutesUntilRestore: Int? = nil
    ) {
        self.id = id
        self.startTimestamp = startTimestamp
        self.scheduledEndTimestamp = scheduledEndTimestamp
        self.actualEndTimestamp = actualEndTimestamp
        self.triggeringAppName = triggeringAppName
        self.notificationDelivered = notificationDelivered
        self.notificationTapped = notificationTapped
        self.userRestoredManually = userRestoredManually
        self.restoredViaDeviceActivity = restoredViaDeviceActivity
        self.itemsLoggedDuringSession = itemsLoggedDuringSession
        self.itemsLoggedAfterSession = itemsLoggedAfterSession
        self.minutesUntilRestore = minutesUntilRestore
    }
    
    /// Check if session is currently active
    var isActive: Bool {
        guard actualEndTimestamp == nil else { return false }
        return Date() < scheduledEndTimestamp
    }
    
    /// Check if session has expired
    var isExpired: Bool {
        return Date() >= scheduledEndTimestamp && actualEndTimestamp == nil
    }
    
    /// Calculate time remaining in seconds
    var timeRemaining: TimeInterval {
        guard isActive else { return 0 }
        return max(0, scheduledEndTimestamp.timeIntervalSinceNow)
    }
    
    /// Calculate minutes remaining (rounded up)
    var minutesRemaining: Int {
        return Int(ceil(timeRemaining / 60.0))
    }
    
    /// Mark session as ended
    mutating func end(at timestamp: Date = Date()) {
        actualEndTimestamp = timestamp
    }
    
    /// Mark that notification was delivered
    mutating func markNotificationDelivered() {
        notificationDelivered = true
    }
    
    /// Mark that notification was tapped
    mutating func markNotificationTapped() {
        notificationTapped = true
    }
    
    /// Mark that user manually restored shield
    mutating func markRestoredManually() {
        userRestoredManually = true
        end()
    }
    
    /// Mark that DeviceActivityMonitor restored shield
    mutating func markRestoredViaDeviceActivity() {
        restoredViaDeviceActivity = true
        end()
    }
}

