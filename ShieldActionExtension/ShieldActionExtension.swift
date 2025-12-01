//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  Extension that handles user actions on the shield screen
//

import ManagedSettings
import ManagedSettingsUI
import Foundation

/// Extension that handles user actions on the shield screen
nonisolated class ShieldActionExtension: ShieldActionDelegate {
    
    // App group for shared data
    let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
    
    // Settings store for managing shields
    let store = ManagedSettingsStore()
    
    // MARK: - Shield Actions
    
    /// Handle primary button tap (e.g., "Something Specific")
    nonisolated override func handle(
        action: ShieldAction,
        for application: ApplicationToken,
        completionHandler: @escaping (ShieldActionResponse) -> Void
    ) {
        switch action {
        case .primaryButtonPressed:
            // User wants something specific - deep link to add to waiting list
            handleSomethingSpecific(completionHandler: completionHandler)
            
        case .secondaryButtonPressed:
            // User was "just browsing" - handle based on difficulty mode
            handleJustBrowsing(completionHandler: completionHandler)
            
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
            handleSomethingSpecific(completionHandler: completionHandler)
        case .secondaryButtonPressed:
            handleJustBrowsing(completionHandler: completionHandler)
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
            handleSomethingSpecific(completionHandler: completionHandler)
        case .secondaryButtonPressed:
            completionHandler(.close)
        @unknown default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Action Handlers
    
    private func handleSomethingSpecific(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Log the intercept event
        logIntercept(outcome: "somethingSpecific")
        
        // Open main app to add item to waiting list
        // Note: Deep linking requires URL scheme setup in the main app
        if let url = URL(string: "spendless://addToWaitingList") {
            sharedDefaults?.set(url.absoluteString, forKey: "pendingDeepLink")
        }
        
        // Close the shield (don't allow access)
        completionHandler(.close)
    }
    
    private func handleJustBrowsing(completionHandler: @escaping (ShieldActionResponse) -> Void) {
        // Get user's difficulty mode
        let difficultyModeRaw = sharedDefaults?.string(forKey: "difficultyMode") ?? "firm"
        
        switch difficultyModeRaw {
        case "gentle":
            // Gentle mode: Show reminder but can proceed
            // Log a small savings amount ($1)
            addToSavings(1)
            logIntercept(outcome: "justBrowsing_gentle")
            
            // Allow brief access (will re-shield after)
            completionHandler(.defer)
            
        case "firm":
            // Firm mode: Require breathing exercise first
            // Deep link to breathing exercise
            if let url = URL(string: "spendless://breathingExercise") {
                sharedDefaults?.set(url.absoluteString, forKey: "pendingDeepLink")
            }
            logIntercept(outcome: "justBrowsing_firm")
            completionHandler(.close)
            
        case "lockdown":
            // Lockdown mode: No access allowed
            logIntercept(outcome: "justBrowsing_lockdown")
            completionHandler(.close)
            
        default:
            completionHandler(.close)
        }
    }
    
    // MARK: - Helpers
    
    private func addToSavings(_ amount: Double) {
        let currentSaved = sharedDefaults?.double(forKey: "totalSaved") ?? 0
        sharedDefaults?.set(currentSaved + amount, forKey: "totalSaved")
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
        
        print("[ShieldAction] Intercept logged: \(outcome)")
    }
}
