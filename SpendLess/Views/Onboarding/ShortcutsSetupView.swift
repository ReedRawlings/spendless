//
//  ShortcutsSetupView.swift
//  SpendLess
//
//  Guides users through setting up iOS Shortcuts automation
//

import SwiftUI

struct ShortcutsSetupView: View {
    @Environment(\.dismiss) private var dismiss
    let onComplete: () -> Void

    @State private var currentStep = 0

    private let steps: [ShortcutsSetupStep] = [
        ShortcutsSetupStep(
            title: "Open Shortcuts",
            description: "We'll set up an automation that opens SpendLess when you try to open shopping apps.",
            systemImage: "arrow.up.forward.app",
            action: .openShortcuts
        ),
        ShortcutsSetupStep(
            title: "Tap 'Automation'",
            description: "Find the Automation tab at the bottom of the screen.",
            systemImage: "gear",
            action: nil
        ),
        ShortcutsSetupStep(
            title: "Create New Automation",
            description: "Tap the '+' button in the top right, then select 'App'.",
            systemImage: "plus.circle",
            action: nil
        ),
        ShortcutsSetupStep(
            title: "Select Your Apps",
            description: "Choose the shopping apps you want to block. Select 'Is Opened' as the trigger.",
            systemImage: "app.badge.checkmark",
            action: nil
        ),
        ShortcutsSetupStep(
            title: "Add SpendLess Action",
            description: "Search for 'SpendLess' and select 'My SpendLess Intervention' or your preferred style.",
            systemImage: "sparkle.magnifyingglass",
            action: nil
        ),
        ShortcutsSetupStep(
            title: "Turn Off 'Ask Before Running'",
            description: "This ensures the intervention starts automatically without a prompt.",
            systemImage: "bolt.fill",
            action: nil
        )
    ]

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Step progress
                    HStack(spacing: SpendLessSpacing.xs) {
                        ForEach(0..<steps.count, id: \.self) { index in
                            Capsule()
                                .fill(index <= currentStep ? Color.spendLessPrimary : Color.spendLessBackgroundSecondary)
                                .frame(height: 4)
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.top, SpendLessSpacing.md)

                    Spacer()

                    // Current step content
                    let step = steps[currentStep]

                    VStack(spacing: SpendLessSpacing.lg) {
                        // Icon
                        ZStack {
                            Circle()
                                .fill(Color.spendLessPrimary.opacity(0.15))
                                .frame(width: 120, height: 120)

                            Image(systemName: step.systemImage)
                                .font(.system(size: 50))
                                .foregroundStyle(Color.spendLessPrimary)
                        }

                        // Text
                        VStack(spacing: SpendLessSpacing.sm) {
                            Text("Step \(currentStep + 1): \(step.title)")
                                .font(SpendLessFont.title2)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .multilineTextAlignment(.center)

                            Text(step.description)
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, SpendLessSpacing.xl)
                        }
                    }

                    Spacer()

                    // Buttons
                    VStack(spacing: SpendLessSpacing.md) {
                        if let action = step.action {
                            Button {
                                performAction(action)
                            } label: {
                                HStack(spacing: SpendLessSpacing.xs) {
                                    Text(actionButtonTitle(action))
                                    Image(systemName: "arrow.up.forward")
                                }
                                .font(SpendLessFont.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SpendLessSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                        .fill(Color.spendLessPrimary)
                                )
                            }
                        }

                        Button {
                            nextStep()
                        } label: {
                            Text(currentStep < steps.count - 1 ? "Next" : "I'm Done")
                                .font(SpendLessFont.headline)
                                .foregroundStyle(step.action == nil ? .white : Color.spendLessPrimary)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, SpendLessSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                        .fill(step.action == nil ? Color.spendLessPrimary : Color.spendLessPrimary.opacity(0.1))
                                )
                        }

                        if currentStep == 0 {
                            Button("Skip for now") {
                                dismiss()
                            }
                            .font(SpendLessFont.subheadline)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button {
                        dismiss()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                }
            }
        }
    }

    private func nextStep() {
        if currentStep < steps.count - 1 {
            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                currentStep += 1
            }
        } else {
            markShortcutsSetupComplete()
            onComplete()
            dismiss()
        }
    }

    private func performAction(_ action: ShortcutsAction) {
        switch action {
        case .openShortcuts:
            if let url = URL(string: "shortcuts://") {
                UIApplication.shared.open(url)
            }
        }
    }

    private func actionButtonTitle(_ action: ShortcutsAction) -> String {
        switch action {
        case .openShortcuts:
            return "Open Shortcuts App"
        }
    }

    private func markShortcutsSetupComplete() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        sharedDefaults?.set(true, forKey: "shortcutsSetupComplete")
    }
}

// MARK: - Supporting Types

struct ShortcutsSetupStep {
    let title: String
    let description: String
    let systemImage: String
    let action: ShortcutsAction?
}

enum ShortcutsAction {
    case openShortcuts
}

// MARK: - Preview

#Preview {
    ShortcutsSetupView(onComplete: {})
}
