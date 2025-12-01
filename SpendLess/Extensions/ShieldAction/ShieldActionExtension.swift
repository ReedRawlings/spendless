//
//  ShieldActionExtension.swift
//  ShieldActionExtension
//
//  SETUP INSTRUCTIONS:
//  1. In Xcode, go to File > New > Target
//  2. Select "Shield Action Extension"
//  3. Name it "ShieldActionExtension"
//  4. Add the FamilyControls entitlement to this target
//  5. Add App Groups capability with identifier: group.com.spendless.data
//  6. Copy this code into the generated extension file
//
//  NOTE: This is a template file. The actual extension must be created
//  through Xcode and requires the com.apple.developer.family-controls entitlement.
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

// MARK: - URL Scheme Note
/*
 To enable deep linking from the shield extension to the main app,
 add the following to the main app's Info.plist:
 
 <key>CFBundleURLTypes</key>
 <array>
     <dict>
         <key>CFBundleURLName</key>
         <string>com.spendless.app</string>
         <key>CFBundleURLSchemes</key>
         <array>
             <string>spendless</string>
         </array>
     </dict>
 </array>
 
 Then handle the URL in the main app's SpendLessApp.swift:
 
 .onOpenURL { url in
     // Handle deep links from shield extension
     if url.host == "addToWaitingList" {
         // Navigate to add waiting list item
     } else if url.host == "breathingExercise" {
         // Show breathing exercise
     }
 }
 */

