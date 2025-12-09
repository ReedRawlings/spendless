//
//  WaitingListStatsCard.swift
//  SpendLess
//
//  Collapsible stats header for the Waiting List view
//

import SwiftUI

struct WaitingListStatsCard: View {
    let stats: WaitingListStats
    let retirementValue: Decimal?
    let currentAmount: Decimal?
    @State private var isExpanded: Bool = true
    
    init(stats: WaitingListStats, retirementValue: Decimal? = nil, currentAmount: Decimal? = nil) {
        self.stats = stats
        self.retirementValue = retirementValue
        self.currentAmount = currentAmount
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Header (always visible)
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    isExpanded.toggle()
                }
            } label: {
                HStack {
                    VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                        Text("Your Patterns")
                            .font(SpendLessFont.headline)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        if !isExpanded {
                            Text(collapsedSummary)
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                    }
                    
                    Spacer()
                    
                    Image(systemName: "chevron.down")
                        .font(.body.weight(.medium))
                        .foregroundStyle(Color.spendLessTextMuted)
                        .rotationEffect(.degrees(isExpanded ? 180 : 0))
                }
                .padding(SpendLessSpacing.md)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if isExpanded {
                VStack(spacing: SpendLessSpacing.md) {
                    Divider()
                        .padding(.horizontal, SpendLessSpacing.md)
                    
                    // Main stats row
                    HStack(spacing: SpendLessSpacing.md) {
                        // Total value waiting
                        StatBox(
                            value: formatCurrency(stats.totalValueWaiting),
                            label: "waiting",
                            sublabel: "\(stats.itemCount) item\(stats.itemCount == 1 ? "" : "s")"
                        )
                        
                        Divider()
                            .frame(height: 50)
                        
                        // Purchase rate
                        if let rateText = stats.purchaseRateText {
                            StatBox(
                                value: rateText,
                                label: "buy rate",
                                sublabel: "of items added"
                            )
                        } else {
                            StatBox(
                                value: "—",
                                label: "buy rate",
                                sublabel: "not enough data"
                            )
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    // Retirement value (if available)
                    if let retirementValue = retirementValue, let currentAmount = currentAmount {
                        Divider()
                            .padding(.horizontal, SpendLessSpacing.md)
                        
                        VStack(spacing: SpendLessSpacing.xs) {
                            HStack(spacing: SpendLessSpacing.xs) {
                                Text("📈")
                                    .font(.caption)
                                Text("If you invest this instead")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                            
                            HStack(alignment: .firstTextBaseline, spacing: SpendLessSpacing.xs) {
                                Text(formatCurrency(currentAmount))
                                    .font(SpendLessFont.title3)
                                    .foregroundStyle(Color.spendLessTextPrimary)
                                
                                Image(systemName: "arrow.right")
                                    .font(.caption2)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                
                                Text(formatCurrency(retirementValue))
                                    .font(SpendLessFont.title3)
                                    .foregroundStyle(Color.spendLessPrimary)
                            }
                            
                            Text("by retirement")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.horizontal, SpendLessSpacing.md)
                    }
                    
                    // Wait time stats (if available)
                    if stats.averageWaitDaysBuy != nil || stats.averageWaitDaysBury != nil {
                        HStack(spacing: SpendLessSpacing.lg) {
                            if let buyDays = stats.averageWaitDaysBuy {
                                WaitTimeChip(
                                    icon: "cart.fill",
                                    days: buyDays,
                                    label: "avg wait to buy"
                                )
                            }
                            
                            if let buryDays = stats.averageWaitDaysBury {
                                WaitTimeChip(
                                    icon: "leaf.fill",
                                    days: buryDays,
                                    label: "avg wait to bury"
                                )
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                    }
                    
                    // Insight text
                    if stats.hasEnoughDataForStats, let insight = generateInsight() {
                        Text(insight)
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SpendLessSpacing.md)
                    }
                }
                .padding(.bottom, SpendLessSpacing.md)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.cardShadow)
    }
    
    private var collapsedSummary: String {
        if stats.itemCount == 0 {
            return "No items waiting"
        }
        return "\(formatCurrency(stats.totalValueWaiting)) across \(stats.itemCount) item\(stats.itemCount == 1 ? "" : "s")"
    }
    
    private func generateInsight() -> String? {
        guard let rate = stats.purchaseRate else { return nil }
        
        if rate < 0.2 {
            return "You resist most of what you add. Trust that instinct!"
        } else if rate < 0.4 {
            return "You're selective about what you actually buy. Nice."
        } else if rate < 0.6 {
            return "About half survives the wait. The list is doing its job."
        } else {
            return "Most items survive the wait. Consider if you're adding genuine needs."
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Stat Box

private struct StatBox: View {
    let value: String
    let label: String
    let sublabel: String?
    
    init(value: String, label: String, sublabel: String? = nil) {
        self.value = value
        self.label = label
        self.sublabel = sublabel
    }
    
    var body: some View {
        VStack(spacing: SpendLessSpacing.xxs) {
            Text(value)
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessPrimary)
            
            Text(label)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
            
            if let sublabel {
                Text(sublabel)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Wait Time Chip

private struct WaitTimeChip: View {
    let icon: String
    let days: Int
    let label: String
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.xxs) {
            Image(systemName: icon)
                .font(.caption)
                .foregroundStyle(Color.spendLessTextMuted)
            
            Text("\(days)d")
                .font(SpendLessFont.subheadline)
                .fontWeight(.semibold)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text(label)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
        }
        .padding(.horizontal, SpendLessSpacing.sm)
        .padding(.vertical, SpendLessSpacing.xxs)
        .background(Color.spendLessBackgroundSecondary)
        .clipShape(Capsule())
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        WaitingListStatsCard(
            stats: WaitingListStats(
                totalValueWaiting: 487,
                itemCount: 6,
                purchaseRate: 0.18,
                averageWaitDaysBuy: 9,
                averageWaitDaysBury: 4,
                totalBuried: 41,
                totalPurchased: 9
            )
        )
        
        WaitingListStatsCard(
            stats: WaitingListStats(
                totalValueWaiting: 0,
                itemCount: 0,
                purchaseRate: nil,
                averageWaitDaysBuy: nil,
                averageWaitDaysBury: nil,
                totalBuried: 0,
                totalPurchased: 0
            )
        )
    }
    .padding()
    .background(Color.spendLessBackground)
}

