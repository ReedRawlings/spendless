//
//  SpendingAuditView.swift
//  SpendLess
//
//  Spending Audit / Detox Framework - V2 placeholder
//

import SwiftUI

struct SpendingAuditView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()
                
                // Icon
                Text("📊")
                    .font(.system(size: 80))
                
                // Title
                Text("Spending Audit")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                // Coming Soon Badge
                Text("Coming Soon")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.vertical, SpendLessSpacing.sm)
                    .background(Color.spendLessPrimary)
                    .clipShape(Capsule())
                
                // Description
                VStack(spacing: SpendLessSpacing.md) {
                    Text("Audit your recurring spending")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text("Based on the Beauty Detox Framework")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, SpendLessSpacing.xl)
                
                // Preview of steps
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    AuditStepPreview(number: 1, title: "List", description: "Enter recurring expenses")
                    AuditStepPreview(number: 2, title: "Annualize", description: "See yearly totals")
                    AuditStepPreview(number: 3, title: "Contextualize", description: "View as % of income")
                    AuditStepPreview(number: 4, title: "Rank", description: "Order by importance")
                    AuditStepPreview(number: 5, title: "Test", description: "Remove from bottom up")
                }
                .padding(SpendLessSpacing.lg)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                .padding(.horizontal, SpendLessSpacing.md)
                
                Spacer()
                Spacer()
            }
        }
        .navigationTitle("Spending Audit")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Audit Step Preview

struct AuditStepPreview: View {
    let number: Int
    let title: String
    let description: String
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.md) {
            // Step number
            Text("\(number)")
                .font(SpendLessFont.headline)
                .foregroundStyle(.white)
                .frame(width: 28, height: 28)
                .background(Color.spendLessTextMuted)
                .clipShape(Circle())
            
            // Content
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text(description)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SpendingAuditView()
    }
}

