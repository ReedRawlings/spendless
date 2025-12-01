//
//  SecondaryButton.swift
//  SpendLess
//
//  Secondary/outlined button style
//

import SwiftUI

struct SecondaryButton: View {
    let title: String
    let icon: String?
    let isDestructive: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    private var foregroundColor: Color {
        isDestructive ? .spendLessError : .spendLessPrimary
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.medium))
                }
                Text(title)
                    .font(SpendLessFont.bodyBold)
            }
            .foregroundStyle(foregroundColor)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(foregroundColor, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
        .accessibilityLabel(title)
    }
}

// MARK: - Text Button (no border)

struct TextButton: View {
    let title: String
    let icon: String?
    let isDestructive: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
    
    private var foregroundColor: Color {
        isDestructive ? .spendLessError : .spendLessPrimary
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.body.weight(.medium))
                }
                Text(title)
                    .font(SpendLessFont.bodyBold)
            }
            .foregroundStyle(foregroundColor)
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Small Secondary Button

struct SmallSecondaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.medium))
                }
                Text(title)
                    .font(SpendLessFont.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundStyle(Color.spendLessPrimary)
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.vertical, SpendLessSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                    .strokeBorder(Color.spendLessPrimary, lineWidth: 1.5)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        SecondaryButton("Maybe Later") {
            print("Tapped")
        }
        
        SecondaryButton("Add to List", icon: "plus") {
            print("Tapped")
        }
        
        SecondaryButton("Delete", icon: "trash", isDestructive: true) {
            print("Tapped")
        }
        
        TextButton("Skip for now") {
            print("Tapped")
        }
        
        TextButton("Remove", icon: "xmark", isDestructive: true) {
            print("Tapped")
        }
        
        SmallSecondaryButton("Still want it", icon: "heart") {
            print("Small tap")
        }
    }
    .padding()
    .background(Color.spendLessBackground)
}

