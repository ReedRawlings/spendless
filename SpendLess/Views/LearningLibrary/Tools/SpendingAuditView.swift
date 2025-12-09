//
//  SpendingAuditView.swift
//  SpendLess
//
//  Spending Audit - Inventory-based category audit that surfaces the true value of what users own
//

import SwiftUI
import SwiftData

// MARK: - Spending Audit Flow

enum SpendingAuditStep: Int, CaseIterable {
    case categorySelection
    case inventoryEntry
    case reveal
    case realityCheck
    case summary
}

struct SpendingAuditView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var currentStep: SpendingAuditStep = .categorySelection
    @State private var selectedCategory: AuditCategory?
    @State private var customCategoryName: String = ""
    @State private var audit: SpendingAudit?
    @State private var inventoryItems: [InventoryEntryItem] = []
    
    // Reality check responses
    @State private var usageRange: UsageRange?
    @State private var finishFrequency: FinishFrequency?
    @State private var duplicateRange: DuplicateRange?
    @State private var currentRealityQuestion: Int = 0
    
    // Navigation
    @State private var showAddToWaitingList = false
    @State private var navigateToLearning = false
    @State private var navigateToSettings = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var hourlyWage: Decimal? {
        profile?.trueHourlyWage
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            switch currentStep {
            case .categorySelection:
                categorySelectionView
            case .inventoryEntry:
                inventoryEntryView
            case .reveal:
                revealView
            case .realityCheck:
                realityCheckView
            case .summary:
                summaryView
            }
        }
        .navigationTitle(navigationTitle)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(currentStep != .categorySelection)
        .toolbar {
            if currentStep != .categorySelection && currentStep != .summary {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        goBack()
                    } label: {
                        HStack(spacing: 4) {
                            Image(systemName: "chevron.left")
                            Text("Back")
                        }
                    }
                }
            }
        }
        .sheet(isPresented: $showAddToWaitingList) {
            AddToWaitingListSheet()
        }
    }
    
    private var navigationTitle: String {
        switch currentStep {
        case .categorySelection:
            return "Spending Audit"
        case .inventoryEntry:
            return "\(selectedCategory?.displayName ?? "Audit")"
        case .reveal:
            return "Your Inventory"
        case .realityCheck:
            return "Reality Check"
        case .summary:
            return "Your Audit"
        }
    }
    
    // MARK: - Screen 1: Category Selection
    
    private var categorySelectionView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Header
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("What area feels out of control?")
                        .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Choose a category to audit")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.lg)
                
                // Category Cards
                VStack(spacing: SpendLessSpacing.md) {
                    ForEach(AuditCategory.allCases) { category in
                        CategoryCard(category: category) {
                            selectCategory(category)
                        }
                    }
                }
                .padding(.horizontal, SpendLessSpacing.md)
            }
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    // MARK: - Screen 2: Inventory Entry
    
    private var inventoryEntryView: some View {
        VStack(spacing: 0) {
            // Running total header
            runningTotalHeader
            
            // Inventory list
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    ForEach(groupedInventoryItems.keys.sorted(), id: \.self) { subcategory in
                        if let items = groupedInventoryItems[subcategory] {
                            InventorySubcategorySection(
                                subcategory: subcategory,
                                items: items,
                                onUpdate: updateInventoryItem
                            )
                        }
                    }
                    
                    // Add custom item button
                    Button {
                        addCustomItem()
                    } label: {
                        HStack {
                            Image(systemName: "plus.circle")
                            Text("Add custom item")
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
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                .padding(.vertical, SpendLessSpacing.md)
            }
            
            // Bottom CTA
            VStack(spacing: SpendLessSpacing.sm) {
                PrimaryButton("See My Results", icon: "chart.bar") {
                    createAuditAndProceed()
                }
                .disabled(totalValue <= 0)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessBackground)
        }
    }
    
    private var runningTotalHeader: some View {
        VStack(spacing: SpendLessSpacing.xs) {
            Text("\(ToolCalculationService.formatCurrency(totalValue)) logged")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessPrimary)
            
            Text("\(totalItemCount) items")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
    }
    
    private var totalValue: Decimal {
        inventoryItems.reduce(0) { $0 + $1.totalValue }
    }
    
    private var totalItemCount: Int {
        inventoryItems.reduce(0) { $0 + $1.quantity }
    }
    
    private var groupedInventoryItems: [String: [Binding<InventoryEntryItem>]] {
        var grouped: [String: [Binding<InventoryEntryItem>]] = [:]
        for index in inventoryItems.indices {
            let item = inventoryItems[index]
            let binding = Binding(
                get: { self.inventoryItems[index] },
                set: { self.inventoryItems[index] = $0 }
            )
            if grouped[item.subcategory] == nil {
                grouped[item.subcategory] = []
            }
            grouped[item.subcategory]?.append(binding)
        }
        return grouped
    }
    
    // MARK: - Screen 3: The Reveal
    
    private var revealView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.xl) {
                // Big reveal
                VStack(spacing: SpendLessSpacing.md) {
                    Text(selectedCategory?.icon ?? "📊")
                        .font(.system(size: 60))
                    
                    Text(ToolCalculationService.formatCurrency(totalValue))
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(Color.spendLessPrimary)
                    
                    Text("worth of \(selectedCategory?.displayName.lowercased() ?? "items")")
                        .font(SpendLessFont.title3)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.md)
                
                // Contextual insights
                VStack(alignment: .leading, spacing: SpendLessSpacing.lg) {
                    // Annualized breakdown
                    InsightRow(
                        icon: "📅",
                        title: "If accumulated over 3 years:",
                        value: "\(ToolCalculationService.formatCurrency(totalValue / 3))/year · \(ToolCalculationService.formatCurrency(totalValue / 36))/month"
                    )
                    
                    // Life energy (if configured)
                    if let wage = hourlyWage, wage > 0 {
                        let hours = ToolCalculationService.lifeEnergyHours(amount: totalValue, hourlyWage: wage)
                        InsightRow(
                            icon: "⏱️",
                            title: "In life energy:",
                            value: "\(ToolCalculationService.formatLifeEnergyHours(hours)) of your life\n(at \(ToolCalculationService.formatCurrency(wage))/hr take-home)"
                        )
                    }
                    
                    // Comparisons
                    let comparisons = ToolCalculationService.valueComparisons(amount: totalValue)
                    if !comparisons.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                            HStack(spacing: SpendLessSpacing.sm) {
                                Text("💡")
                                Text("That's roughly:")
                                    .font(SpendLessFont.bodyBold)
                                    .foregroundStyle(Color.spendLessTextPrimary)
                            }
                            
                            ForEach(comparisons, id: \.self) { comparison in
                                HStack(spacing: SpendLessSpacing.sm) {
                                    Text("•")
                        .foregroundStyle(Color.spendLessTextMuted)
                                    Text(comparison)
                                        .font(SpendLessFont.body)
                                        .foregroundStyle(Color.spendLessTextSecondary)
                                }
                            }
                        }
                        .padding(SpendLessSpacing.md)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.spendLessCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    }
                }
                .padding(.horizontal, SpendLessSpacing.md)
                
                Spacer()
                
                // Continue button
                PrimaryButton("Continue", icon: "arrow.right") {
                    currentStep = .realityCheck
                }
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    // MARK: - Screen 4: Reality Check
    
    private var realityCheckView: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Mirror emoji
            Text("🪞")
                .font(.system(size: 60))
            
            Text("Quick reality check")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("You logged \(totalItemCount) \(selectedCategory?.displayName.lowercased() ?? "items").")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Divider()
                .padding(.horizontal, SpendLessSpacing.xl)
            
            // Current question
            if currentRealityQuestion == 0 {
                realityQuestion1
            } else if currentRealityQuestion == 1 {
                realityQuestion2
            } else if currentRealityQuestion == 2 && totalItemCount > 20 {
                realityQuestion3
            }
            
            Spacer()
            
            // Navigation buttons
            HStack(spacing: SpendLessSpacing.md) {
                SecondaryButton("Skip") {
                    skipRealityQuestion()
                }
                
                PrimaryButton(isLastRealityQuestion ? "Finish" : "Next") {
                    nextRealityQuestion()
                }
            }
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    private var realityQuestion1: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Text("How many do you use regularly?")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                ForEach(UsageRange.allCases) { range in
                    SelectableChip(
                        title: range.displayName,
                        isSelected: usageRange == range
                    ) {
                        usageRange = range
                        HapticFeedback.buttonTap()
                    }
                }
            }
        }
        .padding(.horizontal, SpendLessSpacing.md)
    }
    
    private var realityQuestion2: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Text("When did you last finish a product before buying a replacement?")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            VStack(spacing: SpendLessSpacing.sm) {
                ForEach(FinishFrequency.allCases) { frequency in
                    SelectableRow(
                        title: frequency.displayName,
                        isSelected: finishFrequency == frequency
                    ) {
                        finishFrequency = frequency
                        HapticFeedback.buttonTap()
                    }
                }
            }
        }
        .padding(.horizontal, SpendLessSpacing.md)
    }
    
    private var realityQuestion3: some View {
        VStack(spacing: SpendLessSpacing.lg) {
            Text("How many of your items are duplicates or near-duplicates?")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            Text("(Similar shades, backups, etc.)")
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
            
            HStack(spacing: SpendLessSpacing.sm) {
                ForEach(DuplicateRange.allCases) { range in
                    SelectableChip(
                        title: range.displayName,
                        isSelected: duplicateRange == range
                    ) {
                        duplicateRange = range
                        HapticFeedback.buttonTap()
                    }
                }
            }
        }
        .padding(.horizontal, SpendLessSpacing.md)
    }
    
    private var isLastRealityQuestion: Bool {
        if totalItemCount > 20 {
            return currentRealityQuestion == 2
        } else {
            return currentRealityQuestion == 1
        }
    }
    
    // MARK: - Screen 5: Summary
    
    private var summaryView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Summary card
                summaryCard
                    .padding(.top, SpendLessSpacing.lg)
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.md)
                
                // What would you like to do?
                VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                    Text("What would you like to do?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .padding(.horizontal, SpendLessSpacing.md)
                    
                    // Action buttons
                    ActionCard(
                        icon: "📚",
                        title: "Learn More",
                        subtitle: "Explore the Learning Library"
                    ) {
                        navigateToLearning = true
                        dismiss()
                    }
                    
                    ActionCard(
                        icon: "📝",
                        title: "Add to Waiting List",
                        subtitle: "Something tempting? Wait on it"
                    ) {
                        showAddToWaitingList = true
                    }
                    
                    ActionCard(
                        icon: "🛡️",
                        title: "Set Up Interventions",
                        subtitle: "Block shopping apps & sites"
                    ) {
                        navigateToSettings = true
                        dismiss()
                    }
                    
                    ActionCard(
                        icon: "✓",
                        title: "Done for Now",
                        subtitle: nil
                    ) {
                        saveAndDismiss()
                    }
                }
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
    }
    
    private var summaryCard: some View {
        VStack(spacing: SpendLessSpacing.md) {
            Text(selectedCategory?.icon ?? "📊")
                .font(.system(size: 48))
            
            Text(ToolCalculationService.formatCurrency(totalValue))
                .font(SpendLessFont.largeTitle)
                .foregroundStyle(Color.spendLessPrimary)
            
            Text("\(totalItemCount) items")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            if let wage = hourlyWage, wage > 0 {
                let hours = ToolCalculationService.lifeEnergyHours(amount: totalValue, hourlyWage: wage)
                Text("\(ToolCalculationService.formatLifeEnergyHours(hours)) of life")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
            }
            
            // Usage insight if available
            if let usageRange = usageRange {
                let usageText = estimatedUsageText(for: usageRange)
                Text(usageText)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            
            // Date
            Text(formatDate(Date()))
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextMuted)
                .padding(.top, SpendLessSpacing.xs)
        }
        .padding(SpendLessSpacing.xl)
        .frame(maxWidth: .infinity)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                .padding(.horizontal, SpendLessSpacing.md)
    }
    
    // MARK: - Helper Functions
    
    private func selectCategory(_ category: AuditCategory) {
        selectedCategory = category
        HapticFeedback.buttonTap()
        
        if category == .other {
            // TODO: Show custom category input
            customCategoryName = "Custom"
        }
        
        // Initialize inventory items from category presets
        inventoryItems = []
        for subcategory in category.subcategories {
            for itemName in subcategory.items {
                inventoryItems.append(InventoryEntryItem(
                    subcategory: subcategory.name,
                    name: itemName
                ))
            }
        }
        
        currentStep = .inventoryEntry
    }
    
    private func updateInventoryItem(_ item: InventoryEntryItem) {
        if let index = inventoryItems.firstIndex(where: { $0.id == item.id }) {
            inventoryItems[index] = item
        }
    }
    
    private func addCustomItem() {
        // Add a blank custom item to the first subcategory or "Custom" if category is Other
        let subcategory = selectedCategory?.subcategories.first?.name ?? "Custom"
        inventoryItems.append(InventoryEntryItem(
            subcategory: subcategory,
            name: "Custom Item",
            isCustom: true
        ))
        HapticFeedback.buttonTap()
    }
    
    private func createAuditAndProceed() {
        guard let category = selectedCategory else { return }
        
        // Create the audit
        let newAudit = SpendingAudit(
            category: category,
            customCategoryName: category == .other ? customCategoryName : nil
        )
        
        // Add items with values
        for item in inventoryItems where item.hasValue {
            let auditItem = AuditItem(
                subcategory: item.subcategory,
                name: item.name,
                quantity: item.quantity,
                averagePrice: item.averagePrice,
                isCustom: item.isCustom
            )
            newAudit.items.append(auditItem)
        }
        
        audit = newAudit
        currentStep = .reveal
        HapticFeedback.buttonTap()
    }
    
    private func skipRealityQuestion() {
        nextRealityQuestion()
    }
    
    private func nextRealityQuestion() {
        HapticFeedback.buttonTap()
        
        if isLastRealityQuestion {
            // Save reality check responses to audit
            audit?.regularlyUsedRange = usageRange
            audit?.lastFinishedProduct = finishFrequency
            audit?.duplicateEstimate = duplicateRange
            
            currentStep = .summary
        } else {
            currentRealityQuestion += 1
        }
    }
    
    private func goBack() {
        switch currentStep {
        case .categorySelection:
            break
        case .inventoryEntry:
            currentStep = .categorySelection
        case .reveal:
            currentStep = .inventoryEntry
        case .realityCheck:
            if currentRealityQuestion > 0 {
                currentRealityQuestion -= 1
            } else {
                currentStep = .reveal
            }
        case .summary:
            currentStep = .realityCheck
        }
    }
    
    private func saveAndDismiss() {
        // Save the audit to the database
        if let audit = audit {
            modelContext.insert(audit)
            try? modelContext.save()
        }
        
        HapticFeedback.buttonTap()
        dismiss()
    }
    
    private func estimatedUsageText(for range: UsageRange) -> String {
        guard totalItemCount > 0 else { return "" }
        
        let usedCount: Int
        switch range {
        case .fewItems: usedCount = min(3, totalItemCount)
        case .someItems: usedCount = min(8, totalItemCount)
        case .manyItems: usedCount = min(15, totalItemCount)
        case .mostItems: usedCount = Int(Double(totalItemCount) * 0.8)
        }
        
        let percentage = (usedCount * 100) / totalItemCount
        return "You use ~\(usedCount) regularly (\(percentage)% of what you own)"
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

// MARK: - Inventory Entry Item (Local State)

struct InventoryEntryItem: Identifiable {
    let id = UUID()
    let subcategory: String
    var name: String
    var quantity: Int = 0
    var averagePrice: Decimal = 0
    var isCustom: Bool = false
    var isExpanded: Bool = false
    
    var totalValue: Decimal {
        Decimal(quantity) * averagePrice
    }
    
    var hasValue: Bool {
        quantity > 0 && averagePrice > 0
    }
}

// MARK: - Supporting Views

struct CategoryCard: View {
    let category: AuditCategory
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(category.icon)
                    .font(.title)
                
                Text(category.displayName)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .buttonStyle(.plain)
    }
}

