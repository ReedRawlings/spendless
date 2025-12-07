//
//  ProfileAnalysis.swift
//  SpendLess
//
//  Profile analysis models and engine for onboarding insights
//

import Foundation

// MARK: - Profile Analysis Result

struct ProfileAnalysis {
    let strengths: [ProfileStrengthResult]
    let focusAreas: [ProfileFocusAreaResult]
    let prediction: GoalPrediction?
}

// MARK: - Profile Strength

enum ProfileStrength: String, CaseIterable {
    case selfAwareness
    case clearCommitment
    case emotionalIntelligence
    case honesty
    case readinessToChange
    case specificGoal
    case takingAction // fallback
    case selfInvestment // fallback
}

struct ProfileStrengthResult {
    let type: ProfileStrength
    let title: String
    let description: String
}

// MARK: - Profile Focus Area

enum ProfileFocusArea: String, CaseIterable {
    case lateNightVulnerability
    case emotionalSpending
    case boredomLoop
    case socialTriggers
    case multipleTriggers
    case highFrequency
    case buildingPauseHabit // fallback
}

struct ProfileFocusAreaResult {
    let type: ProfileFocusArea
    let title: String
    let description: String
}

// MARK: - Goal Prediction

struct GoalPrediction {
    let daysToGoal: Int
    let resistanceRate: String // "50%"
    let goalName: String
    let goalAmount: Decimal
}

// MARK: - Profile Analysis Engine

struct ProfileAnalysisEngine {
    static func analyzeProfile(appState: AppState) -> ProfileAnalysis {
        let strengths = generateStrengths(appState: appState)
        let focusAreas = generateFocusAreas(appState: appState)
        let prediction = calculatePrediction(appState: appState)
        
        return ProfileAnalysis(
            strengths: strengths,
            focusAreas: focusAreas,
            prediction: prediction
        )
    }
    
    // MARK: - Strengths Generation
    
    private static func generateStrengths(appState: AppState) -> [ProfileStrengthResult] {
        var strengths: [ProfileStrengthResult] = []
        
        // Self-Awareness: triggers.count >= 2
        if appState.onboardingTriggers.count >= 2 {
            strengths.append(ProfileStrengthResult(
                type: .selfAwareness,
                title: "Self-Awareness",
                description: "You identified \(appState.onboardingTriggers.count) triggers. Knowing your patterns is half the battle."
            ))
        }
        
        // Clear Commitment: goalType != .justStop && goalAmount > 0
        if appState.onboardingGoalType != .justStop && appState.onboardingGoalAmount > 0 {
            let goalName = appState.onboardingGoalName.isEmpty ? goalDisplayName(for: appState.onboardingGoalType) : appState.onboardingGoalName
            let formattedAmount = formatCurrency(appState.onboardingGoalAmount)
            strengths.append(ProfileStrengthResult(
                type: .clearCommitment,
                title: "Clear Commitment",
                description: "Your goal (\(goalName), \(formattedAmount)) is specific and real. That clarity matters."
            ))
        }
        
        // Emotional Intelligence: desiredOutcomes contains emotional outcomes
        let emotionalOutcomes: Set<DesiredOutcome> = [.guiltFree, .lessStress, .breakCycle]
        if !appState.onboardingDesiredOutcomes.isDisjoint(with: emotionalOutcomes) {
            strengths.append(ProfileStrengthResult(
                type: .emotionalIntelligence,
                title: "Emotional Intelligence",
                description: "You understand this isn't just about money—it's about how you feel."
            ))
        }
        
        // Honesty: spendRange >= .high ($250-500 or higher)
        let highSpendRanges: Set<SpendRange> = [.high, .veryHigh]
        if highSpendRanges.contains(appState.onboardingSpendRange) {
            strengths.append(ProfileStrengthResult(
                type: .honesty,
                title: "Honesty",
                description: "You were honest about your spending. That takes courage, and it's the first step."
            ))
        }
        
        // Readiness to Change: desiredOutcomes.count >= 2
        if appState.onboardingDesiredOutcomes.count >= 2 {
            strengths.append(ProfileStrengthResult(
                type: .readinessToChange,
                title: "Readiness to Change",
                description: "You want real change, not a quick fix. That mindset predicts success."
            ))
        }
        
        // Specific Goal: goalType.requiresDetails && !goalName.isEmpty
        if appState.onboardingGoalType.requiresDetails && !appState.onboardingGoalName.isEmpty {
            strengths.append(ProfileStrengthResult(
                type: .specificGoal,
                title: "Specific Vision",
                description: "You didn't just pick a category—you named what you actually want."
            ))
        }
        
        // Select top 3 by priority (order already set above)
        strengths = Array(strengths.prefix(3))
        
        // Ensure at least 2 strengths (add fallbacks if needed)
        if strengths.count < 2 {
            if strengths.count == 0 {
                strengths.append(ProfileStrengthResult(
                    type: .takingAction,
                    title: "Taking Action",
                    description: "You downloaded the app. Most people just think about changing."
                ))
            }
            
            if strengths.count < 2 {
                strengths.append(ProfileStrengthResult(
                    type: .selfInvestment,
                    title: "Self-Investment",
                    description: "You're investing time in yourself. That's not nothing."
                ))
            }
        }
        
        return strengths
    }
    
