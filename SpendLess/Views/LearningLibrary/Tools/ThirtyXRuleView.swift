//
//  ThirtyXRuleView.swift
//  SpendLess
//
//  30x Rule Check - V2 placeholder
//

import SwiftUI

struct ThirtyXRuleView: View {
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            VStack(spacing: SpendLessSpacing.xl) {
                Spacer()
                
                // Icon
                Text("🔢")
                    .font(.system(size: 80))
                
                // Title
                Text("30x Rule Check")
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
                    Text("Quick test: Should you buy it?")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text("Answer three questions to decide:")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, SpendLessSpacing.xl)
                
                // Preview of questions
                VStack(spacing: SpendLessSpacing.sm) {
                    QuestionPreviewRow(question: "Will you use this at least 30 times?")
                    QuestionPreviewRow(question: "Can you match it with 5+ outfits/contexts?")
                    QuestionPreviewRow(question: "Do you have space for this?")
                }
                .padding(SpendLessSpacing.lg)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                .padding(.horizontal, SpendLessSpacing.md)
                
                Spacer()
                Spacer()
            }
        }
        .navigationTitle("30x Rule")
        .navigationBarTitleDisplayMode(.inline)
    }
}

// MARK: - Question Preview Row

struct QuestionPreviewRow: View {
    let question: String
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.md) {
            Image(systemName: "circle")
                .font(.title2)
                .foregroundStyle(Color.spendLessTextMuted)
            
            Text(question)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Spacer()
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ThirtyXRuleView()
    }
}

