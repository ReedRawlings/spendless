//
//  NoBuySupportSheet.swift
//  SpendLess
//
//  Supportive sheet shown when user reaches miss threshold
//

import SwiftUI

struct NoBuySupportSheet: View {
    let challenge: NoBuyChallenge
    let onPause: () -> Void
    let onReviewResources: () -> Void
    let onReset: () -> Void
    let onContinue: () -> Void

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            Capsule()
                .fill(Color.spendLessTextMuted.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, SpendLessSpacing.sm)
                .padding(.bottom, SpendLessSpacing.lg)

            ScrollView {
                VStack(spacing: SpendLessSpacing.xl) {
                    // Header
                    headerSection

                    // Options
                    optionsSection

                    // Continue anyway
                    continueSection
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .background(Color.spendLessCardBackground)
    }

    // MARK: - Header Section

    private var headerSection: some View {
        VStack(spacing: SpendLessSpacing.md) {
            // Supportive emoji
            Text("💙")
                .font(.system(size: 50))

            Text("Let's check in")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)

            Text("You've had \(challenge.missedDays) purchase days so far. That's okay—this is hard work, and every day you're learning more about yourself.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
        }
    }

    // MARK: - Options Section

    private var optionsSection: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Text("What would help right now?")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)

            // Pause option
            SupportOptionButton(
                icon: "pause.circle.fill",
                iconColor: .spendLessSecondary,
                title: "Take a break",
                description: "Pause your challenge and come back when you're ready"
            ) {
                onPause()
                dismiss()
            }

            // Review resources option
            SupportOptionButton(
                icon: "book.fill",
                iconColor: .spendLessPrimary,
                title: "Review learning tools",
                description: "Explore strategies that might help"
            ) {
                onReviewResources()
                dismiss()
            }

            // Reset option
            SupportOptionButton(
                icon: "arrow.counterclockwise.circle.fill",
                iconColor: .spendLessGold,
                title: "Start fresh",
                description: "Reset your challenge and begin again from today"
            ) {
                onReset()
                dismiss()
            }
        }
    }

    // MARK: - Continue Section

    private var continueSection: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            Button {
                onContinue()
                dismiss()
            } label: {
                Text("Keep going as is")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }

            Text("You can always change your mind later")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
        }
        .padding(.top, SpendLessSpacing.md)
    }
}

// MARK: - Support Option Button

private struct SupportOptionButton: View {
    let icon: String
    let iconColor: Color
    let title: String
    let description: String
    let action: () -> Void

    @State private var isPressed = false

    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                // Icon
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 50, height: 50)

                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundStyle(iconColor)
                }

                // Text
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)

                    Text(description)
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .lineLimit(2)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .strokeBorder(Color.spendLessTextMuted.opacity(0.2), lineWidth: 1)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
    }
}

// MARK: - Preview

#Preview {
    let challenge = NoBuyChallenge(
        startDate: Calendar.current.date(byAdding: .day, value: -5, to: Date())!,
        durationType: .oneWeek,
        offLimitCategories: [.clothing, .beauty]
    )
    challenge.missedDays = 2

    return NoBuySupportSheet(
        challenge: challenge,
        onPause: { print("Pause") },
        onReviewResources: { print("Review") },
        onReset: { print("Reset") },
        onContinue: { print("Continue") }
    )
    .presentationDetents([.medium, .large])
}
