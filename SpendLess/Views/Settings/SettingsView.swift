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
    @Environment(\.scenePhase) private var scenePhase
    
    @Query private var profiles: [UserProfile]
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]

    @Bindable var screenTimeManager = ScreenTimeManager.shared
    @State private var selection = FamilyActivitySelection()
    @State private var showAppPicker = false
    @State private var showResetConfirmation = false
    @State private var showResetOnboardingConfirmation = false
    @State private var showEditGoal = false
    @State private var currentInterventionStyleText: String = "Full"

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
                        interventionStyleRow
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
                                    Text("\(birthYear)")
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
                updateInterventionStyle()
            }
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("InterventionStyleDidChange"))) { _ in
                updateInterventionStyle()
            }
            .onChange(of: scenePhase) { oldPhase, newPhase in
                if newPhase == .active {
                    updateInterventionStyle()
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
    
    private var interventionStyleRow: some View {
        NavigationLink {
            InterventionStyleSettingView()
        } label: {
            HStack {
                Label("Intervention Style", systemImage: "sparkles")
                Spacer()
                Text(currentInterventionStyleText)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
    }
    
    private func updateInterventionStyle() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        let styleString = sharedDefaults?.string(forKey: "preferredInterventionStyle") ?? "full"
        
        switch styleString {
        case "breathing": currentInterventionStyleText = "Breathing"
        case "halt": currentInterventionStyleText = "HALT Check"
        case "goal": currentInterventionStyleText = "Goal Reminder"
        case "quick": currentInterventionStyleText = "Quick Pause"
        default: currentInterventionStyleText = "Full"
        }
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
                        title: "Hit the Panic Button",
                        description: "Feeling tempted outside the app? Hit the panic button for a quick breathing exercise and log what you resisted."
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

