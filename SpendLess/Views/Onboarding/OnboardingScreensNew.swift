//
//  OnboardingScreensNew.swift
//  SpendLess
//
//  New consolidated onboarding screens (13-screen flow)
//

import SwiftUI
import SwiftData
import Lottie

// MARK: - Screen 2: About You (NEW)

struct AboutYouView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void

    // Filter out socialMediaAds and lateNight triggers
    private var visibleTriggers: [ShoppingTrigger] {
        ShoppingTrigger.allCases.filter { trigger in
            trigger != .socialMediaAds && trigger != .lateNight
        }
    }

    var body: some View {
        VStack(spacing: SpendLessSpacing.md) {
            // Header
            Text("Let's understand your patterns")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
                .padding(.top, SpendLessSpacing.md)

            // Section 1: Triggers
            VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                Text("What triggers you to shop?")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)

                // Compact chips for triggers
                FlowLayout(spacing: SpendLessSpacing.xs) {
                    ForEach(visibleTriggers) { trigger in
                        TriggerChip(
                            title: trigger.rawValue,
                            icon: trigger.icon,
                            isSelected: appState.onboardingTriggers.contains(trigger)
                        ) {
                            toggleTrigger(trigger)
                        }
                    }
                }
            }
            .padding(.horizontal, SpendLessSpacing.md)

            Divider()
                .padding(.horizontal, SpendLessSpacing.lg)

            // Section 2: Monthly Spend
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                Text("Monthly impulse spending?")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Text("Be honest - no judgment")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)

                VStack(spacing: SpendLessSpacing.xs) {
                    ForEach(SpendRange.allCases) { range in
                        SelectionCard(
                            title: range.rawValue,
                            icon: "💸",
                            isSelected: appState.onboardingSpendRange == range
                        ) {
                            appState.onboardingSpendRange = range
                            HapticFeedback.lightSuccess()
                        }
                    }
                }
            }
            .padding(.horizontal, SpendLessSpacing.md)

            Spacer(minLength: 0)

            PrimaryButton("Continue") {
                onContinue()
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.lg)
        }
    }

    private func toggleTrigger(_ trigger: ShoppingTrigger) {
        if appState.onboardingTriggers.contains(trigger) {
            appState.onboardingTriggers.remove(trigger)
            HapticFeedback.lightSuccess()
        } else {
            appState.onboardingTriggers.insert(trigger)
            HapticFeedback.mediumSuccess()
        }
    }
}

// MARK: - Trigger Chip Component

struct TriggerChip: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xs) {
                Text(icon)
                    .font(.subheadline)
                Text(title)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(isSelected ? Color.white : Color.spendLessTextPrimary)
            }
            .padding(.horizontal, SpendLessSpacing.sm)
            .padding(.vertical, SpendLessSpacing.xs)
            .background(isSelected ? Color.spendLessPrimary : Color.spendLessCardBackground)
            .clipShape(Capsule())
            .overlay(
                Capsule()
                    .strokeBorder(isSelected ? Color.clear : Color.spendLessTextMuted.opacity(0.3), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Flow Layout for Chips

struct FlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                      y: bounds.minY + result.positions[index].y),
                         proposal: .unspecified)
        }
    }

    struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in maxWidth: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > maxWidth && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing

                self.size.width = max(self.size.width, x)
            }

            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Screen 3: The Cost (NEW)

