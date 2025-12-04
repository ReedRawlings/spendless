//
//  InterventionManager.swift
//  SpendLess
//
//  Manages the intervention flow state when triggered by Shortcuts
//

import SwiftUI
import Combine

@MainActor
@Observable
final class InterventionManager {
    
    // MARK: - Singleton
    
    static let shared = InterventionManager()
    
    // MARK: - State
    
    var isShowingIntervention = false
    var interventionType: InterventionTypeValue = .fullFlow
    var currentStep: InterventionStep = .initial
    var triggeringApp: String? = nil
    
    // MARK: - HALT Result
    
    var haltResult = HALTResult()
    var selectedHALTState: HALTState? = nil
    
    // MARK: - Logged Item Data
    
    var loggedItemName: String = ""
    var loggedItemAmount: Decimal = 0
    
    // MARK: - Celebration Context
    
    var isHALTRedirectCelebration: Bool = false
    
    /// Which step we're on within an intervention
    enum InterventionStep: Equatable {
        case initial          // Starting point, routes based on type
        case breathing        // Breathing exercise
        case haltCheck        // HALT questionnaire
        case haltRedirect     // HALT redirect screen with suggestions
        case goalReminder     // Show goal + commitment
        case quickPause       // Simple countdown
        case reflection       // "What brought you here?"
        case dopamineMenu     // Show dopamine menu when "Just Browsing"
        case logItem          // Add to waiting list
        case celebration      // Success!
        case complete
    }
    
    /// The type of intervention (matches InterventionType enum from Intents)
    enum InterventionTypeValue: String, CaseIterable {
        case breathing = "breathing"
        case haltCheck = "halt"
        case goalReminder = "goal"
        case quickPause = "quick"
        case fullFlow = "full"
        
        var title: String {
            switch self {
            case .breathing: return "Breathing Exercise"
            case .haltCheck: return "HALT Check"
            case .goalReminder: return "Goal Reminder"
            case .quickPause: return "Quick Pause"
            case .fullFlow: return "Full Experience"
            }
        }
    }
    
    private let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Pending Intervention Check
    
