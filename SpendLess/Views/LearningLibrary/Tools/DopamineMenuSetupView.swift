//
//  DopamineMenuSetupView.swift
//  SpendLess
//
//  Setup view for configuring the Dopamine Menu
//

import SwiftUI
import SwiftData

struct DopamineMenuSetupView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    let isInitialSetup: Bool
    
    @State private var selectedActivities: Set<DopamineActivity> = []
    @State private var customActivities: [String] = []
    @State private var newCustomActivity = ""
    @State private var showAddCustom = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    init(isInitialSetup: Bool = false) {
        self.isInitialSetup = isInitialSetup
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    headerSection
                    
                    // Default activities
                    defaultActivitiesSection
                    
                    // Custom activities
                    customActivitiesSection
                    
                    // Add custom
                    addCustomSection
                    
                    // Save button
                    saveButton
                }
                .padding(SpendLessSpacing.md)
            }
        }
        .navigationTitle(isInitialSetup ? "Setup Menu" : "Edit Menu")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !isInitialSetup {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        saveAndDismiss()
                    }
                    .fontWeight(.semibold)
                    .foregroundStyle(Color.spendLessPrimary)
                }
            }
        }
        .onAppear {
            loadExistingData()
        }
        .alert("Add Activity", isPresented: $showAddCustom) {
            TextField("Activity", text: $newCustomActivity)
            Button("Cancel", role: .cancel) {
                newCustomActivity = ""
            }
            Button("Add") {
                addCustomActivity()
            }
        } message: {
            Text("What activity makes you feel good?")
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Text("🎯")
                .font(.system(size: 50))
            
            Text("When you want to shop,\nwhat else could give you that hit?")
                .font(SpendLessFont.title3)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("Select activities that feel rewarding to you")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .padding(.vertical, SpendLessSpacing.md)
    }
    
    // MARK: - Default Activities Section
    
    private var defaultActivitiesSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Text("Suggested Activities")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            VStack(spacing: SpendLessSpacing.xs) {
                ForEach(DopamineActivity.allCases) { activity in
                    ActivityCheckboxRow(
                        emoji: activity.emoji,
                        text: activity.rawValue,
                        isSelected: selectedActivities.contains(activity)
                    ) {
                        toggleActivity(activity)
                    }
                }
            }
        }
    }
    
    // MARK: - Custom Activities Section
    
    @ViewBuilder
    private var customActivitiesSection: some View {
        if !customActivities.isEmpty {
            VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                Text("Your Activities")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                VStack(spacing: SpendLessSpacing.xs) {
                    ForEach(customActivities, id: \.self) { activity in
                        CustomActivityRow(
                            text: activity,
                            onDelete: {
                                removeCustomActivity(activity)
                            }
                        )
                    }
                }
            }
        }
    }
    
    // MARK: - Add Custom Section
    
    private var addCustomSection: some View {
        Button {
            HapticFeedback.buttonTap()
            showAddCustom = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                Text("Add your own activity")
                    .font(SpendLessFont.body)
            }
            .foregroundStyle(Color.spendLessPrimary)
            .frame(maxWidth: .infinity)
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(Color.spendLessPrimary.opacity(0.1))
            )
        }
    }
    
    // MARK: - Save Button
    
    private var saveButton: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            PrimaryButton("Save My Menu", icon: "checkmark") {
                saveAndDismiss()
            }
            .disabled(selectedActivities.isEmpty && customActivities.isEmpty)
            
            if selectedActivities.isEmpty && customActivities.isEmpty {
                Text("Select at least one activity")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .padding(.top, SpendLessSpacing.md)
    }
    
    // MARK: - Actions
    
    private func loadExistingData() {
        guard let profile else { return }
        selectedActivities = profile.dopamineMenuSelectedDefaults
        customActivities = profile.dopamineMenuCustomActivities ?? []
    }
    
    private func toggleActivity(_ activity: DopamineActivity) {
        HapticFeedback.selection()
        if selectedActivities.contains(activity) {
            selectedActivities.remove(activity)
        } else {
            selectedActivities.insert(activity)
        }
    }
    
    private func addCustomActivity() {
        guard !newCustomActivity.isEmpty else { return }
        customActivities.append(newCustomActivity)
        newCustomActivity = ""
    }
    
    private func removeCustomActivity(_ activity: String) {
        HapticFeedback.buttonTap()
        customActivities.removeAll { $0 == activity }
    }
    
    private func saveAndDismiss() {
        HapticFeedback.mediumSuccess()
        
        // Get or create profile
        let targetProfile: UserProfile
        if let existing = profile {
            targetProfile = existing
        } else {
            targetProfile = UserProfile()
            modelContext.insert(targetProfile)
        }
        
        // Save selections
        targetProfile.dopamineMenuSelectedDefaults = selectedActivities
        targetProfile.dopamineMenuCustomActivities = customActivities.isEmpty ? nil : customActivities
        
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save dopamine menu setup")
        }
        dismiss()
    }
}

// MARK: - Activity Checkbox Row

struct ActivityCheckboxRow: View {
    let emoji: String
    let text: String
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                // Checkbox
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted)
                
                // Emoji
                Text(emoji)
                    .font(.system(size: 24))
                
                // Text
                Text(text)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
            }
            .padding(SpendLessSpacing.sm)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                    .fill(isSelected ? Color.spendLessPrimary.opacity(0.1) : Color.clear)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Custom Activity Row

struct CustomActivityRow: View {
    let text: String
    let onDelete: () -> Void
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.md) {
            // Custom icon
            Text("✨")
                .font(.system(size: 24))
            
            // Text
            Text(text)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Spacer()
            
            // Delete button
            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .font(.title3)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .padding(SpendLessSpacing.sm)
        .background(
            RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                .fill(Color.spendLessBackgroundSecondary)
        )
    }
}

// MARK: - Preview

#Preview("Initial Setup") {
    NavigationStack {
        DopamineMenuSetupView(isInitialSetup: true)
    }
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

#Preview("Edit Mode") {
    NavigationStack {
        DopamineMenuSetupView(isInitialSetup: false)
    }
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

