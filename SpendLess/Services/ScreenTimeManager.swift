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
        self.selection = selection
        updateBlockedAppCount()

        saveSelection()
        saveState()

        // Apply shields immediately so changes take effect
        applyShields()
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

        // Note: No schedule needed - ManagedSettingsStore shields persist until explicitly cleared
    }

    /// Remove all shields
    func removeShields() {
        let store = ManagedSettingsStore()
        store.clearAllSettings()
    }

    /// Restore shields from saved selection (for temporary access restoration)
    func restoreShields() {
        guard isAuthorized else { return }

        // Reload selection from App Groups to ensure we have the latest
        loadSelection()

        // Apply shields
        applyShields()
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
        } catch {
            // Fallback: Try JSONEncoder as backup
            if let jsonData = try? JSONEncoder().encode(selection) {
                sharedDefaults?.set(jsonData, forKey: "blockedApps")
            }
        }
    }

    /// Load selection from App Groups
    private func loadSelection() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let data = sharedDefaults?.data(forKey: "blockedApps") else {
            return
        }

        // Try PropertyListDecoder first
        let plistDecoder = PropertyListDecoder()
        if let decoded = try? plistDecoder.decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
            updateBlockedAppCount()
            return
        }

        // Fallback: Try JSONDecoder
        let jsonDecoder = JSONDecoder()
        if let decoded = try? jsonDecoder.decode(FamilyActivitySelection.self, from: data) {
            selection = decoded
            updateBlockedAppCount()
        }
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


