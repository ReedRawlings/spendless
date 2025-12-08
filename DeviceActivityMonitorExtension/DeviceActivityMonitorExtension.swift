//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  Extension that responds to device activity schedule events
//  This runs in a separate process from the main app
//

import DeviceActivity
import ManagedSettings
import Foundation
import FamilyControls

/// Extension that responds to device activity schedule events
/// This runs in a separate process from the main app
nonisolated class DeviceActivityMonitorExtension: DeviceActivityMonitor {
    
    // Shared settings store for applying shields
    let store = ManagedSettingsStore()
    
    // App group for shared data
    let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
    
    // MARK: - Schedule Events
    
    /// Called when a monitored schedule interval begins
    nonisolated override func intervalDidStart(for activity: DeviceActivityName) {
        super.intervalDidStart(for: activity)
        
        // Load saved app selection and apply shields
        applyShieldsFromSavedSelection()
        
        // Log event
        logEvent("Schedule started: \(activity.rawValue)")
    }
    
    /// Called when a monitored schedule interval ends
    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)
        
        // Check if this is the temporary access activity
        if activity.rawValue == "temporaryAccess" {
            // Restore shields for temporary access session end
            restoreShieldsForTemporaryAccess()
        } else {
            // Remove shields when schedule ends (main schedule)
            store.clearAllSettings()
        }
        
        // Log event
        logEvent("Schedule ended: \(activity.rawValue)")
    }
    
    /// Called when device activity changes during a schedule
    nonisolated override func eventDidReachThreshold(_ event: DeviceActivityEvent.Name, activity: DeviceActivityName) {
        super.eventDidReachThreshold(event, activity: activity)
        
        // Handle threshold events (e.g., usage time limits)
        logEvent("Event threshold reached: \(event.rawValue) for \(activity.rawValue)")
    }
    
    /// Called when the user grants or revokes authorization
    nonisolated override func intervalWillStartWarning(for activity: DeviceActivityName) {
        super.intervalWillStartWarning(for: activity)
        
        // Warning before schedule starts
        logEvent("Schedule will start soon: \(activity.rawValue)")
    }
    
    nonisolated override func intervalWillEndWarning(for activity: DeviceActivityName) {
        super.intervalWillEndWarning(for: activity)
        
        // Warning before schedule ends
        logEvent("Schedule will end soon: \(activity.rawValue)")
    }
    
    // MARK: - Shield Management
    
    /// Restore shields when temporary access session ends
    private func restoreShieldsForTemporaryAccess() {
        // Load current session (as JSON string since we can't import main app models)
        guard let sessionJSONString = sharedDefaults?.string(forKey: "currentAccessSession"),
              let sessionData = sessionJSONString.data(using: .utf8),
              var sessionDict = try? JSONSerialization.jsonObject(with: sessionData) as? [String: Any] else {
            logEvent("No current session found for restoration")
            // Still restore shields from saved selection
            applyShieldsFromSavedSelection()
            return
        }
        
        // Update session to mark restoration via DeviceActivity
        sessionDict["restoredViaDeviceActivity"] = true
        sessionDict["actualEndTimestamp"] = ISO8601DateFormatter().string(from: Date())
        
        // Save updated session
        if let updatedData = try? JSONSerialization.data(withJSONObject: sessionDict),
           let updatedString = String(data: updatedData, encoding: .utf8) {
            sharedDefaults?.set(updatedString, forKey: "currentAccessSession")
            sharedDefaults?.synchronize()
        }
        
        // Request Live Activity end (main app will handle this)
        sharedDefaults?.set(true, forKey: "pendingLiveActivityEnd")
        sharedDefaults?.synchronize()
        
        // Restore shields from saved selection
        applyShieldsFromSavedSelection()
        
        logEvent("Shields restored via DeviceActivityMonitor for temporary access session")
    }
    
    private func applyShieldsFromSavedSelection() {
        // Load saved FamilyActivitySelection from App Groups
        guard let data = sharedDefaults?.data(forKey: "blockedApps") else {
            logEvent("No saved selection found")
            return
        }
        
        // Try PropertyListDecoder first
        let plistDecoder = PropertyListDecoder()
        var selection: FamilyActivitySelection?
        
        if let decoded = try? plistDecoder.decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
            logEvent("Loaded selection using PropertyListDecoder")
        } else {
            // Fallback: Try JSONDecoder
            let jsonDecoder = JSONDecoder()
            if let decoded = try? jsonDecoder.decode(FamilyActivitySelection.self, from: data) {
                selection = decoded
                logEvent("Loaded selection using JSONDecoder")
            } else {
                logEvent("Failed to decode selection from both encoders")
                return
            }
        }
        
        guard let selection = selection else {
            logEvent("Selection is nil after decoding")
            return
        }
        
        // Apply shields to selected apps
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        logEvent("Shields applied: \(selection.applicationTokens.count) apps, \(selection.categoryTokens.count) categories, \(selection.webDomainTokens.count) domains")
    }
    
    // MARK: - Logging
    
    private func logEvent(_ message: String) {
        let timestamp = ISO8601DateFormatter().string(from: Date())
        sharedDefaults?.set("\(timestamp): \(message)", forKey: "lastExtensionEvent")
        print("[DeviceActivityMonitor] \(message)")
    }
}

// MARK: - Activity Names

extension DeviceActivityName {
    /// Main activity schedule for app blocking
    static let mainSchedule = DeviceActivityName("mainSchedule")
    
    /// Temporary unlock activity
    static let temporaryUnlock = DeviceActivityName("temporaryUnlock")
}

// MARK: - Event Names

extension DeviceActivityEvent.Name {
    /// Event for when a blocked app is opened
    static let blockedAppOpened = DeviceActivityEvent.Name("blockedAppOpened")
}
