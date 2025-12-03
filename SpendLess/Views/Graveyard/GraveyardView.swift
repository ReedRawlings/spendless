//
//  GraveyardView.swift
//  SpendLess
//
//  Cart Graveyard - buried impulse purchases
//

import SwiftUI
import SwiftData

struct GraveyardView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query(sort: \GraveyardItem.buriedAt, order: .reverse) private var items: [GraveyardItem]
    
    @State private var showReturnSheet = false
    
    private var totalBuried: Decimal {
        items.reduce(0) { $0 + $1.amount }
    }
    
    private var returnedItems: [GraveyardItem] {
        items.filter { $0.isReturn }
    }
    
    private var buriedItems: [GraveyardItem] {
        items.filter { !$0.isReturn }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                if items.isEmpty {
                    emptyState
                } else {
                    itemsList
                }
            }
            .navigationTitle("Cart Graveyard")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showReturnSheet = true
                    } label: {
                        Image(systemName: "arrow.uturn.backward.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.spendLessPrimary)
                    }
                }
            }
            .sheet(isPresented: $showReturnSheet) {
                LogReturnSheet()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            VStack(spacing: SpendLessSpacing.sm) {
                Text("🪦")
                    .font(.system(size: 60))
                
                Text("R.I.P.")
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextMuted)
                
                Text("Future Regrets")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            
            Text("Nothing here yet.")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("When you resist an impulse buy, it'll end up here — proof that you didn't need it after all.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
            
            Text("Your first burial is coming.\nWe believe in you.")
                .font(SpendLessFont.bodyBold)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            Spacer()
        }
        .padding()
    }
    
    // MARK: - Items List
    
    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: SpendLessSpacing.md) {
                // Stats header
                statsHeader
                
                // Quote
                Card {
                    Text("\"Things you wanted. Then didn't.\"")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .italic()
                        .frame(maxWidth: .infinity)
                }
                
                // Items
                ForEach(items) { item in
                    GraveyardItemRow(item: item)
                }
                
                // Log return button
                Button {
                    showReturnSheet = true
                } label: {
                    HStack {
                        Image(systemName: "arrow.uturn.backward")
                        Text("Log a return")
                    }
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessPrimary)
                    .frame(maxWidth: .infinity)
                    .padding(SpendLessSpacing.md)
                    .background(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(Color.spendLessPrimary, style: StrokeStyle(lineWidth: 2, dash: [8]))
                    )
                }
                .padding(.top, SpendLessSpacing.sm)
            }
            .padding(SpendLessSpacing.md)
        }
    }
    
    // MARK: - Stats Header
    
    private var statsHeader: some View {
        Card {
            HStack(spacing: SpendLessSpacing.xl) {
                VStack(spacing: SpendLessSpacing.xxs) {
                    Text("Total buried")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    Text(formatCurrency(totalBuried))
                        .font(SpendLessFont.title)
                        .foregroundStyle(Color.spendLessPrimary)
                }
                
                Divider()
                    .frame(height: 40)
                
                VStack(spacing: SpendLessSpacing.xxs) {
                    Text("Items resisted")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    Text("\(items.count)")
                        .font(SpendLessFont.title)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }
            }
            .frame(maxWidth: .infinity)
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

// MARK: - Graveyard Item Row

struct GraveyardItemRow: View {
    let item: GraveyardItem
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.md) {
            // Icon
            IconView(item.displayIcon, font: .title)
                .frame(width: 44, height: 44)
                .background(Color.spendLessBackgroundSecondary)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.sm))
            
            // Info
            VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                HStack {
                    Text(item.name)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    if item.isReturn {
                        Text("🔄")
                            .font(.caption)
                    }
                }
                
                Text(item.buriedTimeAgoText)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                
                // Display removal reason (new feature)
                if let removalReasonText = item.removalReasonDisplayText {
                    HStack(spacing: SpendLessSpacing.xxs) {
                        if let reason = item.removalReason {
                            Text(reason.icon)
                                .font(.caption2)
                        }
                        Text(removalReasonText)
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .lineLimit(1)
                    }
                } else if let reason = item.originalReason, !reason.isEmpty {
                    // Fallback to original reason for backward compatibility
                    Text("\"\(reason)\"")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .italic()
                        .lineLimit(1)
                }
            }
            
            Spacer()
            
            // Amount
            Text(formatCurrency(item.amount))
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessPrimary)
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.subtleShadow)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Log Return Sheet

struct LogReturnSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var goals: [UserGoal]
    
    @State private var itemName = ""
    @State private var itemAmount: Decimal = 0
    @State private var reason = ""
    @State private var showSuccess = false
    
    private var currentGoal: UserGoal? {
        goals.first { $0.isActive }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                if showSuccess {
                    successView
                } else {
                    formView
                }
            }
            .navigationTitle("Log a Return")
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
    
    private var formView: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            VStack(spacing: SpendLessSpacing.xs) {
                Text("🔄")
                    .font(.system(size: 50))
                
                Text("Returning something?")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Text("That takes self-awareness. We're proud of you.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            .padding(.top, SpendLessSpacing.lg)
            
            VStack(spacing: SpendLessSpacing.md) {
                SpendLessTextField(
                    "What did you return?",
                    text: $itemName,
                    placeholder: "e.g., That dress from last week"
                )
                
                CurrencyTextField(
                    title: "How much was it?",
                    amount: $itemAmount
                )
                
                SpendLessTextField(
                    "Why? (optional)",
                    text: $reason,
                    placeholder: "e.g., Realized I have 3 just like it"
                )
            }
            .padding(.horizontal, SpendLessSpacing.md)
            
            Spacer()
            
            PrimaryButton("Log Return", icon: "arrow.uturn.backward") {
                logReturn()
            }
            .disabled(itemName.isEmpty || itemAmount <= 0)
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    private var successView: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            Text("🔄")
                .font(.system(size: 60))
            
            Text("RETURNED!")
                .font(SpendLessFont.title)
                .foregroundStyle(Color.spendLessPrimary)
            
            Text("\"\(itemName)\" is going back.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("+\(formatCurrency(itemAmount))")
                .font(SpendLessFont.largeTitle)
                .foregroundStyle(Color.spendLessGold)
            
            if let goal = currentGoal {
                Text("Going toward \(goal.type.rawValue)!")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            
            Spacer()
            
            PrimaryButton("Done") {
                dismiss()
            }
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    private func logReturn() {
        let item = GraveyardItem(
            name: itemName,
            amount: itemAmount,
            originalReason: reason.isEmpty ? nil : reason,
            source: .returned
        )
        modelContext.insert(item)
        
        // Update goal
        if let goal = currentGoal {
            goal.addSavings(itemAmount)
        }
        
        try? modelContext.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        withAnimation {
            showSuccess = true
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

// MARK: - Preview

#Preview {
    GraveyardView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

