//
//  DopamineMenuView.swift
//  SpendLess
//
//  Dopamine Menu tool - healthy alternatives when shopping urges hit
//

import SwiftUI
import SwiftData

struct DopamineMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    
    @State private var showSetup = false
    @State private var showConfirmation = false
    @State private var selectedActivity: String = ""
    @State private var showAddCustom = false
    @State private var customActivityText = ""
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var needsSetup: Bool {
        guard let profile else { return true }
        return !profile.hasDopamineMenuSetup
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            if needsSetup {
                // Redirect to setup if not configured
                DopamineMenuSetupView(isInitialSetup: true)
            } else {
                mainContent
            }
            
            // Confirmation overlay
            if showConfirmation {
                confirmationOverlay
            }
        }
        .navigationTitle("Dopamine Menu")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showSetup) {
            NavigationStack {
                DopamineMenuSetupView(isInitialSetup: false)
            }
        }
        .alert("Add Activity", isPresented: $showAddCustom) {
            TextField("Activity", text: $customActivityText)
            Button("Cancel", role: .cancel) {
                customActivityText = ""
            }
            Button("Add") {
                addCustomActivity()
            }
        } message: {
            Text("What activity helps you feel good?")
        }
    }
    
    // MARK: - Main Content
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Header
                headerSection
                
                // Activities List
                activitiesSection
                
                // Add custom button
                addCustomButton
                
                // Edit button
                editButton
            }
            .padding(SpendLessSpacing.md)
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            Text("🎯")
                .font(.system(size: 50))
            
            Text("Instead of shopping, try:")
                .font(SpendLessFont.title3)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, SpendLessSpacing.md)
    }
    
    // MARK: - Activities Section
    
    private var activitiesSection: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            // Default activities
            if let profile {
                ForEach(Array(profile.dopamineMenuSelectedDefaults), id: \.self) { activity in
                    ActivityRow(
                        emoji: activity.emoji,
                        text: activity.rawValue,
                        onTap: {
                            selectActivity(activity.rawValue)
                        }
                    )
                }
                
                // Custom activities
                ForEach(profile.dopamineMenuCustomActivities ?? [], id: \.self) { activity in
                    ActivityRow(
                        emoji: "✨",
                        text: activity,
                        onTap: {
                            selectActivity(activity)
                        }
                    )
                }
            }
        }
    }
    
    // MARK: - Add Custom Button
    
    private var addCustomButton: some View {
        Button {
            HapticFeedback.buttonTap()
            showAddCustom = true
        } label: {
            HStack {
                Image(systemName: "plus.circle.dashed")
                    .font(.title2)
                Text("Add your own")
                    .font(SpendLessFont.body)
            }
            .foregroundStyle(Color.spendLessPrimary)
            .frame(maxWidth: .infinity)
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(Color.spendLessPrimary.opacity(0.3), style: StrokeStyle(lineWidth: 2, dash: [8, 4]))
            )
        }
    }
    
    // MARK: - Edit Button
    
    private var editButton: some View {
        Button {
            HapticFeedback.buttonTap()
            showSetup = true
        } label: {
            Text("Edit My List")
                .font(SpendLessFont.bodyBold)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .padding(.top, SpendLessSpacing.md)
    }
    
    // MARK: - Confirmation Overlay
    
    private var confirmationOverlay: some View {
        ZStack {
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismissConfirmation()
                }
            
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showConfirmation)
    }
    
    // MARK: - Actions
    
    private func selectActivity(_ activity: String) {
        HapticFeedback.mediumSuccess()
        selectedActivity = activity
        withAnimation {
            showConfirmation = true
        }
        
        // Auto-dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            dismissConfirmation()
        }
    }
    
    private func dismissConfirmation() {
        withAnimation {
            showConfirmation = false
        }
    }
    
    private func addCustomActivity() {
        guard !customActivityText.isEmpty, let profile else { return }
        if profile.dopamineMenuCustomActivities == nil {
            profile.dopamineMenuCustomActivities = []
        }
        profile.dopamineMenuCustomActivities?.append(customActivityText)
        try? modelContext.save()
        customActivityText = ""
    }
}

// MARK: - Activity Row

struct ActivityRow: View {
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
    NavigationStack {
        DopamineMenuView()
    }
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

