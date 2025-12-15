//
//  ScreenTimeManager.swift
//  SpendLess
//
//  Screen Time API implementation
//

import Foundation
import SwiftUI
import FamilyControls
import ManagedSettings
import DeviceActivity

// MARK: - Protocol for Screen Time Management

protocol ScreenTimeManaging {
    var isAuthorized: Bool { get }
    var blockedAppCount: Int { get }
    
    func requestAuthorization() async throws
    func openAppPicker()
    func applyShields()
    func removeShields()
}

// MARK: - Screen Time Manager

@Observable
final class ScreenTimeManager: ScreenTimeManaging {
    
    // MARK: - Singleton
    static let shared = ScreenTimeManager()
    
    // MARK: - State
    private(set) var isAuthorized: Bool = false
    private(set) var blockedAppCount: Int = 0
    private(set) var isPickerPresented: Bool = false
    
    // Real FamilyActivitySelection
    var selection = FamilyActivitySelection()
    
    // DeviceActivityCenter for schedule management
    private let deviceActivityCenter = DeviceActivityCenter()
    
    // MARK: - Initialization
    private init() {
        // Load saved state
        loadState()
    }
    
    // MARK: - Authorization
    
    /// Request Screen Time authorization
    func requestAuthorization() async throws {
        let center = AuthorizationCenter.shared
        try await center.requestAuthorization(for: .individual)
        
        await MainActor.run {
            isAuthorized = true
            saveState()
            AppState.shared.isScreenTimeAuthorized = true
            AppState.shared.saveToUserDefaults()
        }
    }
    
    // MARK: - App Selection
    
    /// Present the app picker
    func openAppPicker() {
        isPickerPresented = true
    }
    
    func closeAppPicker() {
        isPickerPresented = false
    }
    
    /// Handle selection from the picker
    func handleSelection(_ selection: FamilyActivitySelection) {
        print("[ScreenTimeManager] 📱 handleSelection called")
        print("  - Application tokens: \(selection.applicationTokens.count)")
        print("  - Category tokens: \(selection.categoryTokens.count)")
        print("  - Web domain tokens: \(selection.webDomainTokens.count)")

        self.selection = selection
        updateBlockedAppCount()

        print("[ScreenTimeManager] 📊 Updated blockedAppCount: \(blockedAppCount)")

        saveSelection()
        saveState()

        // Apply shields immediately so changes take effect
        applyShields()

        // Force UI update on main thread
        Task { @MainActor in
            // This ensures @Observable updates propagate
            print("[ScreenTimeManager] ✅ Selection processed and saved")
        }
    }
    
    private func updateBlockedAppCount() {
        let count = selection.applicationTokens.count + selection.categoryTokens.count + selection.webDomainTokens.count
        blockedAppCount = count
        AppState.shared.blockedAppCount = count
    }
    
    // MARK: - Shield Management
    
    /// Apply shields to selected apps
    func applyShields() {
        guard isAuthorized else { return }
        
        let store = ManagedSettingsStore()
        store.shield.applications = selection.applicationTokens
        store.shield.applicationCategories = .specific(selection.categoryTokens)
        store.shield.webDomains = selection.webDomainTokens
        
        // Start monitoring schedule
        startMonitoring()
        
        print("[ScreenTimeManager] Shields applied to \(blockedAppCount) apps")
    }
    
    /// Remove all shields
    func removeShields() {
        let store = ManagedSettingsStore()
        store.clearAllSettings()
        
        // Stop monitoring
        stopMonitoring()
        
        print("[ScreenTimeManager] Shields removed")
    }
    
    /// Restore shields from saved selection (for temporary access restoration)
    func restoreShields() {
        guard isAuthorized else {
            print("[ScreenTimeManager] Cannot restore shields: not authorized")
            return
        }
        
        // Reload selection from App Groups to ensure we have the latest
        loadSelection()
        
        // Apply shields
        applyShields()
        
        print("[ScreenTimeManager] Shields restored from saved selection")
    }
    
