//
//  NoBuyCheckinSheet.swift
//  SpendLess
//
//  Daily check-in sheet for NoBuy challenge
//

import SwiftUI

struct NoBuyCheckinSheet: View {
    let date: Date
    let onComplete: (Bool, String?) -> Void

    @Environment(\.dismiss) private var dismiss
    @State private var step: Step = .question
    @State private var triggerNote: String = ""
    @FocusState private var isTextFieldFocused: Bool

    private enum Step {
        case question
        case triggerCapture
        case logged
    }

    private var dateString: String {
        if Calendar.current.isDateInToday(date) {
            return "today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            return formatter.string(from: date)
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Handle bar
            handleBar

            switch step {
            case .question:
                questionView
            case .triggerCapture:
                triggerCaptureView
            case .logged:
                loggedView
            }
        }
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.xl))
    }

    // MARK: - Handle Bar

    private var handleBar: some View {
        VStack(spacing: 0) {
            Capsule()
                .fill(Color.spendLessTextMuted.opacity(0.3))
                .frame(width: 36, height: 5)
                .padding(.top, SpendLessSpacing.sm)
                .padding(.bottom, SpendLessSpacing.md)
        }
    }

    // MARK: - Question View

    private var questionView: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            // Question
            VStack(spacing: SpendLessSpacing.sm) {
                Text("How did \(dateString) go?")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Did you make any purchases?")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }

            // Answer buttons
            HStack(spacing: SpendLessSpacing.md) {
                // No purchase button
                Button {
                    handleNoPurchase()
                } label: {
                    VStack(spacing: SpendLessSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.spendLessSecondary)

                        Text("No purchases!")
                            .font(SpendLessFont.bodyBold)
                            .foregroundStyle(Color.spendLessTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(SpendLessSpacing.lg)
                    .background(Color.spendLessSecondary.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                            .strokeBorder(Color.spendLessSecondary.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("No purchases")
                .accessibilityHint("Double tap to record a successful no-spend day")

                // Yes purchase button
                Button {
                    handleYesPurchase()
                } label: {
                    VStack(spacing: SpendLessSpacing.sm) {
                        Image(systemName: "cart.fill")
                            .font(.system(size: 40))
                            .foregroundStyle(Color.spendLessTextMuted)

                        Text("Made a purchase")
                            .font(SpendLessFont.bodyBold)
                            .foregroundStyle(Color.spendLessTextPrimary)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(SpendLessSpacing.lg)
                    .background(Color.spendLessTextMuted.opacity(0.1))
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                            .strokeBorder(Color.spendLessTextMuted.opacity(0.3), lineWidth: 1)
                    )
                }
                .buttonStyle(.plain)
                .accessibilityLabel("Made a purchase")
                .accessibilityHint("Double tap to record that you made a purchase today")
            }

            Spacer()
                .frame(height: SpendLessSpacing.lg)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
        .padding(.bottom, SpendLessSpacing.xl)
    }

    // MARK: - Trigger Capture View

    private var triggerCaptureView: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            // Header
            VStack(spacing: SpendLessSpacing.sm) {
                Text("That's okay")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Text("Every day is a new chance.\nWant to share what triggered it?")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }

            // Text field
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                TextField("What triggered the purchase? (optional)", text: $triggerNote, axis: .vertical)
                    .font(SpendLessFont.body)
                    .lineLimit(3...5)
                    .padding(SpendLessSpacing.md)
                    .background(Color.spendLessBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(Color.spendLessTextMuted.opacity(0.3), lineWidth: 1)
                    )
                    .focused($isTextFieldFocused)

                Text("Understanding triggers helps you resist next time")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }

            // Buttons
            VStack(spacing: SpendLessSpacing.sm) {
                PrimaryButton("Save") {
                    completePurchaseEntry()
                }

                Button("Skip") {
                    triggerNote = ""
                    completePurchaseEntry()
                }
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            }

            Spacer()
                .frame(height: SpendLessSpacing.md)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
        .padding(.bottom, SpendLessSpacing.xl)
        .onAppear {
            // Slight delay before focusing
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                isTextFieldFocused = true
            }
        }
    }

    // MARK: - Logged View (for purchases)

    private var loggedView: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()

            // Success message
            VStack(spacing: SpendLessSpacing.md) {
                Image(systemName: "sparkles")
                    .font(.system(size: 50))
                    .foregroundStyle(Color.spendLessGold)

                Text("Logged!")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Text("Every bit of awareness helps.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }

            Spacer()

            PrimaryButton("Done") {
                dismiss()
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
    }

    // MARK: - Actions

    private func handleNoPurchase() {
        // Notify parent and dismiss - calendar will handle celebration
        onComplete(false, nil)
        dismiss()
    }

    private func handleYesPurchase() {
        HapticFeedback.selection()

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            step = .triggerCapture
        }
    }

    private func completePurchaseEntry() {
        HapticFeedback.noBuyCheckin()

        onComplete(true, triggerNote.isEmpty ? nil : triggerNote)

        withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
            step = .logged
        }
    }
}

// MARK: - Preview

#Preview("Question") {
    NoBuyCheckinSheet(
        date: Date(),
        onComplete: { didPurchase, note in
            print("Did purchase: \(didPurchase), note: \(note ?? "none")")
        }
    )
    .presentationDetents([.medium])
}

#Preview("With Trigger Capture") {
    struct PreviewWrapper: View {
        @State private var showSheet = true

        var body: some View {
            Color.spendLessBackground
                .sheet(isPresented: $showSheet) {
                    NoBuyCheckinSheet(
                        date: Date(),
                        onComplete: { _, _ in }
                    )
                    .presentationDetents([.medium, .large])
                    .presentationDragIndicator(.hidden)
                }
        }
    }

    return PreviewWrapper()
}
