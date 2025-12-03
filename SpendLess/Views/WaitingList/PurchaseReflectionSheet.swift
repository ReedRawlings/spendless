//
//  PurchaseReflectionSheet.swift
//  SpendLess
//
//  Sheet for capturing reflection when user decides to buy an item
//

import SwiftUI

struct PurchaseReflectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: WaitingListItem
    let onConfirm: (PurchaseFeeling?) -> Void
    
    @State private var selectedFeeling: PurchaseFeeling?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    VStack(spacing: SpendLessSpacing.sm) {
                        Text("🛍️")
                            .font(.system(size: 50))
                        
                        Text("You waited \(item.daysWaited) days")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessPrimary)
                        
                        Text("Quick reflection before you go:")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(.top, SpendLessSpacing.xl)
                    
                    // Item being purchased
                    Card {
                        HStack {
                            Text(item.name)
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                            
                            Spacer()
                            
                            Text(formatCurrency(item.amount))
                                .font(SpendLessFont.headline)
                                .foregroundStyle(Color.spendLessPrimary)
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    // Question
                    Text("Was this...")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, SpendLessSpacing.md)
                        .padding(.top, SpendLessSpacing.sm)
                    
                    // Feeling options
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(PurchaseFeeling.allCases) { feeling in
                            FeelingOptionCard(
                                title: feeling.displayName,
                                icon: feeling.icon,
                                isSelected: selectedFeeling == feeling
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedFeeling = feeling
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    Spacer()
                    
                    // Actions
                    VStack(spacing: SpendLessSpacing.sm) {
                        PrimaryButton("Done", icon: "checkmark") {
                            onConfirm(selectedFeeling)
                            dismiss()
                        }
                        
                        TextButton("Skip reflection") {
                            onConfirm(nil)
                            dismiss()
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
            .navigationTitle("Buying \(item.name)")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
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

// MARK: - Feeling Option Card

struct FeelingOptionCard: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(icon)
                    .font(.title2)
                
                Text(title)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
                
                ZStack {
                    Circle()
                        .stroke(Color.spendLessTextMuted, lineWidth: 1.5)
                        .frame(width: 24, height: 24)
                        .opacity(isSelected ? 0 : 1)
                    
                    if isSelected {
                        Circle()
                            .fill(Color.spendLessPrimary)
                            .frame(width: 24, height: 24)
                        
                        Image(systemName: "checkmark")
                            .font(.caption.weight(.bold))
                            .foregroundStyle(.white)
                    }
                }
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(isSelected ? Color.spendLessPrimaryLight.opacity(0.15) : Color.spendLessCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(isSelected ? Color.spendLessPrimary : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PurchaseReflectionSheet(
        item: WaitingListItem.sampleItems[1]
    ) { feeling in
        print("Selected: \(feeling?.displayName ?? "skipped")")
    }
}

