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
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()
                
                // Illustration
                Image(systemName: "cart.badge.minus")
                    .font(.system(size: 100))
                    .foregroundStyle(Color.spendLessPrimary)
                
                VStack(spacing: SpendLessSpacing.md) {
                    Text("Ready to break free from impulse shopping?")
                        .font(SpendLessFont.title)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("We'll help you pause, reflect, and redirect your spending toward what really matters.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Get Started", icon: "arrow.right") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
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
            VStack(spacing: SpendLessSpacing.lg) {
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Which of these sounds like you?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Select all that apply")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(ShoppingTrigger.allCases) { trigger in
                            SelectionCard(
                                title: trigger.rawValue,
                                icon: trigger.icon,
                                isSelected: appState.onboardingTriggers.contains(trigger)
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
        } else {
            appState.onboardingTriggers.insert(trigger)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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
        } else {
            appState.onboardingTimings.insert(timing)
        }
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
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

// MARK: - Screen 8: Goal Details

struct OnboardingGoalDetailsView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void
    
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
        VStack(spacing: SpendLessSpacing.lg) {
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Tell us about your goal")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("We'll help you get there")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .padding(.top, SpendLessSpacing.xl)
            
            // Show selected goal type at the top
            Card {
                HStack(spacing: SpendLessSpacing.md) {
                    IconView(appState.onboardingGoalType.icon, font: .title)
                    
                    Text(appState.onboardingGoalType.rawValue)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Spacer()
                }
            }
            .padding(.horizontal, SpendLessSpacing.md)
            
            VStack(spacing: SpendLessSpacing.md) {
                SpendLessTextField(
                    "What is it?",
                    text: Binding(
                        get: { appState.onboardingGoalName },
                        set: { appState.onboardingGoalName = $0 }
                    ),
                    placeholder: placeholderForGoalType(appState.onboardingGoalType)
                )
                
                CurrencyTextField(
                    title: "How much will it cost?",
                    amount: Binding(
                        get: { appState.onboardingGoalAmount },
                        set: { appState.onboardingGoalAmount = $0 }
                    )
                )
            }
            .padding(.horizontal, SpendLessSpacing.md)
            
            Spacer()
            
            PrimaryButton("Continue") {
                onContinue()
            }
            .disabled(appState.onboardingGoalName.isEmpty || appState.onboardingGoalAmount <= 0)
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
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

