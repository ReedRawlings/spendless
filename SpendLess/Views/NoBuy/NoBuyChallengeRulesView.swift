//
//  NoBuyChallengeRulesView.swift
//  SpendLess
//
//  Popover/sheet showing active challenge rules
//

import SwiftUI

struct NoBuyChallengeRulesView: View {
    let challenge: NoBuyChallenge
    @Environment(\.dismiss) private var dismiss

    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        return formatter
    }()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: SpendLessSpacing.lg) {
                    // Challenge period
                    periodSection

                    // Progress stats
                    progressSection

                    // Off-limits categories
                    if !challenge.offLimitCategories.isEmpty {
                        categoriesSection
                    }

                    // Custom rules
                    if let customRules = challenge.customRules, !customRules.isEmpty {
                        customRulesSection(customRules)
                    }
                }
                .padding(SpendLessSpacing.lg)
            }
            .background(Color.spendLessBackground)
            .navigationTitle("My Challenge")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
                }
            }
        }
    }

    // MARK: - Period Section

    private var periodSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Label {
                Text("Challenge Period")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
            } icon: {
                Image(systemName: "calendar")
                    .foregroundStyle(Color.spendLessPrimary)
            }

            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                HStack {
                    Text("Duration:")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    Spacer()
                    Text(challenge.durationType.displayName)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }

                HStack {
                    Text("Ends:")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    Spacer()
                    Text(dateFormatter.string(from: challenge.endDate))
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
    }

    // MARK: - Progress Section

    private var progressSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Label {
                Text("Progress")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
            } icon: {
                Image(systemName: "chart.bar.fill")
                    .foregroundStyle(Color.spendLessGold)
            }

            HStack(spacing: SpendLessSpacing.md) {
                // Success days
                StatBox(
                    value: "\(challenge.successfulDays)",
                    label: "No-Buy Days",
                    color: Color.spendLessSecondary
                )

                // Missed days
                StatBox(
                    value: "\(challenge.missedDays)",
                    label: "Purchases",
                    color: Color.spendLessTextMuted
                )

                // Days remaining
                StatBox(
                    value: "\(challenge.daysRemaining)",
                    label: "Days Left",
                    color: Color.spendLessPrimary
                )
            }
        }
    }

    // MARK: - Categories Section

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Label {
                Text("Off-Limits Categories")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
            } icon: {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.spendLessPrimary)
            }

            NoBuyFlowLayout(spacing: SpendLessSpacing.xs) {
                ForEach(challenge.offLimitCategories) { category in
                    CategoryChip(category: category)
                }
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
    }

    // MARK: - Custom Rules Section

    private func customRulesSection(_ rules: [String]) -> some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Label {
                Text("My Rules")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
            } icon: {
                Image(systemName: "list.bullet")
                    .foregroundStyle(Color.spendLessSecondary)
            }

            VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                ForEach(rules, id: \.self) { rule in
                    HStack(alignment: .top, spacing: SpendLessSpacing.sm) {
                        Image(systemName: "checkmark.circle.fill")
                            .font(.system(size: 14))
                            .foregroundStyle(Color.spendLessSecondary)
                            .padding(.top, 2)

                        Text(rule)
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextPrimary)

                        Spacer()
                    }
                }
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
    }
}

// MARK: - Stat Box

private struct StatBox: View {
    let value: String
    let label: String
    let color: Color

    var body: some View {
        VStack(spacing: SpendLessSpacing.xxs) {
            Text(value)
                .font(SpendLessFont.title)
                .foregroundStyle(color)

            Text(label)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
    }
}

// MARK: - Category Chip

private struct CategoryChip: View {
    let category: NoBuyCategory

    var body: some View {
        HStack(spacing: SpendLessSpacing.xxs) {
            Text(category.emoji)
                .font(.system(size: 14))

            Text(category.displayName)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
        .padding(.horizontal, SpendLessSpacing.sm)
        .padding(.vertical, SpendLessSpacing.xs)
        .background(Color.spendLessPrimary.opacity(0.1))
        .clipShape(Capsule())
    }
}

// MARK: - Flow Layout

private struct NoBuyFlowLayout: Layout {
    var spacing: CGFloat = 8

    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let result = FlowResult(in: proposal.width ?? 0, subviews: subviews, spacing: spacing)
        return result.size
    }

    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        let result = FlowResult(in: bounds.width, subviews: subviews, spacing: spacing)
        for (index, subview) in subviews.enumerated() {
            subview.place(at: CGPoint(x: bounds.minX + result.positions[index].x,
                                       y: bounds.minY + result.positions[index].y),
                          proposal: .unspecified)
        }
    }

    private struct FlowResult {
        var size: CGSize = .zero
        var positions: [CGPoint] = []

        init(in width: CGFloat, subviews: Subviews, spacing: CGFloat) {
            var x: CGFloat = 0
            var y: CGFloat = 0
            var rowHeight: CGFloat = 0

            for subview in subviews {
                let size = subview.sizeThatFits(.unspecified)

                if x + size.width > width && x > 0 {
                    x = 0
                    y += rowHeight + spacing
                    rowHeight = 0
                }

                positions.append(CGPoint(x: x, y: y))
                rowHeight = max(rowHeight, size.height)
                x += size.width + spacing

                self.size.width = max(self.size.width, x)
            }

            self.size.height = y + rowHeight
        }
    }
}

// MARK: - Preview

#Preview {
    let challenge = NoBuyChallenge(
        startDate: Calendar.current.date(byAdding: .day, value: -10, to: Date())!,
        durationType: .oneMonth,
        offLimitCategories: [.clothing, .beauty, .electronics, .coffee],
        customRules: [
            "No impulse buys under $20",
            "Wait 48 hours before any purchase",
            "Only buy things on my pre-approved list"
        ]
    )
    challenge.successfulDays = 8
    challenge.missedDays = 2

    return NoBuyChallengeRulesView(challenge: challenge)
}
