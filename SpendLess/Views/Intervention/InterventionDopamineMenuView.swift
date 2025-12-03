//
//  InterventionDopamineMenuView.swift
//  SpendLess
//
//  Dopamine menu shown during intervention flow when user selects "Just Browsing"
//

import SwiftUI
import SwiftData

struct InterventionDopamineMenuView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    let onComplete: () -> Void
    
    @State private var showConfirmation = false
    @State private var selectedActivity: String = ""
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack {
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    VStack(spacing: SpendLessSpacing.sm) {
                        Text("🎯")
                            .font(.system(size: 60))
                        
                        Text("Instead of shopping, try:")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        Text("Pick something that sounds good right now")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(.top, SpendLessSpacing.xl)
                    
                    // Activities List
                    if let profile {
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(Array(profile.dopamineMenuSelectedDefaults), id: \.self) { activity in
                                InterventionActivityRow(
                                    emoji: activity.emoji,
                                    text: activity.rawValue,
                                    onTap: {
                                        selectActivity(activity.rawValue)
                                    }
                                )
                            }
                            
                            ForEach(profile.dopamineMenuCustomActivities ?? [], id: \.self) { activity in
                                InterventionActivityRow(
                                    emoji: "✨",
                                    text: activity,
                                    onTap: {
                                        selectActivity(activity)
                                    }
                                )
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                    }
                    
                    // Skip button
                    Button {
                        onComplete()
                    } label: {
                        Text("Skip for now")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(.top, SpendLessSpacing.md)
                    .padding(.bottom, SpendLessSpacing.xxl)
                }
            }
            
            // Confirmation overlay
            if showConfirmation {
                confirmationOverlay
            }
        }
    }
    
    // MARK: - Confirmation Overlay
    
    private var confirmationOverlay: some View {
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
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: showConfirmation)
    }
    
    // MARK: - Actions
    
    private func selectActivity(_ activity: String) {
        HapticFeedback.mediumSuccess()
        selectedActivity = activity
        withAnimation {
            showConfirmation = true
        }
        
        // Dismiss after 2 seconds
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation {
                showConfirmation = false
            }
            onComplete()
        }
    }
}

// MARK: - Activity Row

struct InterventionActivityRow: View {
    let emoji: String
    let text: String
    let onTap: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(emoji)
                    .font(.system(size: 32))
                    .frame(width: 50)
                
                Text(text)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.leading)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
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
    InterventionDopamineMenuView(onComplete: {})
        .modelContainer(for: [UserProfile.self], inMemory: true)
}

