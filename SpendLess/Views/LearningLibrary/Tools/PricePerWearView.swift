//
//  PricePerWearView.swift
//  SpendLess
//
//  Price Per Wear Calculator - reveals true cost per use of purchases
//

import SwiftUI
import SwiftData

struct PricePerWearView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]
    
    let initialPrice: Decimal?
    let onComplete: ((Int?) -> Void)?
    
    @State private var priceText = ""
    @State private var usesText = ""
    @State private var showResult = false
    @State private var showAddToWaitingList = false
    
    @FocusState private var focusedField: Field?
    
    enum Field {
        case price, uses
    }
    
    init(initialPrice: Decimal? = nil, onComplete: ((Int?) -> Void)? = nil) {
        self.initialPrice = initialPrice
        self.onComplete = onComplete
    }
    
    private var price: Decimal {
        guard let value = Decimal(string: priceText.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) else { return 0 }
        return value
    }
    
    private var estimatedUses: Int {
        Int(usesText) ?? 0
    }
    
    private var result: PricePerWearResult {
        PricePerWearResult(price: price, estimatedUses: estimatedUses)
    }
    
    private var canShowResult: Bool {
        price > 0 && estimatedUses > 0
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    headerSection
                    
                    // Price Input
                    priceInputSection
                    
                    // Uses Input
                    usesInputSection
                    
                    // Results
                    if showResult && canShowResult {
                        resultSection
                        contextSection
                        targetSection
                        actionButtons
                    }
                }
                .padding(SpendLessSpacing.md)
            }
            .onTapGesture {
                focusedField = nil
            }
        }
        .navigationTitle("Price Per Wear")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAddToWaitingList) {
            AddToWaitingListWithEstimateSheet(
                price: price,
                estimatedUses: estimatedUses,
                onAdd: addToWaitingList,
                onDismiss: { showAddToWaitingList = false }
            )
            .presentationDetents([.medium])
        }
        .onChange(of: priceText) { _, _ in updateResult() }
        .onChange(of: usesText) { _, _ in updateResult() }
        .onAppear {
            if let initialPrice = initialPrice {
                priceText = String(format: "%.0f", NSDecimalNumber(decimal: initialPrice).doubleValue)
            }
        }
        .toolbar {
            if onComplete != nil {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        let estimate = estimatedUses > 0 ? estimatedUses : nil
                        onComplete?(estimate)
                        dismiss()
                    }
                }
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            Text("👗")
                .font(.system(size: 50))
            
            Text("What does it cost per use?")
                .font(SpendLessFont.title3)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("Be honest about how often you'll actually use it")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, SpendLessSpacing.md)
    }
    
    // MARK: - Price Input Section
    
    private var priceInputSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text("What does it cost?")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            HStack {
                Text("$")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextMuted)
                
                TextField("89", text: $priceText)
                    .font(SpendLessFont.title)
                    .keyboardType(.decimalPad)
                    .focused($focusedField, equals: .price)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            .spendLessShadow(SpendLessShadow.subtleShadow)
        }
    }
    
    // MARK: - Uses Input Section
    
    private var usesInputSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text("How many times will you ACTUALLY use it?")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Text("Be honest.")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessPrimary)
                .italic()
            
            TextField("12", text: $usesText)
                .font(SpendLessFont.title)
                .keyboardType(.numberPad)
                .focused($focusedField, equals: .uses)
                .padding(SpendLessSpacing.md)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                .spendLessShadow(SpendLessShadow.subtleShadow)
        }
    }
    
    // MARK: - Result Section
    
    private var resultSection: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Divider()
                .padding(.vertical, SpendLessSpacing.sm)
            
            Text(ToolCalculationService.formatCurrencyWithCents(result.costPerUse))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(verdictColor)
            
            Text("per use")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                Text(result.verdict.emoji)
                    .font(.title)
                
                Text(result.verdict.message)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)
            }
            .padding(SpendLessSpacing.md)
            .background(verdictColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .padding(SpendLessSpacing.lg)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.cardShadow)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Context Section
    
    private var contextSection: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            Text(ToolCalculationService.perUseComparison(costPerUse: result.costPerUse))
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessBackgroundSecondary)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        .transition(.opacity)
    }
    
    // MARK: - Target Section
    
    @ViewBuilder
    private var targetSection: some View {
        if result.usesNeededForTarget > estimatedUses {
            VStack(spacing: SpendLessSpacing.sm) {
                Text("To get under $2/use, you'd need to use this \(result.usesNeededForTarget) times.")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(SpendLessSpacing.md)
            .transition(.opacity)
        }
    }
    
    // MARK: - Action Buttons
    
    private var actionButtons: some View {
        VStack(spacing: SpendLessSpacing.md) {
            PrimaryButton("Add to Waiting List", icon: "clock") {
                HapticFeedback.buttonTap()
                showAddToWaitingList = true
            }
            
            Button {
                HapticFeedback.mediumSuccess()
                buryItem()
            } label: {
                Text("Actually, never mind")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
        }
        .padding(.top, SpendLessSpacing.md)
        .transition(.opacity)
    }
    
    // MARK: - Computed Properties
    
    private var verdictColor: Color {
        switch result.verdict {
        case .greatValue, .solidInvestment:
            return Color.spendLessSuccess
        case .reasonable:
            return Color.spendLessWarning
        case .gettingExpensive, .basicallyARental:
            return Color.spendLessError
        }
    }
    
    // MARK: - Actions
    
    private func updateResult() {
        withAnimation {
            showResult = canShowResult
        }
    }
    
    private func addToWaitingList(name: String) {
        let item = WaitingListItem(name: name, amount: price)
        item.pricePerWearEstimate = estimatedUses
        modelContext.insert(item)
        try? modelContext.save()
        HapticFeedback.mediumSuccess()
        showAddToWaitingList = false
        dismiss()
    }
    
    private func buryItem() {
        let item = GraveyardItem(
            name: "Unnamed item",
            amount: price,
            source: .manual
        )
        modelContext.insert(item)
        
        // Add to goal if exists
        if let goal = activeGoals.first {
            goal.savedAmount += price
        }
        
        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Add to Waiting List Sheet (with estimate)

struct AddToWaitingListWithEstimateSheet: View {
    @Environment(\.dismiss) private var dismiss
    let price: Decimal
    let estimatedUses: Int
    let onAdd: (String) -> Void
    let onDismiss: () -> Void
    
    @State private var itemName = ""
    @FocusState private var isNameFocused: Bool
    
    private var costPerUse: Decimal {
        guard estimatedUses > 0 else { return price }
        return price / Decimal(estimatedUses)
    }
    
    var body: some View {
        NavigationStack {
            VStack(spacing: SpendLessSpacing.lg) {
                Text("What were you thinking of buying?")
                    .font(SpendLessFont.title3)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                TextField("Item name", text: $itemName)
                    .font(SpendLessFont.body)
                    .padding(SpendLessSpacing.md)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .focused($isNameFocused)
                
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("Price: \(ToolCalculationService.formatCurrency(price))")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text("Estimated uses: \(estimatedUses)")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text("Cost per use: \(ToolCalculationService.formatCurrencyWithCents(costPerUse))")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessPrimary)
                }
                
                Spacer()
                
                PrimaryButton("Add to Waiting List", icon: "clock") {
                    onAdd(itemName.isEmpty ? "Unnamed item" : itemName)
                }
                .disabled(itemName.isEmpty)
            }
            .padding(SpendLessSpacing.lg)
            .background(Color.spendLessBackground)
            .navigationTitle("Add Item")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        onDismiss()
                    }
                }
            }
            .onAppear {
                isNameFocused = true
            }
        }
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        PricePerWearView()
    }
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self, WaitingListItem.self, GraveyardItem.self, UserGoal.self], inMemory: true)
}

