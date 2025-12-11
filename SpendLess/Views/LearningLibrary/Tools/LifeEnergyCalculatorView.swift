//
//  LifeEnergyCalculatorView.swift
//  SpendLess
//
//  Life Energy Calculator - Calculate discretionary hourly wage after cost of living
//

import SwiftUI
import SwiftData

// MARK: - Life Energy Calculator Flow

enum LifeEnergyStep: Int, CaseIterable {
    case setupPrompt
    case income
    case costOfLiving
    case results
}

struct LifeEnergyCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var currentStep: LifeEnergyStep = .setupPrompt
    
    // Income inputs
    @State private var takeHomePay: Decimal = 0
    @State private var payFrequency: PayFrequency = .biweekly
    @State private var hoursWorkedPerWeek: Int = 40
    
    // Cost of living inputs
    @State private var monthlyHousing: Decimal = 0
    @State private var monthlyFood: Decimal = 0
    @State private var monthlyUtilities: Decimal = 0
    @State private var monthlyTransportation: Decimal = 0
    @State private var monthlyInsurance: Decimal = 0
    @State private var monthlyDebt: Decimal = 0
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var hasExistingConfiguration: Bool {
        profile?.hasConfiguredLifeEnergy == true
    }
    
    private var calculatedHourlyWage: Decimal? {
        ToolCalculationService.trueHourlyWage(
            takeHome: takeHomePay,
            frequency: payFrequency,
            hoursPerWeek: hoursWorkedPerWeek,
            housing: monthlyHousing,
            food: monthlyFood,
            utilities: monthlyUtilities,
            transportation: monthlyTransportation,
            insurance: monthlyInsurance,
            debt: monthlyDebt
        )
    }
    
    private var monthlyTakeHome: Decimal {
        takeHomePay * payFrequency.monthlyMultiplier
    }
    
    private var monthlyCostOfLiving: Decimal {
        monthlyHousing + monthlyFood + monthlyUtilities + monthlyTransportation + monthlyInsurance + monthlyDebt
    }
    
    private var monthlyDiscretionary: Decimal {
        monthlyTakeHome - monthlyCostOfLiving
    }
    
    private var monthlyWorkHours: Decimal {
        Decimal(hoursWorkedPerWeek) * (Decimal(string: "4.33") ?? Decimal(4.33))
    }
    
    private var minutesPerDollar: Decimal? {
        guard let wage = calculatedHourlyWage, wage > 0 else { return nil }
        return Decimal(60) / wage
    }
    
    private var canCalculateIncome: Bool {
        takeHomePay > 0 && hoursWorkedPerWeek > 0
    }
    
    private var hasNegativeDiscretionary: Bool {
        monthlyDiscretionary <= 0
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            switch currentStep {
            case .setupPrompt:
                setupPromptView
            case .income:
                incomeView
            case .costOfLiving:
                costOfLivingView
            case .results:
                resultsView
            }
        }
        .navigationTitle(currentStep == .setupPrompt ? "Life Energy Calculator" : "")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // If already configured, go straight to results
            if hasExistingConfiguration {
                loadExistingValues()
                currentStep = .results
            }
        }
    }
    
    // MARK: - Screen 1: Setup Prompt
    
    private var setupPromptView: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Icon
            Text("⏱️")
                .font(.system(size: 80))
            
            // Title
            Text("What is your time really worth?")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            // Description
            VStack(spacing: SpendLessSpacing.md) {
                Text("After rent, food, and bills — what do you actually have left to spend per hour of work?")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                
                Text("The answer might surprise you.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            Spacer()
            
            // Get Started button
            PrimaryButton("Calculate Mine", icon: "arrow.right") {
                currentStep = .income
                HapticFeedback.buttonTap()
            }
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    // MARK: - Screen 2: Income
    
    private var incomeView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Progress indicator
                ProgressView(value: 0.33)
                    .tint(Color.spendLessPrimary)
                    .padding(.top, SpendLessSpacing.md)
                
                // Take-home pay
                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("What's your take-home pay?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("(after taxes, per paycheck)")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    CurrencyTextField(title: "", amount: $takeHomePay)
                    
                    Text("Use your average month if income varies")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .padding(.top, SpendLessSpacing.xxs)
                }
                .padding(.top, SpendLessSpacing.md)
                
                // Pay frequency
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    Text("How often are you paid?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    HStack(spacing: SpendLessSpacing.sm) {
                        ForEach(PayFrequency.allCases) { frequency in
                            PayFrequencyChip(
                                frequency: frequency,
                                isSelected: payFrequency == frequency
                            ) {
                                payFrequency = frequency
                                HapticFeedback.buttonTap()
                            }
                        }
                    }
                }
                
                // Hours worked per week
                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("Hours worked per week")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    HStack {
                        Spacer()
                        
                        HStack(spacing: SpendLessSpacing.md) {
                            Button {
                                if hoursWorkedPerWeek > 1 {
                                    hoursWorkedPerWeek -= 1
                                    HapticFeedback.buttonTap()
                                }
                            } label: {
                                Image(systemName: "minus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(hoursWorkedPerWeek > 1 ? Color.spendLessPrimary : Color.spendLessTextMuted)
                            }
                            .disabled(hoursWorkedPerWeek <= 1)
                            
                            Text("\(hoursWorkedPerWeek)")
                                .font(SpendLessFont.title)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .frame(minWidth: 60)
                            
                            Button {
                                if hoursWorkedPerWeek < 168 {
                                    hoursWorkedPerWeek += 1
                                    HapticFeedback.buttonTap()
                                }
                            } label: {
                                Image(systemName: "plus.circle.fill")
                                    .font(.title)
                                    .foregroundStyle(hoursWorkedPerWeek < 168 ? Color.spendLessPrimary : Color.spendLessTextMuted)
                            }
                            .disabled(hoursWorkedPerWeek >= 168)
                        }
                        .padding(SpendLessSpacing.md)
                        .background(Color.spendLessBackgroundSecondary)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                        
                        Spacer()
                    }
                }
                
                Spacer()
                    .frame(height: SpendLessSpacing.xl)
                
                // Next button
                PrimaryButton("Next", icon: "arrow.right") {
                    currentStep = .costOfLiving
                    HapticFeedback.buttonTap()
                }
                .disabled(!canCalculateIncome)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .padding(.horizontal, SpendLessSpacing.md)
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    currentStep = .setupPrompt
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    // MARK: - Screen 3: Cost of Living
    
    private var costOfLivingView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Progress indicator
                ProgressView(value: 0.67)
                    .tint(Color.spendLessPrimary)
                    .padding(.top, SpendLessSpacing.md)
                
                VStack(alignment: .leading, spacing: SpendLessSpacing.md) {
                    Text("What does life cost you?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("(monthly estimates are fine)")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                .padding(.top, SpendLessSpacing.md)
                
                // Cost of living fields
                VStack(spacing: SpendLessSpacing.md) {
                    CostOfLivingRow(
                        label: "Rent/Mortgage",
                        amount: $monthlyHousing
                    )
                    
                    CostOfLivingRow(
                        label: "Food & groceries",
                        amount: $monthlyFood
                    )
                    
                    CostOfLivingRow(
                        label: "Utilities & phone",
                        amount: $monthlyUtilities
                    )
                    
                    CostOfLivingRow(
                        label: "Transportation",
                        amount: $monthlyTransportation
                    )
                    
                    CostOfLivingRow(
                        label: "Insurance",
                        amount: $monthlyInsurance
                    )
                    
                    CostOfLivingRow(
                        label: "Debt payments",
                        amount: $monthlyDebt
                    )
                }
                
                Spacer()
                    .frame(height: SpendLessSpacing.xl)
                
                // See Results button
                PrimaryButton("See Results", icon: "arrow.right") {
                    saveConfiguration()
                    currentStep = .results
                    HapticFeedback.buttonTap()
                }
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .padding(.horizontal, SpendLessSpacing.md)
        }
        .navigationBarBackButtonHidden(false)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    currentStep = .income
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    // MARK: - Screen 4: Results
    
    private var resultsView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.xl) {
                // Title
                Text("Life Energy Calculator")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .padding(.top, SpendLessSpacing.md)
                
                // True hourly wage
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Your true hourly wage")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    if let wage = calculatedHourlyWage {
                        Text(ToolCalculationService.formatCurrencyWithCents(wage))
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Color.spendLessPrimary)
                    } else {
                        Text("$0.00")
                            .font(.system(size: 48, weight: .bold))
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                }
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.xl)
                
                // Breakdown
                VStack(spacing: SpendLessSpacing.sm) {
                    BreakdownRow(
                        label: "Monthly take-home",
                        value: ToolCalculationService.formatCurrency(monthlyTakeHome)
                    )
                    
                    BreakdownRow(
                        label: "Cost of living",
                        value: "-" + ToolCalculationService.formatCurrency(monthlyCostOfLiving)
                    )
                    
                    Divider()
                        .padding(.vertical, SpendLessSpacing.xs)
                    
                    BreakdownRow(
                        label: "Discretionary income",
                        value: ToolCalculationService.formatCurrency(monthlyDiscretionary),
                        isHighlighted: true
                    )
                    
                    BreakdownRow(
                        label: "Hours worked",
                        value: String(format: "%.0f", NSDecimalNumber(decimal: monthlyWorkHours).doubleValue)
                    )
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.xl)
                
                // Insights
                VStack(spacing: SpendLessSpacing.md) {
                    // Show warning if all cost of living fields are empty
                    if monthlyCostOfLiving == 0 && monthlyTakeHome > 0 {
                        WarningBanner(
                            message: "Add your expenses for a more accurate number",
                            type: .warning
                        )
                        .padding(.horizontal, SpendLessSpacing.lg)
                    }
                    
                    if hasNegativeDiscretionary {
                        WarningBanner(
                            message: "Your essentials currently match or exceed your income. Every non-essential purchase goes on credit.",
                            type: .error
                        )
                        .padding(.horizontal, SpendLessSpacing.lg)
                    } else if let wage = calculatedHourlyWage, let minutes = minutesPerDollar {
                        VStack(spacing: SpendLessSpacing.sm) {
                            Text("Every dollar you spend on non-essentials costs you")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                                .multilineTextAlignment(.center)
                            
                            Text("\(Int(NSDecimalNumber(decimal: minutes).doubleValue)) minutes of work.")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .multilineTextAlignment(.center)
                            
                            // Example: $150 jacket
                            let jacketHours = ToolCalculationService.lifeEnergyHours(
                                amount: 150,
                                hourlyWage: wage
                            )
                            
                            Text("That $150 jacket?")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                            
                            Text("\(Int(NSDecimalNumber(decimal: jacketHours).doubleValue)) hours of your life.")
                                .font(SpendLessFont.bodyBold)
                                .foregroundStyle(Color.spendLessTextPrimary)
                        }
                        .padding(SpendLessSpacing.lg)
                        .background(Color.spendLessCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.xl)
                
                // Action buttons
                VStack(spacing: SpendLessSpacing.sm) {
                    SecondaryButton("Recalculate", icon: "arrow.counterclockwise") {
                        currentStep = .income
                        HapticFeedback.buttonTap()
                    }
                    
                    PrimaryButton("Save", icon: "checkmark") {
                        saveConfiguration()
                        HapticFeedback.buttonTap()
                        dismiss()
                    }
                }
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    currentStep = .costOfLiving
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadExistingValues() {
        guard let profile = profile else { return }
        
        if let takeHome = profile.takeHomePay {
            takeHomePay = takeHome
        }
        if let frequency = profile.payFrequency {
            payFrequency = frequency
        }
        if let hours = profile.hoursWorkedPerWeek {
            hoursWorkedPerWeek = hours
        }
        if let housing = profile.monthlyHousing {
            monthlyHousing = housing
        }
        if let food = profile.monthlyFood {
            monthlyFood = food
        }
        if let utilities = profile.monthlyUtilities {
            monthlyUtilities = utilities
        }
        if let transportation = profile.monthlyTransportation {
            monthlyTransportation = transportation
        }
        if let insurance = profile.monthlyInsurance {
            monthlyInsurance = insurance
        }
        if let debt = profile.monthlyDebt {
            monthlyDebt = debt
        }
    }
    
    private func saveConfiguration() {
        guard let profile = profile else { return }
        
        profile.takeHomePay = takeHomePay
        profile.payFrequency = payFrequency
        profile.hoursWorkedPerWeek = hoursWorkedPerWeek
        profile.monthlyHousing = monthlyHousing
        profile.monthlyFood = monthlyFood
        profile.monthlyUtilities = monthlyUtilities
        profile.monthlyTransportation = monthlyTransportation
        profile.monthlyInsurance = monthlyInsurance
        profile.monthlyDebt = monthlyDebt
        
        // trueHourlyWage is computed, so we don't need to save it
        
        try? modelContext.save()
    }
}

// MARK: - Supporting Views

struct CostOfLivingRow: View {
    let label: String
    @Binding var amount: Decimal
    
    @State private var textValue: String = ""
    
    var body: some View {
        HStack {
            Text(label)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Spacer()
            
            HStack(spacing: SpendLessSpacing.xs) {
                Text("$")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                TextField("0", text: $textValue)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .keyboardType(.decimalPad)
                    .multilineTextAlignment(.trailing)
                    .frame(width: 100)
                    .onChange(of: textValue) { _, newValue in
                        // Filter to only numbers and decimal
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        if filtered != newValue {
                            textValue = filtered
                        }
                        // Update the decimal value
                        amount = Decimal(string: filtered) ?? 0
                    }
                    .onChange(of: amount) { _, newValue in
                        if newValue > 0 && textValue.isEmpty {
                            textValue = "\(newValue)"
                        }
                    }
            }
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        .onAppear {
            if amount > 0 {
                textValue = "\(amount)"
            }
        }
    }
}

struct BreakdownRow: View {
    let label: String
    let value: String
    var isHighlighted: Bool = false
    
    var body: some View {
        HStack {
            Text(label)
                .font(isHighlighted ? SpendLessFont.bodyBold : SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Spacer()
            
            Text(value)
                .font(isHighlighted ? SpendLessFont.bodyBold : SpendLessFont.body)
                .foregroundStyle(isHighlighted ? Color.spendLessPrimary : Color.spendLessTextPrimary)
        }
    }
}

struct PayFrequencyChip: View {
    let frequency: PayFrequency
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(frequency.displayName)
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

struct WarningBanner: View {
    let message: String
    let type: WarningType
    
    enum WarningType {
        case warning
        case error
        
        var color: Color {
            switch self {
            case .warning: return Color.orange
            case .error: return Color.spendLessError
            }
        }
        
        var icon: String {
            switch self {
            case .warning: return "exclamationmark.triangle"
            case .error: return "xmark.circle"
            }
        }
    }
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.sm) {
            Image(systemName: type.icon)
                .foregroundStyle(type.color)
            
            Text(message)
                .font(SpendLessFont.caption)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .padding(SpendLessSpacing.sm)
        .background(type.color.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.sm))
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        LifeEnergyCalculatorView()
    }
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

#Preview("With Profile") {
    let config = ModelConfiguration(isStoredInMemoryOnly: true)
    let container = try! ModelContainer(for: UserProfile.self, configurations: config)
    
    // Create a profile with life energy configured
    let profile = UserProfile()
    profile.takeHomePay = 2000
    profile.payFrequency = .biweekly
    profile.hoursWorkedPerWeek = 40
    profile.monthlyHousing = 1400
    profile.monthlyFood = 500
    profile.monthlyUtilities = 200
    profile.monthlyTransportation = 300
    profile.monthlyInsurance = 200
    profile.monthlyDebt = 400
    container.mainContext.insert(profile)
    
    return NavigationStack {
        LifeEnergyCalculatorView()
    }
    .modelContainer(container)
}
