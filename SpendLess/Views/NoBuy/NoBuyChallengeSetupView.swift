//
//  NoBuyChallengeSetupView.swift
//  SpendLess
//
//  Multi-step wizard for creating a NoBuy challenge
//

import SwiftUI
import SwiftData

struct NoBuyChallengeSetupView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var currentStep: Step = .duration
    @State private var selectedDuration: ChallengeDuration?
    @State private var selectedCategories: Set<NoBuyCategory> = []
    @State private var customRules: [String] = []
    @State private var newRuleText: String = ""

    private enum Step: Int, CaseIterable {
        case duration
        case categories
        case customRules
        case confirmation

        var title: String {
            switch self {
            case .duration: return "How long?"
            case .categories: return "What's off-limits?"
            case .customRules: return "Your rules"
            case .confirmation: return "Ready?"
            }
        }

        var progress: Double {
            Double(rawValue + 1) / Double(Step.allCases.count)
        }
    }

    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()

                VStack(spacing: 0) {
                    // Progress bar
                    progressBar

                    // Content
                    TabView(selection: $currentStep) {
                        durationStep
                            .tag(Step.duration)

                        categoriesStep
                            .tag(Step.categories)

                        customRulesStep
                            .tag(Step.customRules)

                        confirmationStep
                            .tag(Step.confirmation)
                    }
                    .tabViewStyle(.page(indexDisplayMode: .never))
                    .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundStyle(Color.spendLessTextSecondary)
                }
            }
        }
    }

    // MARK: - Progress Bar

    private var progressBar: some View {
        VStack(spacing: SpendLessSpacing.xs) {
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    Capsule()
                        .fill(Color.spendLessTextMuted.opacity(0.2))
                        .frame(height: 4)

                    Capsule()
                        .fill(Color.spendLessPrimary)
                        .frame(width: geometry.size.width * currentStep.progress, height: 4)
                        .animation(.easeInOut(duration: 0.3), value: currentStep)
                }
            }
            .frame(height: 4)

            Text(currentStep.title)
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
        .padding(.vertical, SpendLessSpacing.md)
    }

    // MARK: - Duration Step

    private var durationStep: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Choose your challenge length")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }

            LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpendLessSpacing.md) {
                ForEach(ChallengeDuration.allCases) { duration in
                    DurationCard(
                        duration: duration,
                        isSelected: selectedDuration == duration,
                        onTap: {
                            HapticFeedback.selection()
                            selectedDuration = duration
                        }
                    )
                }
            }

            Spacer()

            PrimaryButton("Continue") {
                withAnimation {
                    currentStep = .categories
                }
            }
            .disabled(selectedDuration == nil)
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
    }

    // MARK: - Categories Step

    private var categoriesStep: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Select categories to avoid")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)

                Text("Tap to select multiple")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }

            ScrollView {
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: SpendLessSpacing.sm) {
                    ForEach(NoBuyCategory.allCases) { category in
                        NoBuyCategoryCard(
                            category: category,
                            isSelected: selectedCategories.contains(category),
                            onTap: {
                                HapticFeedback.selection()
                                if selectedCategories.contains(category) {
                                    selectedCategories.remove(category)
                                } else {
                                    selectedCategories.insert(category)
                                }
                            }
                        )
                    }
                }
            }

            HStack(spacing: SpendLessSpacing.md) {
                SecondaryButton("Back") {
                    withAnimation {
                        currentStep = .duration
                    }
                }

                PrimaryButton("Continue") {
                    withAnimation {
                        currentStep = .customRules
                    }
                }
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
    }

    // MARK: - Custom Rules Step

    private var customRulesStep: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            VStack(spacing: SpendLessSpacing.sm) {
                Text("Add your own rules")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)

                Text("Optional but helpful for staying accountable")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }

            // Add rule input
            HStack(spacing: SpendLessSpacing.sm) {
                TextField("e.g., Wait 48 hours before buying", text: $newRuleText)
                    .font(SpendLessFont.body)
                    .padding(SpendLessSpacing.md)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(Color.spendLessTextMuted.opacity(0.3), lineWidth: 1)
                    )

                Button {
                    addRule()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(Color.spendLessPrimary)
                }
                .disabled(newRuleText.trimmingCharacters(in: .whitespaces).isEmpty)
            }

            // Current rules list
            if !customRules.isEmpty {
                ScrollView {
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(customRules, id: \.self) { rule in
                            RuleRow(rule: rule) {
                                customRules.removeAll { $0 == rule }
                            }
                        }
                    }
                }
            } else {
                VStack(spacing: SpendLessSpacing.md) {
                    Spacer()

                    Image(systemName: "list.bullet.clipboard")
                        .font(.system(size: 40))
                        .foregroundStyle(Color.spendLessTextMuted.opacity(0.5))

                    Text("No custom rules yet")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextMuted)

                    Spacer()
                }
            }

            Spacer()

            HStack(spacing: SpendLessSpacing.md) {
                SecondaryButton("Back") {
                    withAnimation {
                        currentStep = .categories
                    }
                }

                PrimaryButton(customRules.isEmpty ? "Skip" : "Continue") {
                    withAnimation {
                        currentStep = .confirmation
                    }
                }
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding(.horizontal, SpendLessSpacing.lg)
    }

    // MARK: - Confirmation Step

    private var confirmationStep: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.xl) {
                // Header
                VStack(spacing: SpendLessSpacing.md) {
                    Image(systemName: "checkmark.seal.fill")
                        .font(.system(size: 60))
                        .foregroundStyle(Color.spendLessSecondary)

                    Text("Your challenge is ready!")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }

                // Summary card
                VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                    if let duration = selectedDuration {
                        SummaryRow(
                            icon: "calendar",
                            label: "Duration",
                            value: duration.displayName
                        )
                    }

                    if !selectedCategories.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                            Label {
                                Text("Off-limits")
                                    .font(SpendLessFont.bodyBold)
                                    .foregroundStyle(Color.spendLessTextPrimary)
                            } icon: {
                                Image(systemName: "xmark.circle")
                                    .foregroundStyle(Color.spendLessPrimary)
                            }

                            FlowLayoutSimple(spacing: SpendLessSpacing.xs) {
                                ForEach(Array(selectedCategories), id: \.self) { category in
                                    Text("\(category.emoji) \(category.displayName)")
                                        .font(SpendLessFont.caption)
                                        .padding(.horizontal, SpendLessSpacing.sm)
                                        .padding(.vertical, SpendLessSpacing.xxs)
                                        .background(Color.spendLessPrimary.opacity(0.1))
                                        .clipShape(Capsule())
                                }
                            }
                        }
                    }

                    if !customRules.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                            Label {
                                Text("My rules")
                                    .font(SpendLessFont.bodyBold)
                                    .foregroundStyle(Color.spendLessTextPrimary)
                            } icon: {
                                Image(systemName: "list.bullet")
                                    .foregroundStyle(Color.spendLessSecondary)
                            }

                            ForEach(customRules, id: \.self) { rule in
                                Text("• \(rule)")
                                    .font(SpendLessFont.body)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                        }
                    }
                }
                .padding(SpendLessSpacing.lg)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))

                // Encouragement
                Text(selectedDuration?.encouragement ?? "")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .italic()
                    .multilineTextAlignment(.center)

                Spacer()
                    .frame(height: SpendLessSpacing.lg)

                HStack(spacing: SpendLessSpacing.md) {
                    SecondaryButton("Back") {
                        withAnimation {
                            currentStep = .customRules
                        }
                    }

                    PrimaryButton("Start Challenge", icon: "flag.fill") {
                        createChallenge()
                    }
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }

    // MARK: - Actions

    private func addRule() {
        let trimmed = newRuleText.trimmingCharacters(in: .whitespaces)
        guard !trimmed.isEmpty else { return }

        HapticFeedback.lightSuccess()
        customRules.append(trimmed)
        newRuleText = ""
    }

    private func createChallenge() {
        guard let duration = selectedDuration else { return }

        let challenge = NoBuyChallenge(
            startDate: Date(),
            durationType: duration,
            offLimitCategories: Array(selectedCategories),
            customRules: customRules.isEmpty ? nil : customRules
        )

        modelContext.insert(challenge)

        HapticFeedback.celebration()

        // Schedule daily notifications
        NotificationManager.shared.scheduleNoBuyDailyNotification(
            challengeID: challenge.id,
            endDate: challenge.endDate
        )

        dismiss()
    }
}

