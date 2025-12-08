//
//  ShieldInteractionEvent.swift
//  SpendLess
//
//  Model for tracking shield interactions and user actions
//

import Foundation

/// Tracks every shield appearance and user action for analytics
struct ShieldInteractionEvent: Codable, Identifiable {
    let id: String
    let timestamp: Date
    let appName: String
    let appBundleID: String?
    let userAction: ShieldUserAction?
    let actionTimestamp: Date?
    let interactionDuration: TimeInterval?
    let currentStreak: Int
    let daysSinceLastBypass: Int?
    let timeOfDay: String
    let dayOfWeek: String
    
    init(
        id: String = UUID().uuidString,
        timestamp: Date = Date(),
        appName: String,
        appBundleID: String? = nil,
        userAction: ShieldUserAction? = nil,
        actionTimestamp: Date? = nil,
        interactionDuration: TimeInterval? = nil,
        currentStreak: Int,
        daysSinceLastBypass: Int? = nil,
        timeOfDay: String? = nil,
        dayOfWeek: String? = nil
    ) {
        self.id = id
        self.timestamp = timestamp
        self.appName = appName
        self.appBundleID = appBundleID
        self.userAction = userAction
        self.actionTimestamp = actionTimestamp
        self.interactionDuration = interactionDuration
        self.currentStreak = currentStreak
        self.daysSinceLastBypass = daysSinceLastBypass
        
        // Calculate timeOfDay and dayOfWeek if not provided
        let calendar = Calendar.current
        let hour = calendar.component(.hour, from: timestamp)
        
        if let timeOfDay = timeOfDay {
            self.timeOfDay = timeOfDay
        } else {
            switch hour {
            case 0..<6: self.timeOfDay = "night"
            case 6..<12: self.timeOfDay = "morning"
            case 12..<18: self.timeOfDay = "afternoon"
            default: self.timeOfDay = "evening"
            }
        }
        
        if let dayOfWeek = dayOfWeek {
            self.dayOfWeek = dayOfWeek
        } else {
            let formatter = DateFormatter()
            formatter.dateFormat = "EEEE"
            self.dayOfWeek = formatter.string(from: timestamp).lowercased()
        }
    }
    
    /// Create a partial event (appearance only, no user action yet)
    static func appearance(
        appName: String,
        appBundleID: String? = nil,
        currentStreak: Int,
        daysSinceLastBypass: Int? = nil
    ) -> ShieldInteractionEvent {
        return ShieldInteractionEvent(
            appName: appName,
            appBundleID: appBundleID,
            currentStreak: currentStreak,
            daysSinceLastBypass: daysSinceLastBypass
        )
    }
    
    /// Complete the event with user action
    func withAction(_ action: ShieldUserAction, at timestamp: Date) -> ShieldInteractionEvent {
        let duration = timestamp.timeIntervalSince(self.timestamp)
        return ShieldInteractionEvent(
            id: self.id,
            timestamp: self.timestamp,
            appName: self.appName,
            appBundleID: self.appBundleID,
            userAction: action,
            actionTimestamp: timestamp,
            interactionDuration: duration,
            currentStreak: self.currentStreak,
            daysSinceLastBypass: self.daysSinceLastBypass,
            timeOfDay: self.timeOfDay,
            dayOfWeek: self.dayOfWeek
        )
    }
}

