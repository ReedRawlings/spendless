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
    @Environment(InterventionManager.self) private var interventionManager
    
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]
    @Query private var graveyardItems: [GraveyardItem]
    @Query private var streaks: [Streak]
    @Query private var profiles: [UserProfile]

    @State private var showFeelingTempted = false
    @State private var showCelebration = false
    @State private var celebrationAmount: Decimal = 0
    @State private var celebrationMessage = ""
    @State private var showAnniversary: Bool = false
    @State private var anniversaryMilestone: Int = 0
    @State private var showEditGoal = false

    private var currentGoal: UserGoal? {
        activeGoals.first
    }
    
    private var currentStreak: Streak? {
        streaks.first
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var totalSaved: Decimal {
        if AppConstants.isScreenshotMode {
            return ScreenshotDataHelper.dashboardTotalSaved
        }
        return graveyardItems.reduce(0) { $0 + $1.amount }
    }
    
    private var thisWeekSaved: Decimal {
        if AppConstants.isScreenshotMode {
            return ScreenshotDataHelper.dashboardThisWeekValue
        }
        let weekAgo = Calendar.current.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return graveyardItems
            .filter { $0.buriedAt >= weekAgo }
            .reduce(0) { $0 + $1.amount }
    }
    
    private var impulsesResisted: Int {
        if AppConstants.isScreenshotMode {
            return ScreenshotDataHelper.dashboardResistedValue
        }
        let graveyardCount = graveyardItems.count
        let interventionCount = interventionManager.resistCount
        return graveyardCount + interventionCount
    }
    
    private var screenshotStreak: Int {
        AppConstants.isScreenshotMode ? ScreenshotDataHelper.dashboardStreakValue : (currentStreak?.currentDays ?? 0)
    }
    
    private var screenshotGoal: UserGoal? {
        guard AppConstants.isScreenshotMode else { return currentGoal }
        // Create a fake goal for screenshot mode
        let goal = UserGoal(
            name: ScreenshotDataHelper.goalName,
            targetAmount: ScreenshotDataHelper.goalTargetAmount,
            savedAmount: ScreenshotDataHelper.goalSavedAmount,
            goalType: .vacation
        )
        return goal
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.lg) {
                        // Goal Progress Section
                        GoalProgressView(
                            goal: screenshotGoal ?? currentGoal,
                            totalSaved: totalSaved,
                            onSetGoal: {
                                showEditGoal = true
                            }
                        )
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        // Stats Row
                        HStack(spacing: SpendLessSpacing.md) {
                            StatsCard(
                                icon: "flame.fill",
                                value: "\(screenshotStreak)",
                                label: AppConstants.isScreenshotMode ? ScreenshotDataHelper.dashboardStreakLabel : "Day Streak",
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
                
                // Feeling Tempted Button (floating at bottom)
                VStack {
                    Spacer()
                    
                    FeelingTemptedView(
                        subheadText: AppConstants.isScreenshotMode ? ScreenshotDataHelper.feelingTemptedSubhead : nil
                    ) {
                        showFeelingTempted = true
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
            .sheet(isPresented: $showFeelingTempted) {
                FeelingTemptedFlowView { amount in
                    // Handle feeling tempted completion
                    celebrationAmount = amount
                    celebrationMessage = generateCelebrationMessage(for: amount)
                    showCelebration = true
                }
            }
            .sheet(isPresented: $showEditGoal) {
                EditGoalSheet(goal: currentGoal)
            }
        }
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

// MARK: - Feeling Tempted View

struct FeelingTemptedView: View {
    let subheadText: String?
    let action: () -> Void
    
    @State private var isPressed = false
    
    init(subheadText: String? = nil, action: @escaping () -> Void) {
        self.subheadText = subheadText
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.sm) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("FEELING TEMPTED")
                        .font(SpendLessFont.headline)
                    Text(subheadText ?? "Need a moment?")
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
        .accessibilityLabel("Feeling tempted button. Tap when you need a moment to pause.")
    }
}

// MARK: - Feeling Tempted Flow

struct FeelingTemptedFlowView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState

    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]
    @Query private var profiles: [UserProfile]

    let onComplete: (Decimal) -> Void

    enum Step {
        case breathing
        case dopamineMenu
        case letter
        case logging
        case celebration
    }

    @State private var currentStep: Step = .breathing
    @State private var itemName = ""
    @State private var itemAmount: Decimal = 0
    @State private var showMoneyAnimation = false
    @State private var showDopamineConfirmation = false
    @State private var selectedDopamineActivity: String = ""
    @State private var delayedTask: Task<Void, Never>?

    private var currentGoal: UserGoal? {
        activeGoals.first
    }
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var hasDopamineMenuSetup: Bool {
        profile?.hasDopamineMenuSetup ?? false
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                switch currentStep {
                case .breathing:
                    breathingStep
                case .dopamineMenu:
                    dopamineMenuStep
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
                        delayedTask?.cancel()
                        dismiss()
                    }
                }
            }
            .onDisappear {
                delayedTask?.cancel()
            }
        }
    }
    
    // MARK: - Steps
    
    private var breathingStep: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            QuickBreathingExercise {
                withAnimation {
                    navigateAfterBreathing()
                }
            }
            
            Spacer()
            
            TextButton("Skip") {
                withAnimation {
                    navigateAfterBreathing()
                }
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding()
    }
    
    private func navigateAfterBreathing() {
        // Show dopamine menu if configured, otherwise continue to letter/logging
        if hasDopamineMenuSetup {
            currentStep = .dopamineMenu
        } else if let profile = profile, let letterText = profile.futureLetterText, !letterText.isEmpty {
            currentStep = .letter
        } else {
            currentStep = .logging
        }
    }
    
    private var dopamineMenuStep: some View {
        ZStack {
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    VStack(spacing: SpendLessSpacing.sm) {
                        Text("🎯")
                            .font(.system(size: 50))
                        
                        Text("Instead of shopping, try:")
                            .font(SpendLessFont.title3)
                            .foregroundStyle(Color.spendLessTextPrimary)
                    }
                    .padding(.top, SpendLessSpacing.lg)
                    
                    // Activities List
                    if let profile {
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(Array(profile.dopamineMenuSelectedDefaults), id: \.self) { activity in
                                DopamineActivityButton(
                                    emoji: activity.emoji,
                                    text: activity.rawValue,
                                    onTap: {
                                        selectDopamineActivity(activity.rawValue)
                                    }
                                )
                            }
                            
                            ForEach(profile.dopamineMenuCustomActivities ?? [], id: \.self) { activity in
                                DopamineActivityButton(
                                    emoji: "✨",
                                    text: activity,
                                    onTap: {
                                        selectDopamineActivity(activity)
                                    }
                                )
                            }
                        }
                    }
                    
                    // Skip to logging
                    Button {
                        withAnimation {
                            navigateAfterDopamineMenu()
                        }
                    } label: {
                        Text("I still want to log something")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(.top, SpendLessSpacing.md)
                }
                .padding(SpendLessSpacing.md)
            }
            
            // Confirmation overlay
            if showDopamineConfirmation {
                dopamineConfirmationOverlay
            }
        }
    }
    
    private var dopamineConfirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.lg) {
                Text("💪")
                    .font(.system(size: 60))
                
                Text("Good choice.")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("You've got this.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .padding(SpendLessSpacing.xl)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
            .spendLessShadow(SpendLessShadow.cardShadow)
            .transition(.scale.combined(with: .opacity))
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showDopamineConfirmation)
    }
    
    private func selectDopamineActivity(_ activity: String) {
        HapticFeedback.mediumSuccess()
        selectedDopamineActivity = activity
        withAnimation {
            showDopamineConfirmation = true
        }
        
        // Dismiss after 2 seconds and close the feeling tempted flow
        delayedTask?.cancel()
        delayedTask = Task {
            try? await Task.sleep(for: .seconds(2))
            guard !Task.isCancelled else { return }
            withAnimation {
                showDopamineConfirmation = false
            }
            dismiss()
        }
    }
    
    private func navigateAfterDopamineMenu() {
        if let profile = profile, let letterText = profile.futureLetterText, !letterText.isEmpty {
            currentStep = .letter
        } else {
            currentStep = .logging
        }
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
        
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save panic button item")
        }
        
        // Sync widget data
        appState.syncWidgetData(context: modelContext)
        
        // Trigger celebration
        showMoneyAnimation = true

        delayedTask?.cancel()
        delayedTask = Task {
            try? await Task.sleep(for: .milliseconds(800))
            guard !Task.isCancelled else { return }
            withAnimation {
                currentStep = .celebration
            }
        }

        // Haptic feedback
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Dopamine Activity Button

struct DopamineActivityButton: View {
    let emoji: String
    let text: String
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(emoji)
                    .font(.system(size: 28))
                    .frame(width: 44)
                
                Text(text)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            .spendLessShadow(SpendLessShadow.subtleShadow)
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
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

