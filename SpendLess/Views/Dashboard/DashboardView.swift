//
//  DashboardView.swift
//  SpendLess
//
//  Main dashboard/home screen
//

import SwiftUI
import SwiftData

struct DashboardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query private var goals: [UserGoal]
    @Query private var graveyardItems: [GraveyardItem]
    @Query private var streaks: [Streak]
    @Query private var profiles: [UserProfile]
    
    @State private var showPanicButton = false
    @State private var showCelebration = false
    @State private var celebrationAmount: Decimal = 0
    @State private var celebrationMessage = ""
    @State private var showAnniversary: Bool = false
    @State private var anniversaryMilestone: Int = 0
    
    private var currentGoal: UserGoal? {
        goals.first { $0.isActive }
    }
    
    private var currentStreak: Streak? {
        streaks.first
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var totalSaved: Decimal {
        graveyardItems.reduce(0) { $0 + $1.amount }
    }
    
    private var thisWeekSaved: Decimal {
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return graveyardItems
            .filter { $0.buriedAt >= weekAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var impulsesResisted: Int {
        graveyardItems.count
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.lg) {
                        // Goal Progress Section
                        GoalProgressView(goal: currentGoal, totalSaved: totalSaved)
                            .padding(.horizontal, SpendLessSpacing.md)
                        
                        // Stats Row
                        HStack(spacing: SpendLessSpacing.md) {
                            StatsCard(
                                icon: "flame.fill",
                                value: "\(currentStreak?.currentDays ?? 0)",
                                label: "Day Streak",
                                iconColor: .spendLessStreak
                            )
                            
                            StatsCard(
                                icon: "dollarsign.circle.fill",
                                value: formatCurrency(thisWeekSaved),
                                label: "This Week"
                            )
                            
                            StatsCard(
                                icon: "cart.badge.minus",
                                value: "\(impulsesResisted)",
                                label: "Resisted"
                            )
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        // Streak milestone message
                        if let streak = currentStreak, let message = streak.celebrationMessage {
                            Card {
                                HStack {
                                    Text("🔥")
                                        .font(.title)
                                    Text(message)
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                }
                            }
                            .padding(.horizontal, SpendLessSpacing.md)
                        }
                        
                        Spacer(minLength: SpendLessSpacing.xxxl)
                    }
                    .padding(.top, SpendLessSpacing.md)
                }
                
                // Panic Button (floating at bottom)
                VStack {
                    Spacer()
                    
                    PanicButtonView {
                        showPanicButton = true
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.bottom, SpendLessSpacing.md)
                }
                
                // Celebration Overlay
                if showCelebration {
                    CelebrationOverlay(
                        isShowing: $showCelebration,
                        amount: celebrationAmount,
                        message: celebrationMessage
                    )
                }
                
                // Anniversary Overlay
                if showAnniversary {
                    CommitmentAnniversaryView(milestone: anniversaryMilestone) {
                        showAnniversary = false
                        markAnniversaryShown(anniversaryMilestone)
                    }
                }
            }
            .navigationTitle("SpendLess")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                checkAnniversaries()
            }
            .sheet(isPresented: $showPanicButton) {
                PanicButtonFlowView { amount in
                    // Handle panic button completion
                    celebrationAmount = amount
                    celebrationMessage = generateCelebrationMessage(for: amount)
                    showCelebration = true
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
    
    private func generateCelebrationMessage(for amount: Decimal) -> String {
        if let goal = currentGoal {
            if let translation = goal.savingsTranslation(for: amount) {
                return translation
            }
            return "Every dollar counts toward \(goal.type.rawValue)!"
        }
        return "That's money back in your pocket!"
    }
    
    private func checkAnniversaries() {
        guard let profile = profile,
              let _ = profile.commitmentDate,
              let daysSince = profile.daysSinceCommitment else {
            return
        }
        
        let milestones = [7, 30, 90, 365]
        
        for milestone in milestones {
            if daysSince == milestone && !hasShownAnniversary(milestone) {
                anniversaryMilestone = milestone
                showAnniversary = true
                return
            }
        }
    }
    
    private func hasShownAnniversary(_ milestone: Int) -> Bool {
        let defaults = UserDefaults.standard
        return defaults.bool(forKey: "anniversary_\(milestone)_shown")
    }
    
    private func markAnniversaryShown(_ milestone: Int) {
        let defaults = UserDefaults.standard
        defaults.set(true, forKey: "anniversary_\(milestone)_shown")
    }
}

// MARK: - Panic Button View

struct PanicButtonView: View {
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("PANIC BUTTON")
                        .font(SpendLessFont.headline)
                    Text("Feeling tempted?")
                        .font(SpendLessFont.caption)
                        .opacity(0.9)
                }
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.body.weight(.semibold))
            }
            .foregroundStyle(.white)
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .fill(Color.spendLessPrimary)
            )
            .spendLessShadow(SpendLessShadow.buttonShadow)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .accessibilityLabel("Panic button. Tap when feeling tempted to shop.")
    }
}

