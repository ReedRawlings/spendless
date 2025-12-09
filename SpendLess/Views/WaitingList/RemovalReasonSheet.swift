//
//  RemovalReasonSheet.swift
//  SpendLess
//
//  Sheet for capturing why user is burying an item
//

import SwiftUI

struct RemovalReasonSheet: View {
    @Environment(\.dismiss) private var dismiss
    
    let item: WaitingListItem
    let onConfirm: (RemovalReason, String?) -> Void
    
    @State private var selectedReason: RemovalReason?
    @State private var otherNote: String = ""
    @FocusState private var isNoteFieldFocused: Bool
    
    private var canConfirm: Bool {
        selectedReason != nil
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.lg) {
                        // Header
                        VStack(spacing: SpendLessSpacing.sm) {
                            Text("🪦")
                                .font(.system(size: 50))
                            
                            Text("Why are you burying this?")
                                .font(SpendLessFont.title2)
                                .foregroundStyle(Color.spendLessTextPrimary)
                            
                            Text("Understanding why helps you recognize patterns.")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                                .multilineTextAlignment(.center)
                        }
                        .padding(.top, SpendLessSpacing.lg)
                        
                        // Item being buried
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
                            ForEach(RemovalReason.allCases) { reason in
                                ReasonOptionCard(
                                    title: reason.displayName,
                                    icon: reason.icon,
                                    isSelected: selectedReason == reason
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedReason = reason
                                        if reason == .other {
                                            isNoteFieldFocused = true
                                        }
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        // Other note field (conditional)
                        if selectedReason == .other {
                            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                                Text("Tell us more (optional)")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                
                                TextField("Why did you change your mind?", text: $otherNote)
                                    .font(SpendLessFont.body)
                                    .padding(SpendLessSpacing.md)
                                    .background(Color.spendLessCardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                                    .focused($isNoteFieldFocused)
                            }
                            .padding(.horizontal, SpendLessSpacing.md)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                        }
                        
                        Spacer(minLength: SpendLessSpacing.xl)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
            }
            .navigationTitle("Bury Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
                
                ToolbarItem(placement: .confirmationAction) {
                    Button("Bury It") {
                        if let reason = selectedReason {
                            let note = reason == .other ? otherNote : nil
                            onConfirm(reason, note)
                            dismiss()
                        }
                    }
                    .fontWeight(.semibold)
                    .disabled(!canConfirm)
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
    RemovalReasonSheet(
        item: WaitingListItem.sampleItems[0]
    ) { reason, note in
        print("Selected: \(reason.displayName), note: \(note ?? "none")")
    }
}

