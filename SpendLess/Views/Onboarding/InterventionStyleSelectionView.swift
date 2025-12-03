//
//  InterventionStyleSelectionView.swift
//  SpendLess
//
//  Onboarding screen for selecting preferred intervention style
//

import SwiftUI

struct InterventionStyleSelectionView: View {
    @Environment(AppState.self) private var appState
    @State private var selectedStyle: InterventionStyleOption = .fullFlow
    let onContinue: () -> Void
    
    var body: some View {
        OnboardingContainer(step: .interventionStyleSelection) {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(spacing: SpendLessSpacing.lg) {
                        // Header
                        VStack(spacing: SpendLessSpacing.sm) {
                            Text("Choose Your Intervention")
                                .font(SpendLessFont.title)
                                .foregroundStyle(Color.spendLessTextPrimary)
                            
                            Text("What would help you most when you're tempted to shop?")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, SpendLessSpacing.xl)
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        // Options
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(InterventionStyleOption.allCases) { style in
                                InterventionStyleCard(
                                    style: style,
                                    isSelected: selectedStyle == style
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedStyle = style
                                    }
                                    
                                    // Haptic feedback
                                    let generator = UIImpactFeedbackGenerator(style: .light)
                                    generator.impactOccurred()
                                }
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                    }
                }
                
                // Continue button
                VStack(spacing: SpendLessSpacing.md) {
                    PrimaryButton("Continue") {
                        saveSelectedStyle()
                        onContinue()
                    }
                }
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.xl)
                .padding(.top, SpendLessSpacing.md)
                .background(
                    LinearGradient(
                        colors: [Color.spendLessBackground.opacity(0), Color.spendLessBackground],
                        startPoint: .top,
                        endPoint: .bottom
                    )
                    .frame(height: 50)
                    .offset(y: -50),
                    alignment: .top
                )
            }
        }
    }
    
    private func saveSelectedStyle() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
        sharedDefaults?.set(selectedStyle.rawValue, forKey: "preferredInterventionStyle")
    }
}

// MARK: - Intervention Style Option

enum InterventionStyleOption: String, CaseIterable, Identifiable {
    case fullFlow = "full"
    case haltCheck = "halt"
    case quickPause = "quick"
    case breathing = "breathing"
    case goalReminder = "goal"
    
    var id: String { rawValue }
    
    static var allCases: [InterventionStyleOption] {
        [.fullFlow, .haltCheck, .quickPause, .breathing, .goalReminder]
    }
    
    var title: String {
        switch self {
        case .breathing: return "Breathing Exercise"
        case .haltCheck: return "HALT Check"
        case .goalReminder: return "Goal Reminder"
        case .quickPause: return "Quick Pause"
        case .fullFlow: return "Full Experience"
        }
    }
    
    var description: String {
        switch self {
        case .breathing:
            return "A calming 30-second breathing exercise to reset your mind"
        case .haltCheck:
            return "Check how you're really feeling"
        case .goalReminder:
            return "See your goal and commitment to stay motivated"
        case .quickPause:
            return "A moment of calm before you continue"
        case .fullFlow:
            return "Breathing + reflection + item logging (most effective)"
        }
    }
    
    var emoji: String {
        switch self {
        case .breathing: return "🌬️"
        case .haltCheck: return "✋"
        case .goalReminder: return "🎯"
        case .quickPause: return "⏸️"
        case .fullFlow: return "🛡️"
        }
    }
    
    var recommendation: String? {
        switch self {
        case .fullFlow: return "Most effective"
        case .quickPause: return "Fastest"
        case .haltCheck: return "Best for emotional shopping"
        default: return nil
        }
    }
    
}

// MARK: - Intervention Style Card

struct InterventionStyleCard: View {
    let style: InterventionStyleOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                // Emoji
                Text(style.emoji)
                    .font(.title)
                    .frame(width: 50, height: 50)
                
                // Text content
                VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                    Text(style.title)
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text(style.description)
                        .font(SpendLessFont.subheadline)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                // Selection indicator
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .foregroundStyle(isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted)
                    .font(.title2)
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .fill(isSelected ? Color.spendLessPrimary.opacity(0.1) : Color.spendLessCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .strokeBorder(isSelected ? Color.spendLessPrimary : Color.spendLessBackgroundSecondary, lineWidth: isSelected ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    InterventionStyleSelectionView {
        print("Continue")
    }
    .environment(AppState.shared)
}

