//
//  Card.swift
//  SpendLess
//
//  Reusable card component with warm styling
//

import SwiftUI

// MARK: - Icon View Helper

/// A view that intelligently renders either an SF Symbol or an emoji
struct IconView: View {
    let icon: String
    let font: Font
    let foregroundColor: Color?
    
    init(_ icon: String, font: Font = .title2, foregroundColor: Color? = nil) {
        self.icon = icon
        self.font = font
        self.foregroundColor = foregroundColor
    }
    
    var body: some View {
        Group {
            if icon.contains(".") {
                // SF Symbol (contains a dot)
                Image(systemName: icon)
                    .font(font)
                    .foregroundStyle(foregroundColor ?? Color.spendLessTextPrimary)
            } else {
                // Emoji
                Text(icon)
                    .font(font)
            }
        }
    }
}

struct Card<Content: View>: View {
    let content: Content
    let padding: CGFloat
    
    init(padding: CGFloat = SpendLessSpacing.md, @ViewBuilder content: () -> Content) {
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .spendLessShadow(SpendLessShadow.cardShadow)
    }
}

// MARK: - Interactive Card

struct InteractiveCard<Content: View>: View {
    let content: Content
    let action: () -> Void
    
    init(action: @escaping () -> Void, @ViewBuilder content: () -> Content) {
        self.action = action
        self.content = content()
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            content
                .padding(SpendLessSpacing.md)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                .spendLessShadow(SpendLessShadow.cardShadow)
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Selection Card (for onboarding)

struct SelectionCard: View {
    let title: String
    let subtitle: String?
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        isSelected: Bool,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                IconView(icon, font: .title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    if let subtitle {
                        Text(subtitle)
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                }
                
                Spacer()
                
                Image(systemName: isSelected ? "checkmark.circle.fill" : "circle")
                    .font(.title2)
                    .foregroundStyle(isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted)
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(Color.spendLessCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(
                                isSelected ? Color.spendLessPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .spendLessShadow(SpendLessShadow.subtleShadow)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

// MARK: - Difficulty Mode Card

struct DifficultyModeCard: View {
    let mode: DifficultyMode
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                HStack {
                    IconView(mode.icon, font: .title)
                    
                    Text(mode.displayName.uppercased())
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Spacer()
                    
                    if isSelected {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.spendLessPrimary)
                    }
                }
                
                Text(mode.description)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
                
                Text(mode.detailedDescription)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.leading)
            }
            .padding(SpendLessSpacing.md)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .fill(Color.spendLessCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                            .strokeBorder(
                                isSelected ? Color.spendLessPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
            .spendLessShadow(SpendLessShadow.cardShadow)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Stats Card

struct StatsCard: View {
    let icon: String
    let value: String
    let label: String
    let iconColor: Color
    
    init(icon: String, value: String, label: String, iconColor: Color = .spendLessPrimary) {
        self.icon = icon
        self.value = value
        self.label = label
        self.iconColor = iconColor
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xs) {
            Image(systemName: icon)
                .font(.title2)
                .foregroundStyle(iconColor)
            
            Text(value)
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text(label)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        .spendLessShadow(SpendLessShadow.subtleShadow)
    }
}

// MARK: - Preview

#Preview {
    ScrollView {
        VStack(spacing: 20) {
            Card {
                VStack(alignment: .leading, spacing: 8) {
                    Text("Basic Card")
                        .font(SpendLessFont.headline)
                    Text("This is a basic card with some content inside.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
            }
            
            SelectionCard(
                title: "I shop when I'm bored",
                subtitle: "Common trigger",
                icon: "🛒",
                isSelected: true
            ) {}
            
            SelectionCard(
                title: "I can't resist a sale",
                icon: "🏷️",
                isSelected: false
            ) {}
            
            DifficultyModeCard(mode: .gentle, isSelected: false) {}
            DifficultyModeCard(mode: .firm, isSelected: true) {}
            
            HStack(spacing: SpendLessSpacing.md) {
                StatsCard(icon: "flame.fill", value: "18", label: "Day Streak", iconColor: .spendLessStreak)
                StatsCard(icon: "dollarsign.circle.fill", value: "$89", label: "This Week")
            }
        }
        .padding()
    }
    .background(Color.spendLessBackground)
}