struct TheCostView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void

    @State private var animatedYearly: Double = 0
    @State private var animatedDecade: Double = 0
    @State private var showQuestion = false
    @State private var showButton = false
    @State private var hasAnimated = false

    var body: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()

            VStack(spacing: SpendLessSpacing.lg) {
                Text("If you're spending ~\(formatCurrency(appState.onboardingSpendRange.monthlyEstimate))/month on things you don't need...")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, SpendLessSpacing.lg)

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

            Spacer()

            PrimaryButton("Let's change that") {
                onContinue()
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
            .opacity(showButton ? 1 : 0)
            .scaleEffect(showButton ? 1 : 0.95)
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showButton)
        }
        .onAppear {
            guard !hasAnimated else { return }
            hasAnimated = true
            animateNumbers()
        }
    }

    private func animateNumbers() {
        let yearly = (appState.onboardingSpendRange.yearlyEstimate as NSDecimalNumber).doubleValue
        let decade = (appState.onboardingSpendRange.decadeEstimate as NSDecimalNumber).doubleValue

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

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.7) {
            showQuestion = true
            HapticFeedback.mediumSuccess()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
            showButton = true
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

// MARK: - Screen 4: The Psychology (NEW)

struct PsychologyView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.spendLessPrimaryDark.ignoresSafeArea()

            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()

                LottieAnimationView(animationName: "brain")
                    .frame(height: 200)

                VStack(spacing: SpendLessSpacing.md) {
                    Text("This isn't about willpower")
                        .font(SpendLessFont.title)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("Shopping addiction is a dopamine problem, not a character flaw. Your brain learned that buying = quick relief.\n\nBut here's the good news: dopamine systems heal. By pausing before purchases, you start wanting less—not just resisting more.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, SpendLessSpacing.md)
                }

                // Progress dots (1 of 2)
                HStack(spacing: SpendLessSpacing.xs) {
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 8, height: 8)
                }
                .padding(.top, SpendLessSpacing.md)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Next")
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessPrimaryDark)
                        .frame(maxWidth: .infinity)
                        .padding(SpendLessSpacing.md)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Screen 5: Future You (NEW)

struct FutureYouView: View {
    let onContinue: () -> Void

    var body: some View {
        ZStack {
            Color.spendLessSecondary.ignoresSafeArea()

            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()

                LottieAnimationView(animationName: "futureSelf")
                    .frame(height: 200)

                VStack(spacing: SpendLessSpacing.md) {
                    Text("Future you is counting on you")
                        .font(SpendLessFont.title)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.center)

                    Text("That trip. That debt paid off. That breathing room. Future you wants those things.\n\nEvery impulse buy steals from them. But every time you resist? That's a gift to yourself.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(.white.opacity(0.9))
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                        .padding(.horizontal, SpendLessSpacing.md)
                }

                // Progress dots (2 of 2)
                HStack(spacing: SpendLessSpacing.xs) {
                    Circle()
                        .fill(Color.white.opacity(0.4))
                        .frame(width: 8, height: 8)
                    Circle()
                        .fill(Color.white)
                        .frame(width: 8, height: 8)
                }
                .padding(.top, SpendLessSpacing.md)

                Spacer()

                Button {
                    onContinue()
                } label: {
                    Text("Next")
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessSecondary)
                        .frame(maxWidth: .infinity)
                        .padding(SpendLessSpacing.md)
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
}

// MARK: - Screen 6: Your Goal (NEW)

struct YourGoalView: View {
    @Environment(AppState.self) private var appState
    let onContinue: () -> Void

    @State private var showDetails = false
    @State private var phraseAppearances: [Bool] = []

    private var goalContent: GoalSpecificContent {
        GoalSpecificContent.content(for: appState.onboardingGoalType, goalName: appState.onboardingGoalName)
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Header
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("What would you rather have?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)

                    Text("Pick something to work toward")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.lg)

                if !showDetails {
                    // Goal type selection - nothing pre-selected visually
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(GoalType.allCases) { goalType in
                            SelectionCard(
                                title: goalType.rawValue,
                                icon: goalType.icon,
                                isSelected: false
                            ) {
                                appState.onboardingGoalType = goalType
                                HapticFeedback.lightSuccess()

                                // Show details after selection
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    showDetails = true
                                }

                                // Animate phrases if needed
                                if goalType.requiresDetails {
                                    animatePhrases()
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                } else {
                    // Selected goal card (highlighted)
                    SelectionCard(
                        title: appState.onboardingGoalType.rawValue,
                        icon: appState.onboardingGoalType.icon,
                        isSelected: true
                    ) {
                        // Allow changing selection
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            showDetails = false
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)

                    Divider()
                        .padding(.horizontal, SpendLessSpacing.lg)

                    if appState.onboardingGoalType.requiresDetails {
                        goalDetailsSection
                    } else {
                        noGoalSection
                    }
                }

                Spacer(minLength: SpendLessSpacing.xxl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                if !showDetails {
                    // Prompt user to tap a goal
                    Text("Tap a goal to continue")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .padding(.bottom, SpendLessSpacing.sm)
                }

                PrimaryButton("Continue") {
                    onContinue()
                }
                .disabled(!showDetails || (appState.onboardingGoalType.requiresDetails &&
                          appState.onboardingGoalAmount <= 0))
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .background(Color.spendLessBackground)
        }
        .hideKeyboardOnTap()
    }

    private var goalDetailsSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
            // Amount field - first and prominent
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                Text(goalContent.amountLabel)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)

                CurrencyTextField(
                    title: "",
                    amount: Binding(
                        get: { appState.onboardingGoalAmount },
                        set: { appState.onboardingGoalAmount = $0 }
                    )
                )
            }
            .padding(.horizontal, SpendLessSpacing.md)

            Divider()
                .padding(.horizontal, SpendLessSpacing.lg)

            // Intro text
            Text(goalContent.introText)
                .font(SpendLessFont.subheadline)
                .foregroundStyle(Color.spendLessTextSecondary)
                .padding(.horizontal, SpendLessSpacing.md)

            // Meaning phrases
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
            .padding(.horizontal, SpendLessSpacing.md)

            // Custom text field
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                Text("Or in your words...")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)

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
        }
    }

    private var noGoalSection: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Text("💰")
                .font(.system(size: 60))

            Text("That's okay!")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)

            Text("We'll track how much you save and you can set a goal later if you want.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, SpendLessSpacing.lg)
        }
        .padding(.vertical, SpendLessSpacing.xl)
    }

    private func animatePhrases() {
        let phraseCount = goalContent.meaningPhrases.count
        phraseAppearances = Array(repeating: false, count: phraseCount)

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
}

