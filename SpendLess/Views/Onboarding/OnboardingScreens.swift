//
//  OnboardingScreens.swift
//  SpendLess
//
//  Individual onboarding screens
//

import SwiftUI

// MARK: - Screen 1: Welcome

struct OnboardingWelcomeView: View {
    let onContinue: () -> Void
    
    @State private var iconVisible = false
    @State private var headlineVisible = false
    @State private var subtitleVisible = false
    @State private var buttonVisible = false
    @State private var hasAnimated = false
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()
                
                // Illustration
                Image(systemName: "cart.badge.minus")
                    .font(.system(size: 100))
                    .foregroundStyle(Color.spendLessPrimary)
                    .opacity(iconVisible ? 1 : 0)
                    .scaleEffect(iconVisible ? 1 : 0.8)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7), value: iconVisible)
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("Your impulse shopping stops here.")
                        .font(SpendLessFont.title)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                        .opacity(headlineVisible ? 1 : 0)
                        .offset(y: headlineVisible ? 0 : 10)
                        .animation(.easeOut(duration: 0.4), value: headlineVisible)
                    
                    Text("We'll help you pause, resist, and save for what actually matters.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .opacity(subtitleVisible ? 1 : 0)
                        .offset(y: subtitleVisible ? 0 : 10)
                        .animation(.easeOut(duration: 0.4), value: subtitleVisible)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Start fresh", icon: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
                .opacity(buttonVisible ? 1 : 0)
                .scaleEffect(buttonVisible ? 1 : 0.95)
                .animation(.spring(response: 0.4, dampingFraction: 0.8), value: buttonVisible)
            }
        }
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                iconVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                headlineVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                subtitleVisible = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.1) {
                buttonVisible = true
            }
        }
    }
}

// MARK: - Screen 2: Behaviors

