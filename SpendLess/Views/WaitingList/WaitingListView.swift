//
//  WaitingListView.swift
//  SpendLess
//
//  7-day waiting list view
//

import SwiftUI
import SwiftData

struct WaitingListView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    @Query(sort: \WaitingListItem.expiresAt) private var items: [WaitingListItem]
    @Query private var goals: [UserGoal]
    
    @State private var showAddSheet = false
    @State private var showCelebration = false
    @State private var celebrationAmount: Decimal = 0
    
    private var currentGoal: UserGoal? {
        goals.first { $0.isActive }
    }
    
    private var activeItems: [WaitingListItem] {
        items.filter { !$0.isExpired }
    }
    
    private var expiredItems: [WaitingListItem] {
        items.filter { $0.isExpired }
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
                
                if showCelebration {
                    CelebrationOverlay(
                        isShowing: $showCelebration,
                        amount: celebrationAmount,
                        message: "Another impulse buried! 🪦"
                    )
                }
            }
            .navigationTitle("Waiting List")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAddSheet = true
                    } label: {
                        Image(systemName: "plus.circle.fill")
                            .font(.title2)
                            .foregroundStyle(Color.spendLessPrimary)
                    }
                }
            }
            .sheet(isPresented: $showAddSheet) {
                AddToWaitingListSheet()
            }
        }
    }
    
    // MARK: - Empty State
    
    private var emptyState: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Spacer()
            
            Text("⏳")
                .font(.system(size: 60))
            
            Text("Nothing here yet.")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("When you resist an impulse, add it here to test if you really want it.")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
            
            Text("Most things don't survive 7 days. 🪦")
                .font(SpendLessFont.bodyBold)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Spacer()
            
            PrimaryButton("Add something you resisted", icon: "plus") {
                showAddSheet = true
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.xl)
        }
        .padding()
    }
    
    // MARK: - Items List
    
    private var itemsList: some View {
        ScrollView {
            LazyVStack(spacing: SpendLessSpacing.md) {
                // Ready to decide section
                if !expiredItems.isEmpty {
                    Section {
                        ForEach(expiredItems) { item in
                            WaitingListItemRow(
                                item: item,
                                onBury: { buryItem(item) },
                                onBuy: { buyItem(item) },
                                onStillWantIt: { stillWantItem(item) }
                            )
                        }
                    } header: {
                        SectionHeader(title: "Ready to Decide", icon: "checkmark.circle")
                    }
                }
                
                // Still waiting section
                if !activeItems.isEmpty {
                    Section {
                        ForEach(activeItems) { item in
                            WaitingListItemRow(
                                item: item,
                                onBury: { buryItem(item) },
                                onBuy: nil,
                                onStillWantIt: { stillWantItem(item) }
                            )
                        }
                    } header: {
                        SectionHeader(title: "Still Waiting", icon: "clock")
                    }
                }
                
                // Add button at bottom
                Button {
                    showAddSheet = true
                } label: {
                    HStack {
                        Image(systemName: "plus.circle")
                        Text("Add something you resisted")
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
    
    // MARK: - Actions
    
    private func buryItem(_ item: WaitingListItem) {
        // Create graveyard item
        let graveyardItem = GraveyardItem(from: item, source: .waitingList)
        modelContext.insert(graveyardItem)
        
        // Update goal
        if let goal = currentGoal {
            goal.addSavings(item.amount)
        }
        
        // Delete waiting list item
        modelContext.delete(item)
        
        try? modelContext.save()
        
        // Show celebration
        celebrationAmount = item.amount
        showCelebration = true
        
        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func buyItem(_ item: WaitingListItem) {
        // Just remove from list - no judgment
        modelContext.delete(item)
        try? modelContext.save()
        
        // Light haptic
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
    
    private func stillWantItem(_ item: WaitingListItem) {
        item.recordCheckin()
        
        // If checked in 3+ times, offer extension
        if item.checkinCount >= 3 && !item.isExpired {
            item.extendWaitingPeriod(days: 2)
        }
        
        try? modelContext.save()
        
        let generator = UIImpactFeedbackGenerator(style: .light)
        generator.impactOccurred()
    }
}

// MARK: - Section Header

struct SectionHeader: View {
    let title: String
    let icon: String
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.xs) {
            Image(systemName: icon)
                .foregroundStyle(Color.spendLessTextMuted)
            
            Text(title)
                .font(SpendLessFont.subheadline)
                .foregroundStyle(Color.spendLessTextMuted)
            
            Spacer()
        }
        .padding(.top, SpendLessSpacing.sm)
    }
}

// MARK: - Waiting List Item Row

struct WaitingListItemRow: View {
    let item: WaitingListItem
    let onBury: () -> Void
    let onBuy: (() -> Void)?
    let onStillWantIt: () -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            // Item info
            HStack {
                Text(item.name)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
                
                Text(formatCurrency(item.amount))
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessPrimary)
            }
            
            // Progress bar
            CountdownProgressBar(
                progress: item.progress,
                daysRemaining: item.daysRemaining
            )
            
            // Reason if provided
            if let reason = item.reason, !reason.isEmpty {
                Text("\"\(reason)\"")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                    .italic()
            }
            
            // Action buttons
            HStack(spacing: SpendLessSpacing.sm) {
                SmallSecondaryButton("Still want it", icon: "heart") {
                    onStillWantIt()
                }
                
                SmallPrimaryButton("Bury it", icon: "leaf.fill") {
                    onBury()
                }
                
                if let onBuy, item.isExpired {
                    SmallSecondaryButton("Buy it") {
                        onBuy()
                    }
                }
            }
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.cardShadow)
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = "USD"
        formatter.maximumFractionDigits = 0
        return formatter.string(from: amount as NSDecimalNumber) ?? "$0"
    }
}

// MARK: - Add to Waiting List Sheet

struct AddToWaitingListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var itemName = ""
    @State private var itemAmount: Decimal = 0
    @State private var reason = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    VStack(spacing: SpendLessSpacing.xs) {
                        Text("What did you resist?")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        Text("Add it to your 7-day waiting list")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(.top, SpendLessSpacing.lg)
                    
                    VStack(spacing: SpendLessSpacing.md) {
                        SpendLessTextField(
                            "What is it?",
                            text: $itemName,
                            placeholder: "e.g., Wireless earbuds"
                        )
                        
                        CurrencyTextField(
                            title: "How much?",
                            amount: $itemAmount
                        )
                        
                        SpendLessTextField(
                            "Why do you want it? (optional)",
                            text: $reason,
                            placeholder: "e.g., My old ones broke"
                        )
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    
                    Spacer()
                    
                    VStack(spacing: SpendLessSpacing.sm) {
                        Text("If you still want it in 7 days, you can buy it guilt-free.")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                            .multilineTextAlignment(.center)
                        
                        PrimaryButton("Add to Waiting List", icon: "clock") {
                            addItem()
                        }
                        .disabled(itemName.isEmpty || itemAmount <= 0)
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
            .navigationTitle("Add Item")
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
    
    private func addItem() {
        let item = WaitingListItem(
            name: itemName,
            amount: itemAmount,
            reason: reason.isEmpty ? nil : reason
        )
        modelContext.insert(item)
        try? modelContext.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    WaitingListView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

