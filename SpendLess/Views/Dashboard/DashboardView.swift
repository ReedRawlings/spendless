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
    @Query private var spendingAudits: [SpendingAudit]

    // NoBuy Challenge queries
    @Query(filter: #Predicate<NoBuyChallenge> { $0.isActive }) private var activeChallenges: [NoBuyChallenge]
    @Query private var noBuyEntries: [NoBuyDayEntry]

    @State private var showFeelingTempted = false
    @State private var showCelebration = false
    @State private var celebrationAmount: Decimal = 0
    @State private var celebrationMessage = ""
    @State private var showAnniversary: Bool = false
    @State private var anniversaryMilestone: Int = 0
    @State private var showEditGoal = false
    @State private var selectedTool: ToolType?

    // NoBuy Challenge state
    @State private var showChallengeSetup = false
    @State private var showCheckinSheet = false
    @State private var checkinDate: Date = Date()
    @State private var showRulesSheet = false
    @State private var celebratingDate: Date? = nil
    @State private var showSupportSheet = false
    @State private var showLearningLibrary = false

    // Dismissed prompts tracking
    @AppStorage("dismissedLifeEnergyPrompt") private var dismissedLifeEnergyPrompt = false
    @AppStorage("dismissedSpendingAuditPrompt") private var dismissedSpendingAuditPrompt = false
    @AppStorage("dismissedDopamineMenuPrompt") private var dismissedDopamineMenuPrompt = false

    private var currentGoal: UserGoal? {
        activeGoals.first
    }

    private var currentStreak: Streak? {
        streaks.first
    }

    private var profile: UserProfile? {
        profiles.first
    }

    // MARK: - NoBuy Challenge Properties

    private var activeChallenge: NoBuyChallenge? {
        activeChallenges.first
    }

    private var challengeEntries: [NoBuyDayEntry] {
        guard let challenge = activeChallenge else { return [] }
        return noBuyEntries.filter { $0.challengeID == challenge.id }
    }

    private var consecutiveNoBuyDays: Int {
        challengeEntries.currentStreak
    }

    private var hasActiveChallenge: Bool {
        activeChallenge != nil
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

    // MARK: - Tool Completion Status

    private var hasCompletedLifeEnergy: Bool {
        profile?.hasConfiguredLifeEnergy ?? false
    }

    private var hasCompletedSpendingAudit: Bool {
        !spendingAudits.isEmpty
    }

    private var hasCompletedDopamineMenu: Bool {
        profile?.hasDopamineMenuSetup ?? false
    }

    /// Tools that need to be set up (not completed and not dismissed)
    private var pendingToolPrompts: [ToolType] {
        var prompts: [ToolType] = []

        if !hasCompletedLifeEnergy && !dismissedLifeEnergyPrompt {
            prompts.append(.lifeEnergyCalculator)
        }
        if !hasCompletedSpendingAudit && !dismissedSpendingAuditPrompt {
            prompts.append(.spendingAudit)
        }
        if !hasCompletedDopamineMenu && !dismissedDopamineMenuPrompt {
            prompts.append(.dopamineMenu)
        }

        return prompts
    }

    /// Whether to show compact goal view (when prompts are showing)
    private var showCompactGoal: Bool {
        !pendingToolPrompts.isEmpty
    }

    var body: some View {
        NavigationStack {
            ZStack {
                // Background
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.lg) {
                        // NoBuy Challenge Layout OR Regular Layout
                        if let challenge = activeChallenge {
                            // MARK: - NoBuy Challenge Active Layout

                            // Minimized Goal Progress
                            GoalProgressView(
                                goal: screenshotGoal ?? currentGoal,
                                totalSaved: totalSaved,
                                isMinimized: true,
                                onSetGoal: {
                                    showEditGoal = true
                                }
                            )
                            .padding(.horizontal, SpendLessSpacing.md)

                            // Challenge Header with Rules Button
                            HStack {
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("NoBuy Challenge")
                                        .font(SpendLessFont.headline)
                                        .foregroundStyle(Color.spendLessTextPrimary)

                                    Text("\(challenge.daysRemaining) days remaining")
                                        .font(SpendLessFont.caption)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }

                                Spacer()

                                Button {
                                    showRulesSheet = true
                                } label: {
                                    Image(systemName: "info.circle.fill")
                                        .font(.system(size: 22))
                                        .foregroundStyle(Color.spendLessPrimary)
                                }
                            }
                            .padding(.horizontal, SpendLessSpacing.md)

                            // Calendar View
                            NoBuyCalendarView(
                                challenge: challenge,
                                entries: challengeEntries,
                                celebratingDate: $celebratingDate,
                                onDayTap: { date in
                                    checkinDate = date
                                    showCheckinSheet = true
                                }
                            )
                            .padding(.horizontal, SpendLessSpacing.md)

                            // Challenge Stats Row
                            HStack(spacing: SpendLessSpacing.md) {
                                StatsCard(
                                    icon: "checkmark.circle.fill",
                                    value: "\(challenge.successfulDays)",
                                    label: "No-Buy Days",
                                    iconColor: .spendLessSecondary
                                )

                                StatsCard(
                                    icon: "flame.fill",
                                    value: "\(consecutiveNoBuyDays)",
                                    label: "Streak",
                                    iconColor: .spendLessGold
                                )

                                StatsCard(
                                    icon: "percent",
                                    value: "\(Int(challenge.successRate * 100))%",
                                    label: "Success Rate",
                                    iconColor: .spendLessPrimary
                                )
                            }
                            .padding(.horizontal, SpendLessSpacing.md)

                            // Onboarding Tool Prompts (also show during NoBuy challenge)
                            if !pendingToolPrompts.isEmpty {
                                VStack(spacing: SpendLessSpacing.sm) {
                                    ForEach(pendingToolPrompts) { tool in
                                        OnboardingPromptCard(
                                            tool: tool,
                                            onTap: {
                                                HapticFeedback.buttonTap()
                                                selectedTool = tool
                                            },
                                            onDismiss: {
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    dismissPrompt(for: tool)
                                                }
                                            }
                                        )
                                        .transition(.asymmetric(
                                            insertion: .opacity,
                                            removal: .opacity.combined(with: .move(edge: .trailing))
                                        ))
                                    }
                                }
                                .padding(.horizontal, SpendLessSpacing.md)
                            }

                        } else {
                            // MARK: - Regular Layout (No Active Challenge)

                            // Goal Progress Section (full)
                            GoalProgressView(
                                goal: screenshotGoal ?? currentGoal,
                                totalSaved: totalSaved,
                                showFullView: !showCompactGoal,
                                onSetGoal: {
                                    showEditGoal = true
                                }
                            )
                            .padding(.horizontal, SpendLessSpacing.md)

                            // Start NoBuy Challenge Prompt
                            StartNoBuyChallengeCard {
                                showChallengeSetup = true
                            }
                            .padding(.horizontal, SpendLessSpacing.md)

                            // Onboarding Tool Prompts
                            if !pendingToolPrompts.isEmpty {
                                VStack(spacing: SpendLessSpacing.sm) {
                                    ForEach(pendingToolPrompts) { tool in
                                        OnboardingPromptCard(
                                            tool: tool,
                                            onTap: {
                                                HapticFeedback.buttonTap()
                                                selectedTool = tool
                                            },
                                            onDismiss: {
                                                withAnimation(.easeOut(duration: 0.2)) {
                                                    dismissPrompt(for: tool)
                                                }
                                            }
                                        )
                                        .transition(.asymmetric(
                                            insertion: .opacity,
                                            removal: .opacity.combined(with: .move(edge: .trailing))
                                        ))
                                    }
                                }
                                .padding(.horizontal, SpendLessSpacing.md)
                            }

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
                        }

                        // Feeling Tempted Button (at bottom of scroll view)
                        FeelingTemptedView(
                            subheadText: AppConstants.isScreenshotMode ? ScreenshotDataHelper.feelingTemptedSubhead : nil
                        ) {
                            showFeelingTempted = true
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                        .padding(.top, SpendLessSpacing.lg)

                        Spacer(minLength: SpendLessSpacing.xl)
                    }
                    .padding(.top, SpendLessSpacing.md)
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
            .sheet(isPresented: $showChallengeSetup) {
                NoBuyChallengeSetupView()
            }
            .sheet(isPresented: $showRulesSheet) {
                if let challenge = activeChallenge {
                    NoBuyChallengeRulesView(challenge: challenge)
                        .presentationDetents([.medium, .large])
                }
            }
            .sheet(isPresented: $showCheckinSheet) {
                if let challenge = activeChallenge {
                    NoBuyCheckinSheet(
                        date: checkinDate,
                        onComplete: { didMakePurchase, triggerNote in
                            handleCheckin(
                                challenge: challenge,
                                date: checkinDate,
                                didMakePurchase: didMakePurchase,
                                triggerNote: triggerNote
                            )
                        }
                    )
                    .presentationDetents([.medium])
                    .presentationDragIndicator(.hidden)
                }
            }
            .sheet(isPresented: $showSupportSheet) {
                if let challenge = activeChallenge {
                    NoBuySupportSheet(
                        challenge: challenge,
                        onPause: {
                            handlePauseChallenge(challenge)
                        },
                        onReviewResources: {
                            challenge.markSupportShown()
                            saveContext()
                            showLearningLibrary = true
                        },
                        onReset: {
                            handleResetChallenge(challenge)
                        },
                        onContinue: {
                            challenge.markSupportShown()
                            saveContext()
                        }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                }
            }
            .navigationDestination(isPresented: $showLearningLibrary) {
                LearningLibraryView()
            }
            .navigationDestination(item: $selectedTool) { tool in
                switch tool {
                case .dopamineMenu:
                    DopamineMenuView()
                case .lifeEnergyCalculator:
                    LifeEnergyCalculatorView()
                case .spendingAudit:
                    SpendingAuditView()
                default:
                    EmptyView()
                }
            }
        }
    }

    // MARK: - NoBuy Challenge Actions

    private func handleCheckin(challenge: NoBuyChallenge, date: Date, didMakePurchase: Bool, triggerNote: String?) {
        // Create the entry
        let entry = NoBuyDayEntry(
            challengeID: challenge.id,
            date: date,
            didMakePurchase: didMakePurchase,
            triggerNote: triggerNote
        )
        modelContext.insert(entry)

        // Update challenge stats
        if didMakePurchase {
            challenge.recordMiss()

            // Check if we should show support after this miss
            if challenge.shouldShowSupport {
                // Delay slightly so check-in sheet can dismiss first
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    showSupportSheet = true
                }
            }
        } else {
            challenge.recordSuccess()
            // Trigger celebration animation on the calendar
            celebratingDate = date
            // Clear celebration after animation completes
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                celebratingDate = nil
            }
        }

        // Save changes
        saveContext()
    }

    private func handlePauseChallenge(_ challenge: NoBuyChallenge) {
        challenge.pause()
        challenge.markSupportShown()
        saveContext()
        // Cancel notifications
        NotificationManager.shared.cancelNoBuyNotifications(for: challenge.id)
    }

    private func handleResetChallenge(_ challenge: NoBuyChallenge) {
        challenge.reset()
        saveContext()
        // Reschedule notifications for new end date
        NotificationManager.shared.cancelNoBuyNotifications(for: challenge.id)
        NotificationManager.shared.scheduleNoBuyDailyNotification(
            challengeID: challenge.id,
            endDate: challenge.endDate
        )
    }

    private func saveContext() {
        do {
            try modelContext.save()
        } catch {
            print("Failed to save: \(error)")
        }
    }

    private func dismissPrompt(for tool: ToolType) {
        switch tool {
        case .lifeEnergyCalculator:
            dismissedLifeEnergyPrompt = true
        case .spendingAudit:
            dismissedSpendingAuditPrompt = true
        case .dopamineMenu:
            dismissedDopamineMenuPrompt = true
        default:
            break
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

        do {
            try modelContext.save()
        } catch {
            print("❌ Failed to save graveyard item: \(error.localizedDescription)")
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

// MARK: - Start NoBuy Challenge Card

struct StartNoBuyChallengeCard: View {
    let onStart: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: onStart) {
            HStack(spacing: SpendLessSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(Color.spendLessSecondary.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: "calendar.badge.checkmark")
                        .font(.system(size: 24))
                        .foregroundStyle(Color.spendLessSecondary)
                }

                VStack(alignment: .leading, spacing: 2) {
                    Text("Start a NoBuy Challenge")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)

                    Text("Track your no-spend days with a calendar")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .strokeBorder(Color.spendLessSecondary.opacity(0.3), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
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
        .environment(InterventionManager.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self,
            SpendingAudit.self,
            AuditItem.self,
            NoBuyChallenge.self,
            NoBuyDayEntry.self
        ], inMemory: true)
}