    // MARK: - DeviceActivity Schedule
    
    private func startMonitoring() {
        // Create a 24/7 schedule
        let schedule = DeviceActivitySchedule(
            intervalStart: DateComponents(hour: 0, minute: 0),
            intervalEnd: DateComponents(hour: 23, minute: 59),
            repeats: true
        )
        
        do {
            let activityName = DeviceActivityName("mainSchedule")
            try deviceActivityCenter.startMonitoring(activityName, during: schedule)
            print("[ScreenTimeManager] Started monitoring schedule")
        } catch {
            print("[ScreenTimeManager] Failed to start monitoring: \(error)")
        }
    }
    
    private func stopMonitoring() {
        let activityName = DeviceActivityName("mainSchedule")
        deviceActivityCenter.stopMonitoring([activityName])
        print("[ScreenTimeManager] Stopped monitoring schedule")
    }
    
    // MARK: - Persistence
    
    private func saveState() {
        let defaults = UserDefaults.standard
        defaults.set(isAuthorized, forKey: "screenTime.isAuthorized")
        defaults.set(blockedAppCount, forKey: "screenTime.blockedAppCount")
    }
    
    private func loadState() {
        let defaults = UserDefaults.standard
        isAuthorized = defaults.bool(forKey: "screenTime.isAuthorized")
        blockedAppCount = defaults.integer(forKey: "screenTime.blockedAppCount")
        
        // Load selection from App Groups
        loadSelection()
    }
    
    /// Save selection to App Groups for extensions
    func saveSelection() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        
        // Use PropertyListEncoder for UserDefaults compatibility
        let encoder = PropertyListEncoder()
        encoder.outputFormat = .binary
        
        do {
            let encoded = try encoder.encode(selection)
            sharedDefaults?.set(encoded, forKey: "blockedApps")
            print("[ScreenTimeManager] ✅ Successfully saved selection: \(blockedAppCount) items")
        } catch {
            print("[ScreenTimeManager] ❌ Failed to encode selection with PropertyListEncoder: \(error)")
            // Fallback: Try JSONEncoder as backup
            do {
                let jsonData = try JSONEncoder().encode(selection)
                sharedDefaults?.set(jsonData, forKey: "blockedApps")
                print("[ScreenTimeManager] ⚠️ Saved using JSONEncoder fallback")
            } catch {
                print("[ScreenTimeManager] ❌ Failed to encode selection with JSONEncoder: \(error)")
            }
        }
    }
    
    /// Load selection from App Groups
    private func loadSelection() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let data = sharedDefaults?.data(forKey: "blockedApps") else {
            print("[ScreenTimeManager] No saved selection found")
            return
        }
        
        // Try PropertyListDecoder first
        let plistDecoder = PropertyListDecoder()
        if let decoded = try? plistDecoder.decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
            updateBlockedAppCount()
            print("[ScreenTimeManager] ✅ Loaded selection: \(blockedAppCount) items")
            return
        }
        
        // Fallback: Try JSONDecoder
        let jsonDecoder = JSONDecoder()
        if let decoded = try? jsonDecoder.decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
            updateBlockedAppCount()
            print("[ScreenTimeManager] ✅ Loaded selection using JSONDecoder: \(blockedAppCount) items")
            return
        }
        
        print("[ScreenTimeManager] ❌ Failed to decode selection from both encoders")
    }
    
    // MARK: - Reset (for testing)
    
    func reset() {
        isAuthorized = false
        blockedAppCount = 0
        selection = FamilyActivitySelection()
        
        removeShields()
        
        let defaults = UserDefaults.standard
        defaults.removeObject(forKey: "screenTime.isAuthorized")
        defaults.removeObject(forKey: "screenTime.blockedAppCount")
        
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.removeObject(forKey: "blockedApps")
        
        AppState.shared.isScreenTimeAuthorized = false
        AppState.shared.blockedAppCount = 0
        AppState.shared.saveToUserDefaults()
    }
}