// MARK: - Duration Card

private struct DurationCard: View {
    let duration: ChallengeDuration
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: SpendLessSpacing.sm) {
                Image(systemName: duration.icon)
                    .font(.system(size: 28))
                    .foregroundStyle(isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted)

                Text(duration.displayName)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Text("\(duration.days) days")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .frame(maxWidth: .infinity)
            .padding(SpendLessSpacing.lg)
            .background(isSelected ? Color.spendLessPrimary.opacity(0.1) : Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                    .strokeBorder(
                        isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - NoBuy Category Card

private struct NoBuyCategoryCard: View {
    let category: NoBuyCategory
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.sm) {
                Text(category.emoji)
                    .font(.title2)

                Text(category.displayName)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .lineLimit(1)

                Spacer()

                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(Color.spendLessPrimary)
                }
            }
            .padding(SpendLessSpacing.md)
            .background(isSelected ? Color.spendLessPrimary.opacity(0.1) : Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(
                        isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted.opacity(0.2),
                        lineWidth: isSelected ? 2 : 1
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Rule Row

private struct RuleRow: View {
    let rule: String
    let onDelete: () -> Void

    var body: some View {
        HStack(spacing: SpendLessSpacing.sm) {
            Image(systemName: "checkmark.circle.fill")
                .foregroundStyle(Color.spendLessSecondary)

            Text(rule)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)

            Spacer()

            Button(action: onDelete) {
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
    }
}

// MARK: - Summary Row

private struct SummaryRow: View {
    let icon: String
    let label: String
    let value: String

    var body: some View {
        HStack {
            Label {
                Text(label)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessTextPrimary)
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(Color.spendLessPrimary)
            }

            Spacer()

            Text(value)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
    }
}

// MARK: - Simple Flow Layout

private struct FlowLayoutSimple: Layout {
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
    NoBuyChallengeSetupView()
}