// MARK: - Screen 7: How It Works (SIMPLIFIED)

struct HowItWorksSimpleView: View {
    let onContinue: () -> Void

    var body: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Text("How SpendLess works")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
                .padding(.top, SpendLessSpacing.lg)

            VStack(spacing: SpendLessSpacing.sm) {
                HowItWorksCard(
                    emoji: "🛡️",
                    title: "BLOCK",
                    description: "Shield yourself from shopping apps when urges hit"
                )

                HowItWorksCard(
                    emoji: "🧘",
                    title: "INTERVENE",
                    description: "Breathing exercises and prompts to help you pause"
                )

                HowItWorksCard(
                    emoji: "⏳",
                    title: "WAIT",
                    description: "Add impulse buys to a 7-day list. Most urges fade."
                )

                HowItWorksCard(
                    emoji: "🧠",
                    title: "LEARN",
                    description: "Tools to understand your triggers and habits"
                )

                HowItWorksCard(
                    emoji: "🎯",
                    title: "GROW",
                    description: "Track savings and progress toward your goals"
                )
            }
            .padding(.horizontal, SpendLessSpacing.md)

            Spacer()

            PrimaryButton("Continue") {
                onContinue()
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
}

struct HowItWorksCard: View {
    let emoji: String
    let title: String
    let description: String

    var body: some View {
        HStack(alignment: .top, spacing: SpendLessSpacing.md) {
            Text(emoji)
                .font(.system(size: 32))

            VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                Text(title)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Text(description)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }

            Spacer()
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
    }
}

// MARK: - Screen 8: First Resist (NEW)

struct FirstResistView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    let onContinue: () -> Void

    @State private var itemName = ""
    @State private var itemAmount: Decimal = 0
    @State private var selectedReason: ReasonWanted?
    @State private var otherReasonNote = ""
    @State private var numberOfWears: String = ""
    @State private var showReasonPicker = false
    @State private var showSuccessMessage = false

    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    VStack(spacing: SpendLessSpacing.xs) {
                        Text("What did you resist?")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)

