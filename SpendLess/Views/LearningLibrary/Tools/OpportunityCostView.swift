//
//  OpportunityCostView.swift
//  SpendLess
//
//  Opportunity Cost Calculator - shows what money could become at retirement
//

import SwiftUI
import SwiftData

struct OpportunityCostView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @Query private var profiles: [UserProfile]
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]
    
    @State private var amountText = ""
    @State private var showAgeEditor = false
    @State private var editAge = 30
    @State private var showResult = false
    @State private var showAddToWaitingList = false
    
    @FocusState private var isAmountFocused: Bool
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var currentAge: Int {
        profile?.currentAge ?? 30
    }
    
    private var amount: Decimal {
        guard let value = Decimal(string: amountText.replacingOccurrences(of: "$", with: "").replacingOccurrences(of: ",", with: "")) else { return 0 }
        return value
    }
    
    private var futureValue: Decimal {
        ToolCalculationService.opportunityCost(amount: amount, currentAge: currentAge)
    }
    
    private var multiplier: Double {
        ToolCalculationService.opportunityMultiplier(currentAge: currentAge)
    }
    
    private var comparisons: [String] {
        ToolCalculationService.comparisons(for: futureValue)
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Header
                    headerSection
                    
                    // Amount Input
                    amountInputSection
                    
                    // Age Display
                    ageSection
                    
                    // Results
                    if showResult && amount > 0 {
                        resultSection
                        comparisonsSection
                        actionButtons
                    }
                }
                .padding(SpendLessSpacing.md)
            }
            .onTapGesture {
                isAmountFocused = false
            }
        }
        .navigationTitle("Opportunity Cost")
        .navigationBarTitleDisplayMode(.large)
        .sheet(isPresented: $showAgeEditor) {
            AgeEditorSheet(
                age: $editAge,
                onSave: saveAge
            )
            .presentationDetents([.height(300)])
        }
        .sheet(isPresented: $showAddToWaitingList) {
            OpportunityCostAddToWaitingListSheet(
                amount: amount,
                onAdd: addToWaitingList,
                onDismiss: { showAddToWaitingList = false }
            )
            .presentationDetents([.medium])
        }
        .onAppear {
            editAge = currentAge
        }
        .onChange(of: amountText) { _, newValue in
            withAnimation {
                showResult = !newValue.isEmpty && amount > 0
            }
        }
    }
    
    // MARK: - Header Section
    
    private var headerSection: some View {
        VStack(spacing: SpendLessSpacing.sm) {
            Text("📈")
                .font(.system(size: 50))
            
            Text("What's this purchase worth?")
                .font(SpendLessFont.title3)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("See what this money could become if invested")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(.vertical, SpendLessSpacing.md)
    }
    
    // MARK: - Amount Input Section
    
    private var amountInputSection: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text("Amount")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            HStack {
                Text("$")
                    .font(SpendLessFont.title)
                    .foregroundStyle(Color.spendLessTextMuted)
                
                TextField("89", text: $amountText)
                    .font(SpendLessFont.title)
                    .keyboardType(.decimalPad)
                    .focused($isAmountFocused)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            .spendLessShadow(SpendLessShadow.subtleShadow)
        }
    }
    
    // MARK: - Age Section
    
    private var ageSection: some View {
        HStack {
            Text("Your age:")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Text("\(currentAge)")
                .font(SpendLessFont.bodyBold)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Spacer()
            
            Button {
                HapticFeedback.buttonTap()
                editAge = currentAge
                showAgeEditor = true
            } label: {
                Text("Edit")
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessPrimary)
            }
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
    }
    
    // MARK: - Result Section
    
    private var resultSection: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Divider()
                .padding(.vertical, SpendLessSpacing.sm)
            
            Text("\(ToolCalculationService.formatCurrency(amount)) today could be")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Text(ToolCalculationService.formatCurrency(futureValue))
                .font(.system(size: 48, weight: .bold, design: .rounded))
                .foregroundStyle(Color.spendLessPrimary)
            
            Text("at age 65")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Divider()
                .padding(.vertical, SpendLessSpacing.sm)
            
            Text("That's \(String(format: "%.1f", multiplier))x your money.")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
        }
        .padding(SpendLessSpacing.lg)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
        .spendLessShadow(SpendLessShadow.cardShadow)
        .transition(.opacity.combined(with: .scale(scale: 0.95)))
    }
    
    // MARK: - Comparisons Section
    
    @ViewBuilder
    private var comparisonsSection: some View {
        if !comparisons.isEmpty {
            VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                Text("Same as:")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                
                ForEach(comparisons, id: \.self) { comparison in
                    HStack(spacing: SpendLessSpacing.sm) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 6))
                            .foregroundStyle(Color.spendLessTextMuted)
                        
                        Text(comparison)
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextPrimary)
                    }
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
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
                Text("I don't need it (bury)")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
        }
        .padding(.top, SpendLessSpacing.md)
        .transition(.opacity)
    }
    
    // MARK: - Actions
    
    private func saveAge() {
        guard let profile else {
            // Create new profile if none exists
            let newProfile = UserProfile()
            newProfile.birthYear = ToolCalculationService.birthYearFromAge(editAge)
            modelContext.insert(newProfile)
            if !modelContext.saveSafely() {
                print("⚠️ Warning: Failed to save profile")
            }
            return
        }
        
        profile.birthYear = ToolCalculationService.birthYearFromAge(editAge)
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save profile")
        }
    }
    
    private func addToWaitingList(name: String) {
        let item = WaitingListItem(name: name, amount: amount)
        modelContext.insert(item)
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save waiting list item")
        }
        HapticFeedback.mediumSuccess()
        showAddToWaitingList = false
        dismiss()
    }
    
    private func buryItem() {
        let item = GraveyardItem(
            name: "Unnamed item",
            amount: amount,
            source: .manual
        )
        modelContext.insert(item)
        
        // Add to goal if exists
        if let goal = activeGoals.first {
            goal.savedAmount += amount
        }
        
        if !modelContext.saveSafely() {
            print("⚠️ Warning: Failed to save graveyard item")
        }
        dismiss()
    }
}

// MARK: - Age Editor Sheet

struct AgeEditorSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var age: Int
    let onSave: () -> Void
    
    var body: some View {
        NavigationStack {
            VStack(spacing: SpendLessSpacing.lg) {
                Text("Your Age")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Picker("Age", selection: $age) {
                    ForEach(18...80, id: \.self) { age in
                        Text("\(age)").tag(age)
                    }
                }
                .pickerStyle(.wheel)
                .frame(height: 150)
                
                PrimaryButton("Save") {
                    onSave()
                    dismiss()
                }
            }
            .padding(SpendLessSpacing.lg)
            .background(Color.spendLessBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Add to Waiting List Sheet

struct OpportunityCostAddToWaitingListSheet: View {
    @Environment(\.dismiss) private var dismiss
    let amount: Decimal
    let onAdd: (String) -> Void
    let onDismiss: () -> Void
    
    @State private var itemName = ""
    @FocusState private var isNameFocused: Bool
    
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
                
                Text("Amount: \(ToolCalculationService.formatCurrency(amount))")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                
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
        OpportunityCostView()
    }
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self, WaitingListItem.self, GraveyardItem.self, UserGoal.self], inMemory: true)
}

