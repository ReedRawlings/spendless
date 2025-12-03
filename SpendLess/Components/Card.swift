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
    let padding: CGFloat
    let action: () -> Void
    
    @State private var checkmarkTrim: CGFloat = 0
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String,
        isSelected: Bool,
        padding: CGFloat = SpendLessSpacing.md,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.isSelected = isSelected
        self.padding = padding
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                IconView(icon, font: .title2)
                    .scaleEffect(isSelected ? 1.1 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.5), value: isSelected)
                
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
                
                ZStack {
                    Circle()
                        .stroke(Color.spendLessTextMuted, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .opacity(isSelected ? 0 : 1)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.spendLessPrimary)
                            .frame(width: 24, height: 24)
                        
                        CheckmarkShape()
                            .trim(from: 0, to: checkmarkTrim)
                            .stroke(Color.white, style: StrokeStyle(lineWidth: 2, lineCap: .round, lineJoin: .round))
                            .frame(width: 12, height: 12)
                    }
                }
            }
            .padding(padding)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(isSelected ? Color.spendLessPrimaryLight.opacity(0.15) : Color.spendLessCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(isSelected ? Color.spendLessPrimary : Color.clear, lineWidth: 2)
            )
            .scaleEffect(isSelected ? 1.02 : 1.0)
            .animation(.spring(response: 0.35, dampingFraction: 0.6), value: isSelected)
        }
        .buttonStyle(.plain)
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .onChange(of: isSelected) { _, newValue in
            if newValue {
                withAnimation(.easeOut(duration: 0.25).delay(0.1)) {
                    checkmarkTrim = 1
                }
            } else {
                checkmarkTrim = 0
            }
        }
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

// MARK: - Checkmark Shape

struct CheckmarkShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.width * 0.15, y: rect.height * 0.5))
        path.addLine(to: CGPoint(x: rect.width * 0.4, y: rect.height * 0.75))
        path.addLine(to: CGPoint(x: rect.width * 0.85, y: rect.height * 0.25))
        return path
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
            
            HStack(spacing: SpendLessSpacing.md) {
                StatsCard(icon: "flame.fill", value: "18", label: "Day Streak", iconColor: .spendLessStreak)
                StatsCard(icon: "dollarsign.circle.fill", value: "$89", label: "This Week")
            }
        }
        .padding()
    }
    .background(Color.spendLessBackground)
}