struct OnboardingBehaviorsView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .behaviors) {
            VStack(spacing: SpendLessSpacing.md) {
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("Which of these sounds like you?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Select all that apply")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.lg)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.xs) {
                        ForEach(ShoppingTrigger.allCases) { trigger in
                            SelectionCard(
                                title: trigger.rawValue,
                                icon: trigger.icon,
                                isSelected: appState.onboardingTriggers.contains(trigger),
                                padding: SpendLessSpacing.sm
                            ) {
                                toggleTrigger(trigger)
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private func toggleTrigger(_ trigger: ShoppingTrigger) {
        if appState.onboardingTriggers.contains(trigger) {
            appState.onboardingTriggers.remove(trigger)
            HapticFeedback.lightSuccess()  // deselect - lighter
        } else {
            appState.onboardingTriggers.insert(trigger)
            HapticFeedback.mediumSuccess()  // select - more satisfying
        }
    }
}

// MARK: - Screen 3: Timing

struct OnboardingTimingView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .timing) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("When do you usually impulse shop?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Select all that apply")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(ShoppingTiming.allCases) { timing in
                            SelectionCard(
                                title: timing.rawValue,
                                icon: timing.icon,
                                isSelected: appState.onboardingTimings.contains(timing)
                            ) {
                                toggleTiming(timing)
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private func toggleTiming(_ timing: ShoppingTiming) {
        if appState.onboardingTimings.contains(timing) {
            appState.onboardingTimings.remove(timing)
            HapticFeedback.lightSuccess()  // deselect - lighter
        } else {
            appState.onboardingTimings.insert(timing)
            HapticFeedback.mediumSuccess()  // select - more satisfying
        }
    }
}

// MARK: - Screen 4: Problem Apps Education

struct OnboardingProblemAppsView: View {
    let onContinue: () -> Void
    
    private let commonApps = [
        ("🛒", "Amazon"),
        ("👗", "Shein"),
        ("📦", "Temu"),
        ("🎯", "Target"),
        ("🛍️", "TikTok Shop"),
        ("📸", "Instagram Shopping"),
        ("🏠", "Etsy"),
        ("🛒", "Walmart"),
        ("👠", "ASOS"),
        ("💄", "Sephora")
    ]
    
    var body: some View {
        OnboardingContainer(step: .problemApps) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Which apps get you in trouble?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Here are some common ones. You'll select yours in the next step.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, SpendLessSpacing.xl)
                .padding(.horizontal, SpendLessSpacing.md)
                
                // App grid
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Common shopping apps")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .frame(maxWidth: .infinity, alignment: .leading)
                    
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 80))], spacing: SpendLessSpacing.md) {
                        ForEach(commonApps, id: \.1) { icon, name in
                            VStack(spacing: SpendLessSpacing.xs) {
                                IconView(icon, font: .system(size: 36))
                                Text(name)
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                            .frame(width: 80, height: 80)
                            .background(Color.spendLessCardBackground.opacity(0.5))
                            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                Text("💡 Tip: In the next step, you can also block Instagram and TikTok if you shop through them.")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.lg)
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Screen 5: Monthly Spend

struct OnboardingMonthlySpendView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .monthlySpend) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("How much do you spend on impulse purchases each month?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Be honest — no judgment here.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                .padding(.horizontal, SpendLessSpacing.md)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(SpendRange.allCases) { range in
                            SelectionCard(
                                title: range.rawValue,
                                icon: "💸",
                                isSelected: appState.onboardingSpendRange == range
                            ) {
                                appState.onboardingSpendRange = range
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Screen 6: Impact Visualization

struct OnboardingImpactView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    @State private var animatedYearly: Double = 0
    @State private var animatedDecade: Double = 0
    @State private var showQuestion = false
    
    var body: some View {
        OnboardingContainer(step: .impactVisualization) {
            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("If you're spending ~\(formatCurrency(appState.onboardingSpendRange.monthlyEstimate))/month on things you don't need...")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                    
                    VStack(spacing: SpendLessSpacing.lg) {
                        VStack(spacing: SpendLessSpacing.xxs) {
                            Text(formatCurrency(Decimal(animatedYearly)))
                                .font(SpendLessFont.largeTitle)
                                .foregroundStyle(Color.spendLessPrimary)
                            Text("per year")
                                .font(SpendLessFont.subheadline)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        
                        VStack(spacing: SpendLessSpacing.xxs) {
                            Text(formatCurrency(Decimal(animatedDecade)))
                                .font(SpendLessFont.largeTitle)
                                .foregroundStyle(Color.spendLessGold)
                            Text("over 10 years")
                                .font(SpendLessFont.subheadline)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                    }
                    
                    Text("What could YOU do with that?")
                        .font(SpendLessFont.title3)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .padding(.top, SpendLessSpacing.md)
                        .opacity(showQuestion ? 1 : 0)
                        .offset(y: showQuestion ? 0 : 10)
                        .animation(.easeOut(duration: 0.4), value: showQuestion)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Let's change that") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .onAppear {
            animateNumbers()
        }
    }
    
    private func animateNumbers() {
        let yearly = (appState.onboardingSpendRange.yearlyEstimate as NSDecimalNumber).doubleValue
        let decade = (appState.onboardingSpendRange.decadeEstimate as NSDecimalNumber).doubleValue
        
        // Animate over 1.5 seconds
        let steps = 30
        let yearlyIncrement = yearly / Double(steps)
        let decadeIncrement = decade / Double(steps)
        
        for step in 1...steps {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(step) * 0.05) {
                withAnimation(.easeOut(duration: 0.05)) {
                    animatedYearly = min(yearlyIncrement * Double(step), yearly)
                    animatedDecade = min(decadeIncrement * Double(step), decade)
                }
            }
        }
        
        // Show question and trigger haptic after animation completes
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.6) {
            showQuestion = true
            HapticFeedback.mediumSuccess()
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Screen 7: Goal Selection

struct OnboardingGoalSelectionView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .goalSelection) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("What would you rather have?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Pick something to work toward")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(GoalType.allCases) { goalType in
                            SelectionCard(
                                title: goalType.rawValue,
                                icon: goalType.icon,
                                isSelected: appState.onboardingGoalType == goalType
                            ) {
                                appState.onboardingGoalType = goalType
                                let generator = UIImpactFeedbackGenerator(style: .light)
                                generator.impactOccurred()
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Meaning Chip Component

struct MeaningChip: View {
    let icon: String
    let text: String
    let isVisible: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: {
            let generator = UIImpactFeedbackGenerator(style: .light)
            generator.impactOccurred()
            action()
        }) {
            HStack(spacing: SpendLessSpacing.sm) {
                Text(icon)
                    .font(.title3)
                
                Text(text)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(Color.spendLessPrimary.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
        .opacity(isVisible ? 1 : 0)
        .offset(y: isVisible ? 0 : 10)
    }
}

// MARK: - Goal-Specific Content Helper

struct GoalSpecificContent {
    let introText: String
    let meaningPhrases: [(icon: String, text: String)]
    let amountLabel: String
    let placeholder: String
    
    static func content(for goalType: GoalType, goalName: String = "") -> GoalSpecificContent {
        switch goalType {
        case .emergency:
            return GoalSpecificContent(
                introText: "An emergency fund means...",
                meaningPhrases: [
                    ("🛡️", "A real safety net"),
                    ("😮‍💨", "Breathing room when life happens"),
                    ("😴", "Sleeping without money anxiety")
                ],
                amountLabel: "How much will make you feel secure?",
                placeholder: "e.g., \"Never panicking about bills\""
            )
        case .vacation:
            return GoalSpecificContent(
                introText: goalName.isEmpty ? "A dream vacation means..." : "A trip to \(goalName) means...",
                meaningPhrases: [
                    ("✨", "Experiences over things"),
                    ("📸", "Memories you'll actually keep"),
                    ("🎯", "Finally doing that thing you keep saying you'll do")
                ],
                amountLabel: "What's your trip budget?",
                placeholder: "e.g., \"Making memories that last\""
            )
        case .debtFree:
            return GoalSpecificContent(
                introText: "Being debt free means...",
                meaningPhrases: [
                    ("💵", "Your paycheck is actually yours"),
                    ("😌", "No more \"minimum payment\" dread"),
                    ("🆓", "Freedom to say yes to what matters")
                ],
                amountLabel: "How much are you paying off?",
                placeholder: "e.g., \"Financial freedom\""
            )
        case .downPayment, .car, .bigPurchase:
            return GoalSpecificContent(
                introText: goalName.isEmpty ? "Saving for this means..." : "Saving for \(goalName) means...",
                meaningPhrases: [
                    ("💰", "Buying it outright, no interest"),
                    ("😊", "The satisfaction of earning it"),
                    ("🎉", "No buyer's remorse, just pride")
                ],
                amountLabel: "How much do you need?",
                placeholder: "e.g., \"Buying it the right way\""
            )
        case .retirement:
            return GoalSpecificContent(
                introText: "Retirement means...",
                meaningPhrases: [
                    ("🌴", "Freedom to choose how you spend your time"),
                    ("💎", "Security for your future self"),
                    ("🎯", "Living life on your terms")
                ],
                amountLabel: "What's your retirement goal?",
                placeholder: "e.g., \"Financial independence\""
            )
        case .justStop:
            return GoalSpecificContent(
                introText: "Keeping your money means...",
                meaningPhrases: [
                    ("🛑", "Stuff stops owning you"),
                    ("🙏", "Your future self will thank you"),
                    ("💪", "Spending on purpose, not impulse")
                ],
                amountLabel: "What's your first savings target?",
                placeholder: "e.g., \"Breaking the cycle\""
            )
        }
    }
}

// MARK: - Screen 8: Goal Details

struct OnboardingGoalDetailsView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    @State private var phraseAppearances: [Bool] = []
    
    private var goalContent: GoalSpecificContent {
        GoalSpecificContent.content(for: appState.onboardingGoalType, goalName: appState.onboardingGoalName)
    }
    
    var body: some View {
        OnboardingContainer(step: .goalDetails) {
            VStack(spacing: SpendLessSpacing.lg) {
                if appState.onboardingGoalType.requiresDetails {
                    goalDetailsForm
                } else {
                    noGoalView
                }
            }
        }
    }
    
    private var goalDetailsForm: some View {
        VStack(spacing: SpendLessSpacing.md) {
            // Main heading - just the intro text
            Text(goalContent.introText)
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.top, SpendLessSpacing.lg)
                .padding(.horizontal, SpendLessSpacing.md)
            
            // Meaning phrases section
            VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                VStack(spacing: SpendLessSpacing.xs) {
                    ForEach(Array(goalContent.meaningPhrases.enumerated()), id: \.offset) { index, phrase in
                        MeaningChip(
                            icon: phrase.icon,
                            text: phrase.text,
                            isVisible: index < phraseAppearances.count ? phraseAppearances[index] : false
                        ) {
                            appState.onboardingGoalName = phrase.text
                        }
                    }
                }
            }
            .padding(.horizontal, SpendLessSpacing.md)
            
            // "Or in your words" section
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                Text("Or in your words...")
                    .font(SpendLessFont.subheadline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                SpendLessTextField(
                    "What does it mean to you?",
                    text: Binding(
                        get: { appState.onboardingGoalName },
                        set: { appState.onboardingGoalName = $0 }
                    ),
                    placeholder: goalContent.placeholder
                )
            }
            .padding(.horizontal, SpendLessSpacing.md)
            
            // Amount field
            CurrencyTextField(
                title: goalContent.amountLabel,
                amount: Binding(
                    get: { appState.onboardingGoalAmount },
                    set: { appState.onboardingGoalAmount = $0 }
                )
            )
            .padding(.horizontal, SpendLessSpacing.md)
            
            Spacer()
            
            PrimaryButton("Continue") {
                onContinue()
            }
            .disabled(appState.onboardingGoalName.isEmpty || appState.onboardingGoalAmount <= 0)
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .hideKeyboardOnTap()
        .onAppear {
            animatePhrases()
        }
        .onChange(of: appState.onboardingGoalType) { _, _ in
            animatePhrases()
        }
    }
    
    private func animatePhrases() {
        let phraseCount = goalContent.meaningPhrases.count
        // Reset appearances
        phraseAppearances = Array(repeating: false, count: phraseCount)
        
        // Stagger the animations
        for index in 0..<phraseCount {
            DispatchQueue.main.asyncAfter(deadline: .now() + Double(index) * 0.2) {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.7)) {
                    if index < phraseAppearances.count {
                        phraseAppearances[index] = true
                    }
                }
            }
        }
    }
    
    private func placeholderForGoalType(_ goalType: GoalType) -> String {
        switch goalType {
        case .emergency:
            return "e.g., 6 months of expenses"
        case .vacation:
            return "e.g., Trip to Japan"
        case .retirement:
            return "e.g., $500,000 retirement fund"
        case .debtFree:
            return "e.g., Pay off credit card debt"
        case .downPayment:
            return "e.g., House down payment"
        case .car:
            return "e.g., New car"
        case .bigPurchase:
            return "e.g., New laptop"
        case .justStop:
            return ""
        }
    }
    
    private var noGoalView: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            Text("💰")
                .font(.system(size: 80))
            
            VStack(spacing: SpendLessSpacing.md) {
                Text("That's okay!")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("We'll track how much you save and you can set a goal later if you want.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            PrimaryButton("Continue") {
                onContinue()
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
}

// MARK: - Screen 9: Desired Outcomes

struct OnboardingDesiredOutcomesView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .desiredOutcomes) {
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("What do you want from this?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Select all that apply")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.lg)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.xs) {
                        ForEach(DesiredOutcome.allCases) { outcome in
                            SelectionCard(
                                title: outcome.displayName,
                                icon: outcome.icon,
                                isSelected: appState.onboardingDesiredOutcomes.contains(outcome),
                                padding: SpendLessSpacing.sm
                            ) {
                                toggleOutcome(outcome)
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                PrimaryButton("Continue") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private func toggleOutcome(_ outcome: DesiredOutcome) {
        if appState.onboardingDesiredOutcomes.contains(outcome) {
            appState.onboardingDesiredOutcomes.remove(outcome)
        } else {
            appState.onboardingDesiredOutcomes.insert(outcome)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

