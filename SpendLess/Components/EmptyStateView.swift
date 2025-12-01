//
//  EmptyStateView.swift
//  SpendLess
//
//  Reusable empty state component
//

import SwiftUI

struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            IconView(icon, font: .system(size: 60))
            
            VStack(spacing: SpendLessSpacing.sm) {
                Text(title)
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text(message)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle, let action {
                PrimaryButton(actionTitle, icon: "plus") {
                    action()
                }
                .padding(.top, SpendLessSpacing.md)
            }
        }
        .padding(SpendLessSpacing.xl)
    }
}

// MARK: - Preset Empty States

extension EmptyStateView {
    static var waitingList: EmptyStateView {
        EmptyStateView(
            icon: "⏳",
            title: "Nothing here yet.",
            message: "When you resist an impulse, add it here to test if you really want it.\n\nMost things don't survive 7 days. 🪦"
        )
    }
    
    static var graveyard: EmptyStateView {
        EmptyStateView(
            icon: "🪦",
            title: "Nothing here yet.",
            message: "When you resist an impulse buy, it'll end up here — proof that you didn't need it after all.\n\nYour first burial is coming. We believe in you."
        )
    }
    
    static var noGoal: EmptyStateView {
        EmptyStateView(
            icon: "🎯",
            title: "No goal set",
            message: "Set a goal to track your progress and stay motivated."
        )
    }
}

#Preview {
    VStack(spacing: 40) {
        EmptyStateView.waitingList
        
        EmptyStateView(
            icon: "📦",
            title: "No items",
            message: "Start adding items to see them here.",
            actionTitle: "Add Item"
        ) {
            print("Add tapped")
        }
    }
    .padding()
    .background(Color.spendLessBackground)
}