struct InventorySubcategorySection: View {
    let subcategory: String
    let items: [Binding<InventoryEntryItem>]
    let onUpdate: (InventoryEntryItem) -> Void
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Text(subcategory)
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
                .padding(.horizontal, SpendLessSpacing.md)
            
            ForEach(items) { $item in
                InventoryItemRow(item: $item)
            }
        }
    }
}

struct InventoryItemRow: View {
    @Binding var item: InventoryEntryItem
    @State private var priceText: String = ""
    
    var body: some View {
        VStack(spacing: 0) {
            // Collapsed row
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    item.isExpanded.toggle()
                }
                HapticFeedback.buttonTap()
            } label: {
                HStack {
                    Text(item.name)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Spacer()
                    
                    if item.hasValue {
                        Text("\(item.quantity) × \(ToolCalculationService.formatCurrency(item.averagePrice))")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(Color.spendLessSuccess)
                    } else {
                        Text("__ × $__")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                }
                .padding(SpendLessSpacing.md)
                .background(Color.spendLessCardBackground)
            }
            .buttonStyle(.plain)
            
            // Expanded content
            if item.isExpanded {
                VStack(spacing: SpendLessSpacing.md) {
                    // Quantity
                    HStack {
                        Text("How many?")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        Spacer()
                        
                        CompactStepperInput(value: $item.quantity, range: 0...999)
                    }
                    
                    // Price
                    HStack {
                        Text("Average price each")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                        
                        Spacer()
                        
                        HStack(spacing: SpendLessSpacing.xs) {
                            Text("$")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextPrimary)
                            
                            TextField("0", text: $priceText)
                                .font(SpendLessFont.body)
                                .keyboardType(.decimalPad)
                                .frame(width: 80)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: priceText) { _, newValue in
                                    let filtered = newValue.filter { $0.isNumber || $0 == "." }
                                    if filtered != newValue {
                                        priceText = filtered
                                    }
                                    item.averagePrice = Decimal(string: filtered) ?? 0
                                }
                        }
                    }
                    
                    // Calculated total
                    if item.hasValue {
                        Divider()
                        
                        HStack {
                            Spacer()
                            Text("= \(ToolCalculationService.formatCurrency(item.totalValue))")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessPrimary)
                        }
                    }
                }
                .padding(SpendLessSpacing.md)
                .background(Color.spendLessBackgroundSecondary)
                .onAppear {
                    if item.averagePrice > 0 {
                        priceText = "\(item.averagePrice)"
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        .padding(.horizontal, SpendLessSpacing.md)
    }
}

struct InsightRow: View {
    let icon: String
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            HStack(spacing: SpendLessSpacing.sm) {
                Text(icon)
                Text(title)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessTextPrimary)
            }
            
            Text(value)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
                .padding(.leading, 28)
        }
        .padding(SpendLessSpacing.md)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
    }
}

struct SelectableChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(SpendLessFont.body)
                .foregroundStyle(isSelected ? .white : Color.spendLessTextPrimary)
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.vertical, SpendLessSpacing.sm)
                .background(isSelected ? Color.spendLessPrimary : Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .buttonStyle(.plain)
    }
}

struct SelectableRow: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                Image(systemName: isSelected ? "circle.inset.filled" : "circle")
                    .foregroundStyle(isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted)
                
                Text(title)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                Spacer()
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .buttonStyle(.plain)
    }
}

struct ActionCard: View {
    let icon: String
    let title: String
    let subtitle: String?
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(icon)
                    .font(.title2)
                
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    if let subtitle {
                        Text(subtitle)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    }
            }
            
            Spacer()
                
                Image(systemName: "chevron.right")
                    .font(.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        SpendingAuditView()
    }
    .modelContainer(for: [UserProfile.self, SpendingAudit.self, AuditItem.self], inMemory: true)
}
