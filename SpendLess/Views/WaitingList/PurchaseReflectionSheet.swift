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
    let onConfirm: (PurchaseReason?) -> Void
    
    @State private var selectedReason: PurchaseReason?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    VStack(spacing: SpendLessSpacing.sm) {
                        Text("🛍️")
                            .font(.system(size: 50))
                        
                        if item.isExpired {
                            Text("You waited \(item.daysWaited) days")
                                .font(SpendLessFont.title2)
                                .foregroundStyle(Color.spendLessPrimary)
                        } else {
                            Text("You've waited \(item.daysWaited) days")
                                .font(SpendLessFont.title2)
                                .foregroundStyle(Color.spendLessPrimary)
                        }
                        
                        Text("What made you decide to purchase?")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
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
                    
                    // Reason options
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(PurchaseReason.allCases) { reason in
                            ReasonOptionCard(
                                title: reason.displayName,
                                description: reason.description,
                                icon: reason.icon,
                                isSelected: selectedReason == reason,
                                isAligned: reason.isAligned
                            ) {
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    selectedReason = reason
                                }
                            }
                        }
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    Spacer()
                    
                    // Actions
                    VStack(spacing: SpendLessSpacing.sm) {
                        PrimaryButton("Continue", icon: "checkmark") {
                            onConfirm(selectedReason)
                            dismiss()
                        }
                        .disabled(selectedReason == nil)
                        
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

// MARK: - Reason Option Card

private struct ReasonOptionCard: View {
    let title: String
    let description: String
    let icon: String
    let isSelected: Bool
    let isAligned: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                HStack(spacing: SpendLessSpacing.md) {
                    Text(icon)
                        .font(.title2)
                    
                    Text(title)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Spacer()
                    
                    ZStack {
                        Circle()
                            .stroke(isAligned ? Color.spendLessSuccess : Color.spendLessTextMuted, lineWidth: 1.5)
                            .frame(width: 24, height: 24)
                            .opacity(isSelected ? 0 : 1)
                        
                        if isSelected {
                            Circle()
                                .fill(isAligned ? Color.spendLessSuccess : Color.spendLessPrimary)
                                .frame(width: 24, height: 24)
                            
                            Image(systemName: "checkmark")
                                .font(.caption.weight(.bold))
                                .foregroundStyle(.white)
                        }
                    }
                }
                
                Text(description)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 40) // Align with icon
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(isSelected 
                        ? (isAligned ? Color.spendLessSuccess.opacity(0.1) : Color.spendLessPrimaryLight.opacity(0.15))
                        : Color.spendLessCardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .strokeBorder(
                        isSelected 
                            ? (isAligned ? Color.spendLessSuccess : Color.spendLessPrimary)
                            : Color.clear, 
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    PurchaseReflectionSheet(
        item: WaitingListItem.sampleItems[1]
    ) { reason in
        print("Selected: \(reason?.displayName ?? "skipped")")
    }
}

