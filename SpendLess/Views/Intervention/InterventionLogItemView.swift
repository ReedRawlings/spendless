//
//  InterventionLogItemView.swift
//  SpendLess
//
//  Form to log an item to waiting list during intervention
//

import SwiftUI

struct InterventionLogItemView: View {
    let onItemLogged: (String, Decimal) -> Void
    
    @State private var itemName = ""
    @State private var itemPrice = ""
    @State private var reason = ""
    @FocusState private var focusedField: Field?
    @State private var appeared = false
    
    enum Field {
        case name, price, reason
    }
    
    var body: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Header
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("What did you want?")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Add it to your waiting list. If you still want it in 7 days, buy it guilt-free.")
                        .font(SpendLessFont.subheadline)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                }
                .padding(.top, SpendLessSpacing.xxxl)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                // Form fields
                VStack(spacing: SpendLessSpacing.lg) {
                    // Item name
                    VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                        Text("Item")
                            .font(SpendLessFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        TextField("Wireless earbuds, dress, etc.", text: $itemName)
                            .font(SpendLessFont.body)
                            .padding(SpendLessSpacing.md)
                            .background(Color.spendLessCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                    .strokeBorder(Color.spendLessBackgroundSecondary, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .name)
                    }
                    
                    // Price
                    VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                        Text("Price")
                            .font(SpendLessFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("$")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                            
                            TextField("0", text: $itemPrice)
                                .font(SpendLessFont.body)
                                .keyboardType(.decimalPad)
                                .focused($focusedField, equals: .price)
                        }
                        .padding(SpendLessSpacing.md)
                        .background(Color.spendLessCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                        .overlay(
                            RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                .strokeBorder(Color.spendLessBackgroundSecondary, lineWidth: 1)
                        )
                    }
                    
                    // Reason (optional)
                    VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                        Text("Why do you want it? (optional)")
                            .font(SpendLessFont.subheadline)
                            .fontWeight(.medium)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        TextField("My old one broke...", text: $reason)
                            .font(SpendLessFont.body)
                            .padding(SpendLessSpacing.md)
                            .background(Color.spendLessCardBackground)
                            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                            .overlay(
                                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                    .strokeBorder(Color.spendLessBackgroundSecondary, lineWidth: 1)
                            )
                            .focused($focusedField, equals: .reason)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .opacity(appeared ? 1 : 0)
                .offset(y: appeared ? 0 : 20)
                
                Spacer(minLength: SpendLessSpacing.xxl)
                
                // Submit button
                PrimaryButton("Add to Waiting List", isDisabled: !isValid) {
                    logItem()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xxl)
                .opacity(appeared ? 1 : 0)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.4)) {
                appeared = true
            }
            
            // Focus name field after animation
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                focusedField = .name
            }
        }
        .onTapGesture {
            focusedField = nil
        }
    }
    
    private var isValid: Bool {
        !itemName.trimmingCharacters(in: .whitespaces).isEmpty &&
        !itemPrice.isEmpty &&
        Decimal(string: itemPrice) != nil &&
        (Decimal(string: itemPrice) ?? 0) > 0
    }
    
    private func logItem() {
        guard let amount = Decimal(string: itemPrice) else { return }
        
        // Haptic feedback
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        onItemLogged(itemName, amount)
    }
}

// MARK: - Preview

#Preview {
    InterventionLogItemView { name, amount in
        print("Logged: \(name) for \(amount)")
    }
}