    /// Call this when app becomes active to check for pending interventions
    func checkForPendingIntervention() {
        guard let sharedDefaults = sharedDefaults else { return }
        
        let triggered = sharedDefaults.bool(forKey: "interventionTriggered")
        let timestamp = sharedDefaults.double(forKey: "interventionTimestamp")
        
        // Only process if triggered recently (within last 30 seconds)
        let isRecent = Date().timeIntervalSince1970 - timestamp < 30
        
        if triggered && isRecent {
            // Clear the flag
            sharedDefaults.set(false, forKey: "interventionTriggered")
            
            // Get intervention type
            let typeString = sharedDefaults.string(forKey: "interventionType") ?? "full"
            self.interventionType = InterventionTypeValue(rawValue: typeString) ?? .fullFlow
            
            // Reset state
            self.haltResult = HALTResult()
            self.selectedHALTState = nil
            self.loggedItemName = ""
            self.loggedItemAmount = 0
            self.isHALTRedirectCelebration = false
            
            // Set starting step based on type
            self.currentStep = initialStep(for: interventionType)
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                self.isShowingIntervention = true
            }
        }
    }
    
    /// Determines the first step based on intervention type
    private func initialStep(for type: InterventionTypeValue) -> InterventionStep {
        switch type {
        case .breathing:
            return .breathing
        case .haltCheck:
            return .haltCheck
        case .goalReminder:
            return .goalReminder
        case .quickPause:
            return .quickPause
        case .fullFlow:
            return .breathing
        }
    }
    
    // MARK: - Step Transitions
    
    /// Called when breathing exercise completes
    func completeBreathing() {
        switch interventionType {
        case .breathing:
            // Breathing-only flow goes straight to celebration
            handleJustBrowsing()
        case .fullFlow:
            // Full flow continues to reflection
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .reflection
            }
        default:
            completeIntervention()
        }
    }
    
    /// Called when HALT check completes with a selected state
    func completeHALTCheck(selectedState: HALTState?) {
        self.selectedHALTState = selectedState
        
        if selectedState != nil {
            // Show redirect screen for the selected state
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .haltRedirect
            }
        } else {
            // "I'm fine, actually" - skip to regular flow
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .reflection
            }
        }
    }
    
    /// Called when user taps "I'll do that ✓" on redirect screen
    func handleHALTRedirectAccepted() {
        // Log the HALT check result
        let checkResult = HALTCheckResult(
            triggerApp: triggeringApp,
            selectedState: selectedHALTState,
            didRedirect: true
        )
        saveHALTCheckResult(checkResult)
        
        // Add $1 to savings as a small win
        addToSavings(amount: 1.0)
        incrementResistCount()
        
        // Mark as HALT redirect celebration
        isHALTRedirectCelebration = true
        
        // Show brief celebration
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .celebration
        }
    }
    
    /// Called when user taps "I still want to browse" on redirect screen
    func handleHALTRedirectDeclined() {
        // Log the HALT check result (they saw it but proceeded)
        let checkResult = HALTCheckResult(
            triggerApp: triggeringApp,
            selectedState: selectedHALTState,
            didRedirect: false
        )
        saveHALTCheckResult(checkResult)
        
        // Continue to normal intervention flow
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .reflection
        }
    }
    
    /// Called when goal reminder is dismissed
    func completeGoalReminder(resisted: Bool) {
        if resisted {
            incrementResistCount()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .celebration
            }
        } else {
            completeIntervention()
        }
    }
    
    /// Called when quick pause countdown finishes
    func completeQuickPause(resisted: Bool) {
        if resisted {
            incrementResistCount()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .celebration
            }
        } else {
            completeIntervention()
        }
    }
    
    /// Called when user selects "Just Browsing"
    func handleJustBrowsing() {
        // Check if dopamine menu is setup
        if hasDopamineMenuSetup {
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .dopamineMenu
            }
        } else {
            incrementResistCount()
            withAnimation(.easeInOut(duration: 0.3)) {
                currentStep = .celebration
            }
        }
    }
    
    /// Called when user completes dopamine menu (selects an activity or skips)
    func completeDopamineMenu() {
        incrementResistCount()
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .celebration
        }
    }
    
    /// Check if dopamine menu is configured
    var hasDopamineMenuSetup: Bool {
        guard let data = sharedDefaults?.array(forKey: "dopamineMenuSelectedDefaults") as? [String],
              !data.isEmpty else {
            // Also check custom activities
            let custom = sharedDefaults?.stringArray(forKey: "dopamineMenuCustomActivities") ?? []
            return !custom.isEmpty
        }
        return true
    }
    
    /// Called when user wants to log a specific item
    func handleSomethingSpecific() {
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .logItem
        }
    }
    
    /// Called after item is logged to waiting list
    func handleItemLogged(name: String, amount: Decimal) {
        loggedItemName = name
        loggedItemAmount = amount
        // Note: Item is logged to waiting list, but we still celebrate the resistance
        incrementResistCount()
        withAnimation(.easeInOut(duration: 0.3)) {
            currentStep = .celebration
        }
    }
    
    /// Dismiss the intervention flow
    func completeIntervention() {
        withAnimation(.easeOut(duration: 0.3)) {
            isShowingIntervention = false
        }

        // Reset state after animation completes
        Task {
            try? await Task.sleep(for: .milliseconds(350))
            self.currentStep = .initial
            self.haltResult = HALTResult()
            self.selectedHALTState = nil
            self.loggedItemName = ""
            self.loggedItemAmount = 0
            self.triggeringApp = nil
            self.isHALTRedirectCelebration = false
        }
    }
    
    /// Trigger intervention manually (for testing or from Settings)
    func triggerIntervention(type: InterventionTypeValue) {
        self.interventionType = type
        self.haltResult = HALTResult()
        self.selectedHALTState = nil
        self.loggedItemName = ""
        self.loggedItemAmount = 0
        self.isHALTRedirectCelebration = false
        self.currentStep = initialStep(for: type)
        
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            self.isShowingIntervention = true
        }
    }
    
    // MARK: - Private Helpers
    
    private func addToSavings(amount: Decimal) {
        let current = sharedDefaults?.double(forKey: "savedAmount") ?? 0
        sharedDefaults?.set(current + NSDecimalNumber(decimal: amount).doubleValue, forKey: "savedAmount")
    }
    
    private func incrementResistCount() {
        let current = sharedDefaults?.integer(forKey: "resistCount") ?? 0
        sharedDefaults?.set(current + 1, forKey: "resistCount")
    }
    
    // MARK: - Data Access
    
    var resistCount: Int {
        sharedDefaults?.integer(forKey: "resistCount") ?? 0
    }
    
    var savedAmount: Double {
        sharedDefaults?.double(forKey: "savedAmount") ?? 0
    }
    
    var goalName: String {
        sharedDefaults?.string(forKey: "goalName") ?? "Your Goal"
    }
    
    var targetAmount: Double {
        sharedDefaults?.double(forKey: "targetAmount") ?? 1000
    }
    
    var commitment: String {
        sharedDefaults?.string(forKey: "userCommitment") ?? sharedDefaults?.string(forKey: "futureLetterText") ?? "I'm done buying things I don't need"
    }
    
    var progress: Double {
        guard targetAmount > 0 else { return 0 }
        return min(savedAmount / targetAmount, 1.0)
    }
    
    // MARK: - HALT Check Result Persistence
    
    private func saveHALTCheckResult(_ result: HALTCheckResult) {
        // Store in UserDefaults for analytics/insights later
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(result),
           let _ = String(data: data, encoding: .utf8) {
            // Store as array of results (append to existing)
            var results = loadHALTCheckResults()
            results.append(result)
            
            // Keep only last 100 results
            if results.count > 100 {
                results = Array(results.suffix(100))
            }
            
            // Save back
            if let allData = try? encoder.encode(results),
               let allJsonString = String(data: allData, encoding: .utf8) {
                sharedDefaults?.set(allJsonString, forKey: "haltCheckResults")
            }
        }
    }
    
    func loadHALTCheckResults() -> [HALTCheckResult] {
        guard let sharedDefaults = sharedDefaults,
              let jsonString = sharedDefaults.string(forKey: "haltCheckResults"),
              let data = jsonString.data(using: .utf8),
              let results = try? JSONDecoder().decode([HALTCheckResult].self, from: data) else {
            return []
        }
        return results
    }
}

// MARK: - HALT Result (Legacy - kept for compatibility)

struct HALTResult {
    var isHungry: Bool = false
    var isAngry: Bool = false
    var isLonely: Bool = false
    var isTired: Bool = false
    
    var hasAnyTrigger: Bool {
        isHungry || isAngry || isLonely || isTired
    }
    
    var triggers: [String] {
        var result: [String] = []
        if isHungry { result.append("Hungry") }
        if isAngry { result.append("Angry") }
        if isLonely { result.append("Lonely") }
        if isTired { result.append("Tired") }
        return result
    }
    
    var suggestions: [String] {
        var result: [String] = []
        if isHungry { result.append("Grab a snack first") }
        if isAngry { result.append("Take a few deep breaths") }
        if isLonely { result.append("Text a friend instead") }
        if isTired { result.append("Rest before deciding") }
        return result
    }
}

// MARK: - Notification Names

extension Notification.Name {
    static let checkForIntervention = Notification.Name("checkForIntervention")
}