// MARK: - Panic Button Flow

struct PanicButtonFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query private var goals: [UserGoal]
    @Query private var profiles: [UserProfile]
    
    let onComplete: (Decimal) -> Void
    
    enum Step {
        case breathing
        case letter
        case logging
        case celebration
    }
    
    @State private var currentStep: Step = .breathing
    @State private var itemName = ""
    @State private var itemAmount: Decimal = 0
    @State private var showMoneyAnimation = false
    
    private var currentGoal: UserGoal? {
        goals.first { $0.isActive }
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                switch currentStep {
                case .breathing:
                    breathingStep
                case .letter:
                    letterStep
                case .logging:
                    loggingStep
                case .celebration:
                    celebrationStep
                }
                
                if showMoneyAnimation {
                    MoneyFlyingAnimation(
                        isAnimating: $showMoneyAnimation,
                        amount: itemAmount,
                        startPosition: CGPoint(x: UIScreen.main.bounds.width / 2, y: UIScreen.main.bounds.height - 200),
                        endPosition: CGPoint(x: UIScreen.main.bounds.width / 2, y: 100)
                    )
                }
            }
            .navigationTitle("Take a Moment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Steps
    
    private var breathingStep: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            QuickBreathingExercise {
                withAnimation {
                    // Show letter if available, otherwise go to logging
                    if let profile = profile, let letterText = profile.futureLetterText, !letterText.isEmpty {
                        currentStep = .letter
                    } else {
                        currentStep = .logging
                    }
                }
            }
            
            Spacer()
            
            TextButton("Skip") {
                withAnimation {
                    // Skip to letter if available, otherwise logging
                    if let profile = profile, let letterText = profile.futureLetterText, !letterText.isEmpty {
                        currentStep = .letter
                    } else {
                        currentStep = .logging
                    }
                }
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding()
    }
    
    private var letterStep: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            VStack(spacing: SpendLessSpacing.md) {
                Text("You wrote this to yourself:")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                if let letterText = profile?.futureLetterText, !letterText.isEmpty {
                    Card {
                        Text(letterText)
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextPrimary)
                            .multilineTextAlignment(.center)
                            .padding(SpendLessSpacing.md)
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                }
                
                Text("The urge will pass.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .padding(.top, SpendLessSpacing.sm)
                
                Text("What brought you here?")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .padding(.top, SpendLessSpacing.xs)
            }
            .multilineTextAlignment(.center)
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            
            PrimaryButton("Continue") {
                withAnimation {
                    currentStep = .logging
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    private var loggingStep: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            VStack(spacing: SpendLessSpacing.xs) {
                Text("What were you about to buy?")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("Log it here and we'll add it to your savings")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .multilineTextAlignment(.center)
            .padding(.top, SpendLessSpacing.xl)
            
            VStack(spacing: SpendLessSpacing.md) {
                SpendLessTextField(
                    "Item name",
                    text: $itemName,
                    placeholder: "e.g., Cute dress on sale"
                )
                
                CurrencyTextField(title: "How much was it?", amount: $itemAmount)
            }
            .padding(.horizontal, SpendLessSpacing.md)
            
            Spacer()
            
            PrimaryButton("I resisted! Log it.", icon: "checkmark.circle.fill") {
                saveItem()
            }
            .disabled(itemName.isEmpty || itemAmount <= 0)
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    private var celebrationStep: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            Text("🎉")
                .font(.system(size: 80))
            
            Text("You didn't spend")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Text(formatCurrency(itemAmount))
                .font(SpendLessFont.largeTitle)
                .foregroundStyle(Color.spendLessPrimary)
            
            if let goal = currentGoal {
                Text("That's going toward \(goal.type.rawValue)!")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
            }
            
            Spacer()
            
            PrimaryButton("Done") {
                onComplete(itemAmount)
                dismiss()
            }
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    // MARK: - Actions
    
    private func saveItem() {
        // Create graveyard item
        let graveyardItem = GraveyardItem(
            name: itemName,
            amount: itemAmount,
            source: .panicButton
        )
        modelContext.insert(graveyardItem)
        
        // Update goal if exists
        if let goal = currentGoal {
            goal.addSavings(itemAmount)
        }
        
        try? modelContext.save()
        
        // Sync widget data
        appState.syncWidgetData(context: modelContext)
        
        // Trigger celebration
        showMoneyAnimation = true
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            withAnimation {
                currentStep = .celebration
            }
        }
        
        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Preview

#Preview {
    DashboardView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

