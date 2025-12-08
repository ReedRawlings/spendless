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
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]
    // Note: sourceRaw must match GraveyardSource.waitingList.rawValue ("waitingList")
    @Query(filter: #Predicate<GraveyardItem> { $0.sourceRaw == "waitingList" })
    private var buriedFromWaitingList: [GraveyardItem]

    @State private var showAddSheet = false
    @State private var showCelebration = false
    @State private var celebrationAmount: Decimal = 0

    // Sheet state for bury/buy flows
    @State private var itemToBury: WaitingListItem?
    @State private var itemToBuy: WaitingListItem?

    private var currentGoal: UserGoal? {
        activeGoals.first
    }
    
    private var activeItems: [WaitingListItem] {
        if AppConstants.isScreenshotMode {
            return ScreenshotDataHelper.screenshotWaitingListItems().filter { !$0.isExpired }
        }
        return items.filter { !$0.isExpired }
    }
    
    private var expiredItems: [WaitingListItem] {
        if AppConstants.isScreenshotMode {
            return ScreenshotDataHelper.screenshotWaitingListItems().filter { $0.isExpired }
        }
        return items.filter { $0.isExpired }
    }
    
    private var waitingListStats: WaitingListStats {
        if AppConstants.isScreenshotMode {
            // Return fake stats for screenshot mode
            return WaitingListStats(
                totalValueWaiting: ScreenshotDataHelper.waitingListTotal,
                itemCount: ScreenshotDataHelper.waitingListItemCount,
                purchaseRate: 0.12, // 12%
                averageWaitDaysBuy: nil,
                averageWaitDaysBury: nil,
                totalBuried: 0,
                totalPurchased: 0
            )
        }
        return calculateWaitingListStats(
            waitingItems: items,
            graveyardItems: buriedFromWaitingList,
            purchasedItems: PurchasedItemsStore.shared.items
        )
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                if AppConstants.isScreenshotMode || !items.isEmpty {
                    itemsList
                } else {
                    emptyState
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
            .sheet(isPresented: $showAddSheet) {
                AddToWaitingListSheet()
            }
            .sheet(item: $itemToBury) { item in
                RemovalReasonSheet(item: item) { reason, note in
                    completeBuryItem(item, reason: reason, note: note)
                }
            }
            .sheet(item: $itemToBuy) { item in
                PurchaseReflectionSheet(item: item) { feeling in
                    completeBuyItem(item, feeling: feeling)
                }
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
                // Stats header (collapsible)
                WaitingListStatsCard(stats: waitingListStats)
                
                // Ready to decide section
                if !expiredItems.isEmpty {
                    Section {
                        ForEach(expiredItems) { item in
                            WaitingListItemRow(
                                item: item,
                                goal: currentGoal,
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
                                goal: currentGoal,
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
        // Show removal reason sheet
        itemToBury = item
    }
    
    private func completeBuryItem(_ item: WaitingListItem, reason: RemovalReason, note: String?) {
        // Create graveyard item with removal reason
        let graveyardItem = GraveyardItem(
            from: item,
            source: .waitingList,
            removalReason: reason,
            removalReasonNote: note
        )
        modelContext.insert(graveyardItem)
        
        // Update goal
        if let goal = currentGoal {
            goal.addSavings(item.amount)
        }
        
        // Delete waiting list item
        modelContext.delete(item)
        
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save after burying item")
        }
        
        // Show celebration
        celebrationAmount = item.amount
        showCelebration = true
        
        // Haptic
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    
    private func buyItem(_ item: WaitingListItem) {
        // Show purchase reflection sheet
        itemToBuy = item
    }
    
    private func completeBuyItem(_ item: WaitingListItem, feeling: PurchaseFeeling?) {
        // Track the purchase for analytics
        let purchasedItem = PurchasedWaitingListItem(from: item, reflection: feeling)
        PurchasedItemsStore.shared.add(purchasedItem)
        
        // Remove from waiting list - no judgment
        modelContext.delete(item)
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save after buying item")
        }
        
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
        
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save checkin")
        }
        
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
    let goal: UserGoal?
    let onBury: () -> Void
    let onBuy: (() -> Void)?
    let onStillWantIt: () -> Void
    
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var goalPercentage: Double? {
        guard let goal, goal.targetAmount > 0 else { return nil }
        let percentage = (item.amount as NSDecimalNumber).doubleValue / (goal.targetAmount as NSDecimalNumber).doubleValue * 100
        return percentage
    }
    
    private var opportunityCost: Decimal? {
        guard let birthYear = profile?.birthYear else { return nil }
        let currentAge = ToolCalculationService.ageFromBirthYear(birthYear)
        return ToolCalculationService.opportunityCost(amount: item.amount, currentAge: currentAge)
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            // Item info
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: SpendLessSpacing.xxs) {
                    Text(item.name)
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    // Reason wanted display
                    if let reasonText = item.reasonDisplayText {
                        HStack(spacing: SpendLessSpacing.xxs) {
                            if let reason = item.reasonWanted {
                                Text(reason.icon)
                                    .font(.caption)
                            }
                            Text(reasonText)
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                    }
                }
                
                Spacer()
                
                VStack(alignment: .trailing, spacing: SpendLessSpacing.xxs) {
                    HStack(spacing: SpendLessSpacing.xs) {
                        Text(formatCurrency(item.amount))
                            .font(SpendLessFont.headline)
                            .foregroundStyle(Color.spendLessPrimary)
                        
                        // Goal percentage (if goal exists)
                        if let percentage = goalPercentage {
                            Text("(\(formatPercentage(percentage))%)")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                    }
                    
                    // Real-life equivalent
                    Text("= \(AppConstants.isScreenshotMode ? (ScreenshotDataHelper.screenshotEquivalent(for: item.name) ?? realLifeEquivalent(for: item.amount)) : realLifeEquivalent(for: item.amount))")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
            }
            
            // Tool insights (small, integrated)
            if let costPerUse = item.calculatedCostPerUse, let uses = item.pricePerWearEstimate {
                HStack(spacing: SpendLessSpacing.xs) {
                    Text("👗")
                        .font(.caption)
                    Text("\(ToolCalculationService.formatCurrencyWithCents(costPerUse)) per use")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    Text("(\(uses) uses)")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                .padding(.top, SpendLessSpacing.xxs)
            }
            
            if let futureValue = opportunityCost {
                HStack(spacing: SpendLessSpacing.xs) {
                    Text("📈")
                        .font(.caption)
                    Text("This \(ToolCalculationService.formatCurrency(item.amount)) → \(ToolCalculationService.formatCurrency(futureValue)) by retirement")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xxs)
            }
            
            // Progress bar
            CountdownProgressBar(
                progress: item.progress,
                daysRemaining: item.daysRemaining
            )
            
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

    private func formatPercentage(_ percentage: Double) -> String {
        if percentage >= 1 {
            return String(format: "%.0f", percentage)
        } else {
            return String(format: "%.1f", percentage)
        }
    }
    
    private func formatCurrency(_ amount: Decimal) -> String {
        ToolCalculationService.formatCurrency(amount)
    }
}

// MARK: - Add to Waiting List Sheet

struct AddToWaitingListSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @State private var itemName = ""
    @State private var itemAmount: Decimal = 0
    @State private var selectedReason: ReasonWanted?
    @State private var otherReasonNote = ""
    @State private var showReasonPicker = false
    @State private var showPricePerWear = false
    @State private var pricePerWearEstimate: Int?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
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
                            
                            // Optional: Calculate price per wear
                            if itemAmount > 0 {
                                Button {
                                    showPricePerWear = true
                                } label: {
                                    HStack {
                                        Text("👗")
                                        Text("Calculate price per wear?")
                                            .font(SpendLessFont.body)
                                            .foregroundStyle(Color.spendLessPrimary)
                                        Spacer()
                                        if pricePerWearEstimate != nil {
                                            Image(systemName: "checkmark.circle.fill")
                                                .foregroundStyle(Color.spendLessSuccess)
                                        } else {
                                            Image(systemName: "chevron.right")
                                                .foregroundStyle(Color.spendLessTextMuted)
                                                .font(.caption)
                                        }
                                    }
                                    .padding(SpendLessSpacing.md)
                                    .background(Color.spendLessCardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Why do you want this? picker
                            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                                Text("Why do you want it? (optional)")
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                
                                Button {
                                    showReasonPicker = true
                                } label: {
                                    HStack {
                                        if let reason = selectedReason {
                                            Text(reason.icon)
                                            Text(reason.displayName)
                                                .foregroundStyle(Color.spendLessTextPrimary)
                                        } else {
                                            Text("Select a reason...")
                                                .foregroundStyle(Color.spendLessTextMuted)
                                        }
                                        Spacer()
                                        Image(systemName: "chevron.down")
                                            .foregroundStyle(Color.spendLessTextMuted)
                                    }
                                    .font(SpendLessFont.body)
                                    .padding(SpendLessSpacing.md)
                                    .background(Color.spendLessCardBackground)
                                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                                }
                                .buttonStyle(.plain)
                            }
                            
                            // Other reason note (if "Other" selected)
                            if selectedReason == .other {
                                SpendLessTextField(
                                    "Tell us more",
                                    text: $otherReasonNote,
                                    placeholder: "What's the reason?"
                                )
                                .transition(.opacity.combined(with: .move(edge: .top)))
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        Spacer(minLength: SpendLessSpacing.xl)
                    }
                }
                .scrollDismissesKeyboard(.interactively)
                
                // Bottom action area
                VStack {
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
                    .padding(.top, SpendLessSpacing.sm)
                    .background(
                        Color.spendLessBackground
                            .shadow(color: .black.opacity(0.05), radius: 10, y: -5)
                    )
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
            .sheet(isPresented: $showReasonPicker) {
                ReasonWantedPicker(selectedReason: $selectedReason)
                    .presentationDetents([.medium])
            }
            .fullScreenCover(isPresented: $showPricePerWear) {
                NavigationStack {
                    PricePerWearView(initialPrice: itemAmount) { estimate in
                        pricePerWearEstimate = estimate
                        showPricePerWear = false
                    }
                }
            }
        }
    }
    
    private func addItem() {
        let item = WaitingListItem(
            name: itemName,
            amount: itemAmount,
            reasonWanted: selectedReason,
            reasonWantedNote: selectedReason == .other ? otherReasonNote : nil
        )
        item.pricePerWearEstimate = pricePerWearEstimate
        modelContext.insert(item)
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save new waiting list item")
        }
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Reason Wanted Picker

struct ReasonWantedPicker: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedReason: ReasonWanted?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.sm) {
                        ForEach(ReasonWanted.allCases) { reason in
                            Button {
                                selectedReason = reason
                                dismiss()
                            } label: {
                                HStack(spacing: SpendLessSpacing.md) {
                                    Text(reason.icon)
                                        .font(.title2)
                                    
                                    Text(reason.displayName)
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextPrimary)
                                    
                                    Spacer()
                                    
                                    if selectedReason == reason {
                                        Image(systemName: "checkmark")
                                            .foregroundStyle(Color.spendLessPrimary)
                                            .fontWeight(.semibold)
                                    }
                                }
                                .padding(SpendLessSpacing.md)
                                .background(
                                    RoundedRectangle(cornerRadius: SpendLessRadius.md)
                                        .fill(selectedReason == reason 
                                            ? Color.spendLessPrimaryLight.opacity(0.15) 
                                            : Color.spendLessCardBackground)
                                )
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    .padding(SpendLessSpacing.md)
                }
            }
            .navigationTitle("Why do you want it?")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Skip") {
                        selectedReason = nil
                        dismiss()
                    }
                }
            }
        }
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