                        Text("When you want to buy something, add it here instead.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding(.top, SpendLessSpacing.lg)

                    inputForm

                    Spacer(minLength: 140)
                }
                .padding(.horizontal, SpendLessSpacing.md)
            }
            .scrollDismissesKeyboard(.interactively)

            // Bottom action area
            VStack {
                Spacer()

                VStack(spacing: SpendLessSpacing.sm) {
                    Text("If you still want it in 7 days, you can buy it guilt-free.")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .multilineTextAlignment(.center)

                    PrimaryButton("Add to Waiting List", icon: "clock") {
                        addItemToWaitlist()
                    }
                    .disabled(itemName.isEmpty || itemAmount <= 0)

                    Button("Skip for now") {
                        onContinue()
                    }
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextMuted)
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
                .padding(.top, SpendLessSpacing.sm)
                .background(
                    Color.spendLessBackground
                        .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                )
            }

            // Success toast overlay
            if showSuccessMessage {
                VStack {
                    Spacer()

                    HStack(spacing: SpendLessSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.white)
                        Text("Added to your waitlist!")
                            .font(SpendLessFont.bodyBold)
                            .foregroundStyle(Color.white)
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.vertical, SpendLessSpacing.md)
                    .background(Color.spendLessSecondary)
                    .clipShape(Capsule())
                    .shadow(color: .black.opacity(0.15), radius: 10, y: 5)

                    Spacer()
                }
                .transition(.opacity.combined(with: .scale))
            }
        }
        .sheet(isPresented: $showReasonPicker) {
            ReasonWantedPicker(selectedReason: $selectedReason)
                .presentationDetents([.medium])
        }
    }

    private var inputForm: some View {
        VStack(spacing: SpendLessSpacing.md) {
            SpendLessTextField(
                "What is it?",
                text: $itemName,
                placeholder: "e.g., Wireless earbuds"
            )

            HStack(spacing: SpendLessSpacing.md) {
                CurrencyTextField(
                    title: "How much?",
                    amount: $itemAmount
                )

                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("Number of wears?")
                        .font(SpendLessFont.subheadline)
                        .foregroundStyle(Color.spendLessTextPrimary)

                    TextField("e.g., 50", text: $numberOfWears)
                        .font(SpendLessFont.title3)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .keyboardType(.numberPad)
                        .padding(SpendLessSpacing.md)
                        .background(Color.spendLessBackgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                        .onChange(of: numberOfWears) { _, newValue in
                            let filtered = newValue.filter { $0.isNumber }
                            if filtered != newValue {
                                numberOfWears = filtered
                            }
                        }
                }
            }

            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                Text("Why do you want it? (optional)")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)

                Button {
                    showReasonPicker = true
                } label: {
                    HStack {
                        if let reason = selectedReason {
                            Text(reason.icon)
                            Text(reason.displayName)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        } else {
                            Text("Select a reason...")
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        Spacer()
                        Image(systemName: "chevron.down")
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                    .font(SpendLessFont.body)
                    .padding(SpendLessSpacing.md)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                }
                .buttonStyle(.plain)
            }

            if selectedReason == .other {
                SpendLessTextField(
                    "Tell us more",
                    text: $otherReasonNote,
                    placeholder: "What's the reason?"
                )
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
    }

    private func addItemToWaitlist() {
        let item = WaitingListItem(
            name: itemName,
            amount: itemAmount,
            reasonWanted: selectedReason,
            reasonWantedNote: selectedReason == .other ? otherReasonNote : nil
        )

        if let wears = Int(numberOfWears), wears > 0 {
            item.pricePerWearEstimate = wears
        }

        modelContext.insert(item)

        do {
            try modelContext.save()
            HapticFeedback.mediumSuccess()

            // Show success toast and auto-continue
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                showSuccessMessage = true
            }

            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                onContinue()
            }
        } catch {
            // Silently handle save errors - user can re-add item later
        }
    }
}

// MARK: - Screen 9: Stay Committed (Lead Magnet Wrapper)

struct StayCommittedView: View {
    @Environment(\.modelContext) private var modelContext
    let onContinue: () -> Void

    var body: some View {
        LeadMagnetView(
            source: .onboarding,
            onComplete: {
                onContinue()
            },
            onSkip: {
                onContinue()
            }
        )
    }
}

// MARK: - Screen 12: Ready (NEW)

struct ReadyView: View {
    @Environment(AppState.self) private var appState
    @Environment(\.modelContext) private var modelContext
    @Bindable var screenTimeManager = ScreenTimeManager.shared
    let onContinue: () -> Void

    @State private var notificationStatus: UNAuthorizationStatus = .notDetermined
    @State private var isRequestingNotifications = false
    @State private var showShortcutsSetup = false
    @State private var shortcutsSetupComplete = false
    @Query private var waitingListItems: [WaitingListItem]

    private var firstItem: WaitingListItem? {
        waitingListItems.first
    }

