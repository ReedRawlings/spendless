//
//  NoBuySuccessAnimation.swift
//  SpendLess
//
//  Success animation for NoBuy challenge check-in
//

import SwiftUI

struct NoBuySuccessAnimation: View {
    @Binding var isShowing: Bool
    let consecutiveDays: Int
    let onDismiss: (() -> Void)?

    @State private var showContent = false
    @State private var iconScale: CGFloat = 0.5
    @State private var confettiTrigger = false
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    /// Milestone days for special celebrations
    private static let milestones: [Int] = [7, 14, 30, 60, 90, 180, 365]

    /// Encouraging messages for regular days
    private let regularMessages = [
        "You're building a better habit!",
        "Every day counts.",
        "You chose yourself today.",
        "That's how change happens.",
        "Stronger than the urge!",
        "One more day closer to your goal.",
        "You've got this!"
    ]

    init(isShowing: Binding<Bool>, consecutiveDays: Int, onDismiss: (() -> Void)? = nil) {
        self._isShowing = isShowing
        self.consecutiveDays = consecutiveDays
        self.onDismiss = onDismiss
    }

    var body: some View {
        ZStack {
            // Background
            Color.black.opacity(0.4)
                .ignoresSafeArea()
                .onTapGesture {
                    dismiss()
                }

            // Confetti
            if !reduceMotion {
                ConfettiBurst(trigger: $confettiTrigger)
            }

            // Content card
            VStack(spacing: SpendLessSpacing.lg) {
                // Success icon with glow
                ZStack {
                    // Glow effect
                    Circle()
                        .fill(
                            RadialGradient(
                                colors: [Color.spendLessGold.opacity(0.4), Color.clear],
                                center: .center,
                                startRadius: 20,
                                endRadius: 80
                            )
                        )
                        .frame(width: 140, height: 140)
                        .scaleEffect(showContent ? 1.2 : 0.8)
                        .opacity(showContent ? 1 : 0)

                    // Icon
                    Image(systemName: isMilestone ? "crown.fill" : "sparkles")
                        .font(.system(size: 50, weight: .medium))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color.spendLessGold, Color.spendLessGoldDark],
                                startPoint: .top,
                                endPoint: .bottom
                            )
                        )
                        .scaleEffect(iconScale)
                }

                // Days count
                VStack(spacing: SpendLessSpacing.xxs) {
                    if isMilestone {
                        Text(milestoneTitle)
                            .font(SpendLessFont.largeTitle)
                            .foregroundStyle(Color.spendLessGold)
                    }

                    Text(daysText)
                        .font(isMilestone ? SpendLessFont.title2 : SpendLessFont.title)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }
                .opacity(showContent ? 1 : 0)
                .scaleEffect(showContent ? 1 : 0.8)

                // Message
                Text(message)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                    .opacity(showContent ? 1 : 0)

                // Continue button
                PrimaryButton(isMilestone ? "Celebrate!" : "Keep Going") {
                    dismiss()
                }
                .padding(.top, SpendLessSpacing.sm)
                .opacity(showContent ? 1 : 0)
            }
            .padding(SpendLessSpacing.xl)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
            .padding(.horizontal, SpendLessSpacing.lg)
            .scaleEffect(showContent ? 1 : 0.9)
        }
        .onAppear {
            triggerAnimation()
        }
    }

    // MARK: - Computed Properties

    private var isMilestone: Bool {
        Self.milestones.contains(consecutiveDays)
    }

    private var milestoneTitle: String {
        switch consecutiveDays {
        case 7: return "1 Week!"
        case 14: return "2 Weeks!"
        case 30: return "1 Month!"
        case 60: return "2 Months!"
        case 90: return "3 Months!"
        case 180: return "6 Months!"
        case 365: return "1 Year!"
        default: return ""
        }
    }

    private var daysText: String {
        if consecutiveDays == 1 {
            return "1 no-buy day"
        } else {
            return "\(consecutiveDays) no-buy days"
        }
    }

    private var message: String {
        if isMilestone {
            return milestoneMessage
        } else {
            return regularMessages.randomElement() ?? regularMessages[0]
        }
    }

    private var milestoneMessage: String {
        switch consecutiveDays {
        case 7: return "A full week of mindful spending. You're proving you can do this!"
        case 14: return "Two weeks strong! New habits are forming."
        case 30: return "A whole month! You've built real self-control."
        case 60: return "60 days! This is becoming who you are."
        case 90: return "90 days! You've transformed your relationship with spending."
        case 180: return "Half a year of intentional choices. Incredible!"
        case 365: return "ONE YEAR! You're an absolute inspiration."
        default: return "Keep going!"
        }
    }

    // MARK: - Actions

    private func triggerAnimation() {
        // Haptic feedback - use NoBuy-specific patterns
        if isMilestone {
            HapticFeedback.noBuyMilestone()
        } else {
            HapticFeedback.noBuySuccess()
        }

        // Trigger confetti for milestones
        if isMilestone && !reduceMotion {
            confettiTrigger = true
        }

        // Animate icon
        withAnimation(.spring(response: 0.5, dampingFraction: 0.6)) {
            iconScale = 1.0
        }

        // Animate content
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.15)) {
            showContent = true
        }
    }

    private func dismiss() {
        withAnimation(.easeOut(duration: 0.3)) {
            showContent = false
            isShowing = false
        }
        onDismiss?()
    }
}

// MARK: - Compact Success Badge

/// A smaller inline success indicator for the calendar
struct NoBuySuccessBadge: View {
    let consecutiveDays: Int
    @State private var isAnimating = false

    var body: some View {
        HStack(spacing: SpendLessSpacing.xs) {
            Image(systemName: "flame.fill")
                .font(.system(size: 14, weight: .semibold))
                .foregroundStyle(Color.spendLessGold)
                .scaleEffect(isAnimating ? 1.1 : 1.0)

            Text("\(consecutiveDays) day streak")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .padding(.horizontal, SpendLessSpacing.sm)
        .padding(.vertical, SpendLessSpacing.xs)
        .background(Color.spendLessGold.opacity(0.1))
        .clipShape(Capsule())
        .onAppear {
            withAnimation(.easeInOut(duration: 0.5).repeatForever(autoreverses: true)) {
                isAnimating = true
            }
        }
    }
}

// MARK: - Preview

#Preview("Regular Day") {
    struct PreviewWrapper: View {
        @State private var isShowing = true

        var body: some View {
            ZStack {
                Color.spendLessBackground
                    .ignoresSafeArea()

                if isShowing {
                    NoBuySuccessAnimation(
                        isShowing: $isShowing,
                        consecutiveDays: 5
                    )
                }

                Button("Show Animation") {
                    isShowing = true
                }
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Milestone Day") {
    struct PreviewWrapper: View {
        @State private var isShowing = true

        var body: some View {
            ZStack {
                Color.spendLessBackground
                    .ignoresSafeArea()

                if isShowing {
                    NoBuySuccessAnimation(
                        isShowing: $isShowing,
                        consecutiveDays: 30
                    )
                }

                Button("Show Animation") {
                    isShowing = true
                }
            }
        }
    }

    return PreviewWrapper()
}

#Preview("Success Badge") {
    NoBuySuccessBadge(consecutiveDays: 12)
        .padding()
}
