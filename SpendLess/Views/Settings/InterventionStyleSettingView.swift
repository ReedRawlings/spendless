//
//  InterventionStyleSettingView.swift
//  SpendLess
//
//  Settings view to change preferred intervention style
//

import SwiftUI

struct InterventionStyleSettingView: View {
    @State private var selectedStyle: InterventionStyleOption = .fullFlow
    @State private var showPreview = false
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    VStack(spacing: SpendLessSpacing.xs) {
                        Text("When you try to open a shopping app")
                            .font(SpendLessFont.subheadline)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(.top, SpendLessSpacing.md)
                    
                    // Options
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(InterventionStyleOption.allCases) { style in
                            InterventionStyleSettingCard(
                                style: style,
                                isSelected: selectedStyle == style
                            ) {
                                selectStyle(style)
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    // Preview button
                    VStack(spacing: SpendLessSpacing.xs) {
                        Divider()
                            .padding(.vertical, SpendLessSpacing.md)
                        
                        Button {
                            testIntervention()
                        } label: {
                            HStack(spacing: SpendLessSpacing.xs) {
                                Image(systemName: "play.circle.fill")
                                    .font(.title2)
                                Text("Preview This Intervention")
                                    .font(SpendLessFont.headline)
                            }
                            .foregroundStyle(Color.spendLessPrimary)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, SpendLessSpacing.md)
                            .background(
                                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                    .fill(Color.spendLessPrimary.opacity(0.1))
                            )
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        Text("This determines what you'll see when a Shortcut automation triggers SpendLess.")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SpendLessSpacing.lg)
                    }
                }
            }
        }
        .navigationTitle("Intervention Style")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            loadCurrentStyle()
        }
    }
    
    private func loadCurrentStyle() {
        let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
        if let styleString = sharedDefaults?.string(forKey: "preferredInterventionStyle"),
           let style = InterventionStyleOption(rawValue: styleString) {
            selectedStyle = style
        }
    }
    
    private func selectStyle(_ style: InterventionStyleOption) {
        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
            selectedStyle = style
        }
        
        // Save to UserDefaults
        let sharedDefaults = UserDefaults(suiteName: "group.com.spendless.data")
        sharedDefaults?.set(style.rawValue, forKey: "preferredInterventionStyle")
        sharedDefaults?.synchronize()
        
        // Post notification to update other views
        NotificationCenter.default.post(name: NSNotification.Name("InterventionStyleDidChange"), object: nil)
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func testIntervention() {
        // Trigger the intervention flow to preview it
        let interventionType = InterventionManager.InterventionTypeValue(rawValue: selectedStyle.rawValue) ?? .fullFlow
        InterventionManager.shared.triggerIntervention(type: interventionType)
    }
}

// MARK: - Intervention Style Setting Card

struct InterventionStyleSettingCard: View {
    let style: InterventionStyleOption
    let isSelected: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                // Emoji
                Text(style.emoji)
                    .font(.title2)
                    .frame(width: 44, height: 44)
                    .background(
                        RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                            .fill(isSelected ? Color.spendLessPrimary.opacity(0.2) : Color.spendLessBackgroundSecondary)
                    )
                
                // Content
                VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                    HStack {
                        Text(style.title)
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        if let recommendation = style.recommendation {
                            Text(recommendation)
                                .font(SpendLessFont.caption2)
                                .fontWeight(.medium)
                                .foregroundStyle(Color.spendLessPrimary)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.spendLessPrimary.opacity(0.15))
                                .clipShape(RoundedRectangle(cornerRadius: 4))
                        }
                    }
                    
                    Text(style.description)
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .lineLimit(2)
                }
                
                Spacer()
                
                // Checkmark
                if isSelected {
                    Image(systemName: "checkmark")
                        .foregroundStyle(Color.spendLessPrimary)
                        .fontWeight(.semibold)
                }
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(Color.spendLessCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(isSelected ? Color.spendLessPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        InterventionStyleSettingView()
    }
}