    var body: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.xl) {
                Text("You're all set!")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .padding(.top, SpendLessSpacing.xl)

                // Summary Card
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    summaryRow(icon: "checkmark.circle.fill", text: "\(screenTimeManager.blockedAppCount) apps blocked", color: .spendLessSecondary)

                    if appState.onboardingGoalType.requiresDetails && appState.onboardingGoalAmount > 0 {
                        summaryRow(
                            icon: "checkmark.circle.fill",
                            text: "Goal: \(appState.onboardingGoalName.isEmpty ? appState.onboardingGoalType.rawValue : appState.onboardingGoalName) — \(formatCurrency(appState.onboardingGoalAmount))",
                            color: .spendLessSecondary
                        )
                    }

                    if let item = firstItem {
                        summaryRow(icon: "checkmark.circle.fill", text: "First item: \(item.name)", color: .spendLessSecondary)
                    }
                }
                .padding(SpendLessSpacing.md)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                .padding(.horizontal, SpendLessSpacing.md)

                Divider()
                    .padding(.horizontal, SpendLessSpacing.lg)

                // Notifications Section
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    Text("Stay on track")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)

                    Text("Get reminders and celebrate your wins.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)

                    if notificationStatus == .authorized || notificationStatus == .provisional {
                        HStack(spacing: SpendLessSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.spendLessSecondary)
                            Text("Notifications enabled")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        .padding(.top, SpendLessSpacing.xs)
                    } else {
                        Button {
                            requestNotifications()
                        } label: {
                            HStack(spacing: SpendLessSpacing.sm) {
                                if isRequestingNotifications {
                                    ProgressView()
                                        .scaleEffect(0.8)
                                } else {
                                    Image(systemName: "bell")
                                }
                                Text("Enable Notifications")
                            }
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessPrimary)
                        }
                        .disabled(isRequestingNotifications)
                        .padding(.top, SpendLessSpacing.xs)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SpendLessSpacing.md)

                Divider()
                    .padding(.horizontal, SpendLessSpacing.lg)

                // Shortcuts Section
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    Text("Want richer interventions?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)

                    Text("Breathing exercises and reflection prompts when you're tempted.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)

                    if shortcutsSetupComplete {
                        HStack(spacing: SpendLessSpacing.sm) {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(Color.spendLessSecondary)
                            Text("Shortcuts configured")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        .padding(.top, SpendLessSpacing.xs)
                    } else {
                        SecondaryButton("Set Up Shortcuts") {
                            showShortcutsSetup = true
                        }
                        .padding(.top, SpendLessSpacing.xs)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, SpendLessSpacing.md)

                Spacer(minLength: SpendLessSpacing.xxl)
            }
        }
        .safeAreaInset(edge: .bottom) {
            VStack {
                PrimaryButton("Start Using SpendLess") {
                    onContinue()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .background(Color.spendLessBackground)
        }
        .onAppear {
            checkNotificationStatus()
        }
        .sheet(isPresented: $showShortcutsSetup) {
            ShortcutsSetupView {
                shortcutsSetupComplete = true
            }
        }
    }

    private func summaryRow(icon: String, text: String, color: Color) -> some View {
        HStack(spacing: SpendLessSpacing.sm) {
            Image(systemName: icon)
                .foregroundStyle(color)
            Text(text)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
    }

    private func checkNotificationStatus() {
        Task {
            let settings = await UNUserNotificationCenter.current().notificationSettings()
            await MainActor.run {
                notificationStatus = settings.authorizationStatus
            }
        }
    }

    private func requestNotifications() {
        isRequestingNotifications = true

        Task {
            do {
                let granted = try await UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound])
                await MainActor.run {
                    notificationStatus = granted ? .authorized : .denied
                    isRequestingNotifications = false
                }
            } catch {
                await MainActor.run {
                    isRequestingNotifications = false
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

// MARK: - Previews

#Preview("About You") {
    AboutYouView(onContinue: {})
        .environment(AppState.shared)
}

#Preview("The Cost") {
    TheCostView(onContinue: {})
        .environment(AppState.shared)
}

#Preview("Psychology") {
    PsychologyView(onContinue: {})
}

#Preview("Future You") {
    FutureYouView(onContinue: {})
}

#Preview("Your Goal") {
    YourGoalView(onContinue: {})
        .environment(AppState.shared)
}

#Preview("How It Works") {
    HowItWorksSimpleView(onContinue: {})
}
