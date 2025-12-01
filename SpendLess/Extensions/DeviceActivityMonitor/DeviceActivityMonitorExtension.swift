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
        
        // Remove shields when schedule ends
        store.clearAllSettings()
        
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
    
    private func applyShieldsFromSavedSelection() {
        /*
        // Load saved FamilyActivitySelection from App Groups
        guard let data = sharedDefaults?.data(forKey: "blockedApps"),
              let selection = try? JSONDecoder().decode(FamilyActivitySelection.self, from: data) else {
            return
        }
        
        // Apply shields to selected apps
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        */
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

