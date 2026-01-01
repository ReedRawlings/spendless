//
//  DeviceActivityMonitorExtension.swift
//  DeviceActivityMonitorExtension
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target
//  2. Select "Device Activity Monitor Extension"
//  3. Name it "DeviceActivityMonitorExtension"
//  4. Add the FamilyControls entitlement to this target
//  5. Add App Groups capability with identifier: group.com.spendless.data
//  6. Copy this code into the generated extension file
//
//  NOTE: This is a template file. The actual extension must be created
//  through Xcode and requires the com.apple.developer.family-controls entitlement.
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

        // Only handle temporaryAccess - this is when the 10-minute window starts
        // Shields are already removed at this point by ShieldActionExtension
        if activity.rawValue == "temporaryAccess" {
            logEvent("Temporary access started")
        }
    }

    /// Called when a monitored schedule interval ends
    nonisolated override func intervalDidEnd(for activity: DeviceActivityName) {
        super.intervalDidEnd(for: activity)

        // Only handle temporaryAccess - restore shields when 10-minute window ends
        if activity.rawValue == "temporaryAccess" {
            applyShieldsFromSavedSelection()
            logEvent("Temporary access ended, shields restored")
        }
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
    /// Temporary access activity (10-minute window)
    static let temporaryAccess = DeviceActivityName("temporaryAccess")
}

// MARK: - Event Names

extension DeviceActivityEvent.Name {
    /// Event for when a blocked app is opened
    static let blockedAppOpened = DeviceActivityEvent.Name("blockedAppOpened")
}

