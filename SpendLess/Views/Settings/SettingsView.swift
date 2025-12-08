//
//  SettingsView.swift
//  SpendLess
//
//  App settings and configuration
//

import SwiftUI
import SwiftData
import FamilyControls

struct SettingsView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    @Environment(SuperwallService.self) private var superwallService
    @Environment(\.scenePhase) private var scenePhase
    
    @Query private var profiles: [UserProfile]
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]

    @Bindable var screenTimeManager = ScreenTimeManager.shared
    @State private var selection = FamilyActivitySelection()
    @State private var showAppPicker = false
    @State private var showResetConfirmation = false
    @State private var showResetOnboardingConfirmation = false
    @State private var showDeleteAnalyticsConfirmation = false
    @State private var showEditGoal = false

    private var profile: UserProfile? {
        profiles.first
    }

    private var currentGoal: UserGoal? {
        activeGoals.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                List {
                    // Blocking Section
                    Section {
                        blockedAppsRow
                    } header: {
                        Text("Blocking")
                    }
                    
                    // Goal Section
                    Section {
                        editGoalRow
                        resetSavingsRow
                    } header: {
                        Text("My Goal")
                    }
                    
                    // Graveyard Section
                    Section {
                        NavigationLink {
                            GraveyardView()
                        } label: {
                            Label("Cart Graveyard", systemImage: "leaf.fill")
                        }
                    } header: {
                        Text("Savings")
                    }
                    
                    // Tools Section
                    Section {
                        NavigationLink {
                            DopamineMenuSettingsView()
                        } label: {
                            HStack {
                                Label("Dopamine Menu", systemImage: "list.bullet.circle")
                                Spacer()
                                if profile?.hasDopamineMenuSetup == true {
                                    Text("Configured")
                                        .foregroundStyle(Color.spendLessTextMuted)
                                } else {
                                    Text("Not Set Up")
                                        .foregroundStyle(Color.spendLessTextMuted)
                                }
                            }
                        }
                        
                        NavigationLink {
                            BirthYearSettingsView()
                        } label: {
                            HStack {
                                Label("Birth Year", systemImage: "calendar")
                                Spacer()
                                if let birthYear = profile?.birthYear {
                                    Text(formatBirthYear(birthYear))
                                        .foregroundStyle(Color.spendLessTextMuted)
                                } else {
                                    Text("Not Set")
                                        .foregroundStyle(Color.spendLessTextMuted)
                                }
                            }
                        }
                    } header: {
                        Text("Tools")
                    } footer: {
                        Text("Used for Opportunity Cost Calculator and intervention alternatives")
                    }
                    
                    // Commitment Section
                    if profile?.commitmentDate != nil || profile?.futureLetterText != nil {
                        Section {
                            NavigationLink {
                                CommitmentDetailView()
                            } label: {
                                Label("View My Commitment", systemImage: "signature")
                            }
                            
                            NavigationLink {
                                EditLetterView()
                            } label: {
                                Label("Edit My Letter", systemImage: "pencil")
                            }
                            
                            if let commitmentDate = profile?.commitmentDate {
                                Text("Signed: \(formatCommitmentDate(commitmentDate))")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                
                                Text("\(daysSince(commitmentDate)) days since you committed")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                        } header: {
                            Text("MY COMMITMENT")
                        }
                    }
                    
                    // Subscription Section
                    Section {
                        if appState.subscriptionService.hasProAccess {
                            HStack {
                                Label("Pro Member", systemImage: "checkmark.seal.fill")
                                    .foregroundStyle(Color.spendLessPrimary)
                                Spacer()
                                if let expirationDate = appState.subscriptionService.expirationDate {
                                    Text("Expires: \(formatDate(expirationDate))")
                                        .font(SpendLessFont.caption)
                                        .foregroundStyle(Color.spendLessTextMuted)
                                }
                            }
                            
                            Button {
                                // Open subscription management (Apple's system UI)
                                if let url = URL(string: "https://apps.apple.com/account/subscriptions") {
                                    UIApplication.shared.open(url)
                                }
                            } label: {
                                Label("Manage Subscription", systemImage: "creditcard")
                            }
                        } else {
                            Button {
                                superwallService.register(event: "campaign_trigger")
                            } label: {
                                Label("Upgrade to Pro", systemImage: "star.fill")
                                    .foregroundStyle(Color.spendLessPrimary)
                            }
                            
                            Button {
                                Task {
                                    do {
                                        try await appState.subscriptionService.restorePurchases()
                                        // Show success feedback
                                        let generator = UINotificationFeedbackGenerator()
                                        generator.notificationOccurred(.success)
                                    } catch {
                                        print("❌ Restore failed: \(error)")
                                        // You could show an alert here
                                    }
                                }
                            } label: {
                                Label("Restore Purchases", systemImage: "arrow.clockwise")
                            }
                        }
                    } header: {
                        Text("Subscription")
                    }
                    
                    // Analytics Section
                    Section {
                        Toggle(isOn: Binding(
                            get: { ShieldAnalytics.shared.isAnalyticsEnabled },
                            set: { ShieldAnalytics.shared.isAnalyticsEnabled = $0 }
                        )) {
                            Label("Analytics", systemImage: "chart.bar")
                        }
                        
                        // Show current session status if active
                        if let session = ShieldSessionManager.shared.currentSession, session.isActive {
                            HStack {
                                Label("Active Session", systemImage: "timer")
                                Spacer()
                                Text("\(session.minutesRemaining) min remaining")
                                    .foregroundStyle(Color.spendLessTextMuted)
                            }
                            
                            Button {
                                ShieldSessionManager.shared.restoreShieldEarly()
                            } label: {
                                Label("Restore Shield Now", systemImage: "lock.shield")
                                    .foregroundStyle(Color.spendLessError)
                            }
                        }
                        
                        Button {
                            exportAnalyticsData()
                        } label: {
                            Label("Export Data", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(role: .destructive) {
                            showDeleteAnalyticsConfirmation = true
                        } label: {
                            Label("Delete All Data", systemImage: "trash")
                        }
                    } header: {
                        Text("Analytics")
                    } footer: {
                        Text("Analytics help us understand your patterns and improve the app. All data is stored locally on your device.")
                    }
                    
                    // Lead Magnet Section (only show if email not collected)
                    if profile?.leadMagnetEmailCollected != true {
                        Section {
                            NavigationLink {
                                LeadMagnetView(
                                    source: .settings,
                                    onComplete: {
                                        // View will automatically refresh when profile changes
                                    },
                                    onSkip: nil
                                )
                            } label: {
                                Label("Get Your Free Guide", systemImage: "gift.fill")
                                    .foregroundStyle(Color.spendLessPrimary)
                            }
                        } header: {
                            Text("Resources")
                        } footer: {
                            Text("Get our free Self-Compassion Guide to help you recover from spending slip-ups")
                        }
                    }
                    
                    // About Section
                    Section {
                        NavigationLink {
                            HowItWorksView()
                        } label: {
                            Label("How SpendLess Works", systemImage: "questionmark.circle")
                        }
                        
                        Link(destination: URL(string: "https://example.com/privacy")!) {
                            Label("Privacy Policy", systemImage: "lock.shield")
                        }
                        
                        Link(destination: URL(string: "https://example.com/terms")!) {
                            Label("Terms of Service", systemImage: "doc.text")
                        }
                        
                        Link(destination: URL(string: "mailto:support@spendless.app")!) {
                            Label("Contact Support", systemImage: "envelope")
                        }
                    } header: {
                        Text("About")
                    }
                    
                    // Debug Section (for development)
                    #if DEBUG
                    Section {
                        Button {
                            showResetOnboardingConfirmation = true
                        } label: {
                            Label("Reset Onboarding", systemImage: "arrow.counterclockwise")
                                .foregroundStyle(Color.spendLessError)
                        }
                        
                        Button {
                            addSampleData()
                        } label: {
                            Label("Add Sample Data", systemImage: "plus.circle")
                        }
                    } header: {
                        Text("Debug")
                    }
                    #endif
                    
                    // Version
                    Section {
                        HStack {
                            Spacer()
                            Text("Version 1.0.0")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextMuted)
                            Spacer()
                        }
                    }
                    .listRowBackground(Color.clear)
                }
                .scrollContentBackground(.hidden)
            }
            .navigationTitle("Settings")
            .familyActivityPicker(isPresented: $showAppPicker, selection: $selection)
            .onChange(of: selection) { oldValue, newValue in
                screenTimeManager.handleSelection(newValue)
            }
            .onAppear {
                selection = screenTimeManager.selection
                
                // Check subscription status when Settings opens (lazy loading)
                // This avoids showing Apple ID prompt during onboarding
                Task {
                    await appState.subscriptionService.checkSubscriptionStatus()
                }
            }
            .sheet(isPresented: $showEditGoal) {
                EditGoalSheet(goal: currentGoal)
            }
            .alert("Reset Savings?", isPresented: $showResetConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetSavings()
                }
            } message: {
                Text("This will reset your saved amount to $0. Your graveyard items will not be deleted.")
            }
            .alert("Reset Onboarding?", isPresented: $showResetOnboardingConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetOnboarding()
                }
            } message: {
                Text("This will reset the app as if you just installed it.")
            }
            .alert("Delete All Analytics Data?", isPresented: $showDeleteAnalyticsConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete", role: .destructive) {
                    deleteAnalyticsData()
                }
            } message: {
                Text("This will permanently delete all shield interaction and session data. This action cannot be undone.")
            }
        }
    }
    
    // MARK: - Rows
    
    private var blockedAppsRow: some View {
        Button {
            showAppPicker = true
        } label: {
            HStack {
                Label("Blocked Apps", systemImage: "app.badge")
                Spacer()
                Text("\(screenTimeManager.blockedAppCount) apps")
                    .foregroundStyle(Color.spendLessTextMuted)
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .foregroundStyle(Color.spendLessTextPrimary)
    }
    
    private var editGoalRow: some View {
        Button {
            showEditGoal = true
        } label: {
            HStack {
                Label("Edit Goal", systemImage: "target")
                Spacer()
                if let goal = currentGoal {
                    Text(goal.name)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .lineLimit(1)
                }
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .foregroundStyle(Color.spendLessTextPrimary)
    }
    
    private var resetSavingsRow: some View {
        Button {
            showResetConfirmation = true
        } label: {
            Label("Reset Savings", systemImage: "arrow.counterclockwise")
                .foregroundStyle(Color.spendLessError)
        }
    }
    
    // MARK: - Actions
    
    private func resetSavings() {
        if let goal = currentGoal {
            goal.resetSavings()
            try? modelContext.save()
        }
    }
    
    private func resetOnboarding() {
        appState.resetOnboarding()
        ScreenTimeManager.shared.reset()
    }
    
    private func addSampleData() {
        // Add sample goal
        let goal = UserGoal.sampleGoal
        modelContext.insert(goal)
        
        // Add sample graveyard items
        for item in GraveyardItem.sampleItems {
            modelContext.insert(item)
        }
        
        // Add sample waiting list items
        for item in WaitingListItem.sampleItems {
            modelContext.insert(item)
        }
        
        // Add sample streak
        let streak = Streak.sampleStreak
        modelContext.insert(streak)
        
        try? modelContext.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func formatCommitmentDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    private func formatBirthYear(_ year: Int) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .none
        formatter.groupingSeparator = ""
        return formatter.string(from: NSNumber(value: year)) ?? "\(year)"
    }
    
    private func exportAnalyticsData() {
        guard let data = AnalyticsManager.shared.exportData() else {
            print("Failed to export analytics data")
            return
        }
        
        // Save to temporary file and share
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("spendless-analytics-\(Date().timeIntervalSince1970).json")
        
        do {
            try data.write(to: tempURL)
            let activityVC = UIActivityViewController(activityItems: [tempURL], applicationActivities: nil)
            
            if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let rootViewController = windowScene.windows.first?.rootViewController {
                rootViewController.present(activityVC, animated: true)
            }
        } catch {
            print("Failed to write analytics data: \(error)")
        }
    }
    
    private func deleteAnalyticsData() {
        ShieldAnalytics.shared.clearAllEvents()
        ShieldAnalytics.shared.clearAllSessions()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
}

// MARK: - Edit Goal Sheet

struct EditGoalSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let goal: UserGoal?
    
    @State private var name: String = ""
    @State private var targetAmount: Decimal = 0
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    VStack(spacing: SpendLessSpacing.md) {
                        SpendLessTextField(
                            "Goal name",
                            text: $name,
                            placeholder: "e.g., Trip to Paris"
                        )
                        
                        CurrencyTextField(
                            title: "Target amount",
                            amount: $targetAmount
                        )
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.top, SpendLessSpacing.lg)
                    
                    Spacer()
                    
                    PrimaryButton("Save Changes") {
                        saveGoal()
                    }
                    .disabled(name.isEmpty || targetAmount <= 0)
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
            .navigationTitle("Edit Goal")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .onAppear {
                if let goal {
                    name = goal.name
                    targetAmount = goal.targetAmount
                }
            }
        }
    }
    
    private func saveGoal() {
        if let goal {
            goal.name = name
            goal.targetAmount = targetAmount
        } else {
            let newGoal = UserGoal(name: name, targetAmount: targetAmount)
            modelContext.insert(newGoal)
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - How It Works View

struct HowItWorksView: View {
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(alignment: .leading, spacing: SpendLessSpacing.lg) {
                    howItWorksSection(
                        icon: "1.circle.fill",
                        title: "We watch your shopping apps",
                        description: "When you try to open a blocked app, we'll step in and ask what you wanted."
                    )
                    
                    howItWorksSection(
                        icon: "2.circle.fill",
                        title: "Add items to your Waiting List",
                        description: "Something specific? Add it to your 7-day waiting list. If you still want it after a week, buy it guilt-free."
                    )
                    
                    howItWorksSection(
                        icon: "3.circle.fill",
                        title: "Bury what you don't need",
                        description: "When you realize you didn't need something, bury it in your Cart Graveyard. That money goes toward your goal."
                    )
                    
                    howItWorksSection(
                        icon: "4.circle.fill",
                        title: "Feeling Tempted",
                        description: "Feeling tempted outside the app? Tap 'Feeling Tempted' for a quick breathing exercise and log what you resisted."
                    )
                    
                    howItWorksSection(
                        icon: "5.circle.fill",
                        title: "Watch your progress",
                        description: "Track your streak, see how much you've saved, and get closer to your goal every day."
                    )
                }
                .padding(SpendLessSpacing.lg)
            }
        }
        .navigationTitle("How It Works")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func howItWorksSection(icon: String, title: String, description: String) -> some View {
        HStack(alignment: .top, spacing: SpendLessSpacing.md) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(Color.spendLessPrimary)
            
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                Text(title)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text(description)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    SettingsView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