    // MARK: - Focus Areas Generation
    
    private static func generateFocusAreas(appState: AppState) -> [ProfileFocusAreaResult] {
        var focusAreas: [ProfileFocusAreaResult] = []
        
        // Late Night Vulnerability: timings.contains(.lateNight)
        // Note: PRD mentions .beforeBed but it doesn't exist in enum, so using .lateNight only
        if appState.onboardingTimings.contains(.lateNight) {
            focusAreas.append(ProfileFocusAreaResult(
                type: .lateNightVulnerability,
                title: "Late Night Danger Zone",
                description: "Your patterns suggest evenings are when you're most vulnerable. We'll add extra support after 9pm."
            ))
        }
        
        // Emotional Spending: triggers contain emotional triggers
        let emotionalTriggers: Set<ShoppingTrigger> = [.afterStress, .sad, .lonely]
        if !appState.onboardingTriggers.isDisjoint(with: emotionalTriggers) {
            focusAreas.append(ProfileFocusAreaResult(
                type: .emotionalSpending,
                title: "Emotional Triggers",
                description: "When feelings run high, shopping feels like relief. We'll help you pause in those moments."
            ))
        }
        
        // Boredom Loop: triggers.contains(.bored)
        if appState.onboardingTriggers.contains(.bored) {
            focusAreas.append(ProfileFocusAreaResult(
                type: .boredomLoop,
                title: "The Boredom Loop",
                description: "Boredom shopping is a dopamine shortcut. We'll help redirect that energy."
            ))
        }
        
        // Social Triggers: triggers.contains(.socialMediaAds) or .sales (FOMO)
        if appState.onboardingTriggers.contains(.socialMediaAds) || appState.onboardingTriggers.contains(.sales) {
            focusAreas.append(ProfileFocusAreaResult(
                type: .socialTriggers,
                title: "Social Pressure",
                description: "Algorithms know your weaknesses. We'll help you see through the tricks."
            ))
        }
        
        // Multiple Triggers: triggers.count >= 4
        if appState.onboardingTriggers.count >= 4 {
            focusAreas.append(ProfileFocusAreaResult(
                type: .multipleTriggers,
                title: "Multiple Triggers",
                description: "You have several triggers—that's normal. We'll tackle them one at a time."
            ))
        }
        
        // High Frequency: timings.count >= 3
        if appState.onboardingTimings.count >= 3 {
            focusAreas.append(ProfileFocusAreaResult(
                type: .highFrequency,
                title: "Always-On Temptation",
                description: "Shopping temptation hits you at multiple times. We'll build walls that stay up."
            ))
        }
        
        // Select top 2 by priority (order already set above)
        focusAreas = Array(focusAreas.prefix(2))
        
        // Ensure at least 1 focus area (add fallback if needed)
        if focusAreas.isEmpty {
            focusAreas.append(ProfileFocusAreaResult(
                type: .buildingPauseHabit,
                title: "Building the Pause Habit",
                description: "The hardest part is creating space between impulse and action. That's exactly what we'll practice."
            ))
        }
        
        return focusAreas
    }
    
    // MARK: - Prediction Calculation
    
    private static func calculatePrediction(appState: AppState) -> GoalPrediction? {
        // If goalType is .justStop, show alternate message
        guard appState.onboardingGoalType != .justStop else {
            return nil // Will show alternate message in UI
        }
        
        // If no goal amount, don't show prediction
        guard appState.onboardingGoalAmount > 0 else {
            return nil
        }
        
        let monthlyImpulse = appState.onboardingSpendRange.monthlyEstimate
        let assumedResistRate: Decimal = 0.5 // "If you resist 50% of impulses"
        let monthlySavings = monthlyImpulse * assumedResistRate
        let dailySavings = monthlySavings / 30
        
        guard dailySavings > 0 else {
            return nil
        }
        
        let ratio = (appState.onboardingGoalAmount / dailySavings) as NSDecimalNumber
        let daysToGoal = Int(ceil(ratio.doubleValue))
        
        // Cap at 365 days - if longer, return nil (UI will show alternate message)
        guard daysToGoal <= 365 else {
            return nil
        }
        
        let goalName = appState.onboardingGoalName.isEmpty ? goalDisplayName(for: appState.onboardingGoalType) : appState.onboardingGoalName
        
        return GoalPrediction(
            daysToGoal: daysToGoal,
            resistanceRate: "50%",
            goalName: goalName,
            goalAmount: appState.onboardingGoalAmount
        )
    }
    
    // MARK: - Helper Functions
    
    private static func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
    
    private static func goalDisplayName(for goalType: GoalType) -> String {
        switch goalType {
        case .vacation: return "Your dream trip"
        case .debtFree: return "Freedom from debt"
        case .emergency: return "Peace of mind"
        case .justStop: return "Your wallet"
        case .retirement: return "Your retirement"
        case .downPayment: return "Your down payment"
        case .car: return "Your car"
        case .bigPurchase: return "What you actually need"
        }
    }
}

