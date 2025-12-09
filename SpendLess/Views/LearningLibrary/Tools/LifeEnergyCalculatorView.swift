//
//  LifeEnergyCalculatorView.swift
//  SpendLess
//
//  Life Energy Calculator - One-time setup tool to calculate true hourly wage
//

import SwiftUI
import SwiftData

// MARK: - Life Energy Calculator Flow

enum LifeEnergyStep: Int, CaseIterable {
    case setupPrompt
    case calculator
    case confirmation
}

struct LifeEnergyCalculatorView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var currentStep: LifeEnergyStep = .setupPrompt
    
    // Calculator inputs
    @State private var takeHomePay: Decimal = 0
    @State private var payFrequency: PayFrequency = .biweekly
    @State private var hoursWorkedPerWeek: Int = 40
    @State private var monthlyWorkExpenses: Decimal = 0
    
    // Validation
    @State private var showLowWageWarning = false
    @State private var showHighWageWarning = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var hasExistingConfiguration: Bool {
        profile?.hasConfiguredLifeEnergy == true
    }
    
    private var calculatedHourlyWage: Decimal {
        ToolCalculationService.trueHourlyWage(
            takeHome: takeHomePay,
            frequency: payFrequency,
            hoursPerWeek: hoursWorkedPerWeek,
            monthlyExpenses: monthlyWorkExpenses
        )
    }
    
    private var canCalculate: Bool {
        takeHomePay > 0 && hoursWorkedPerWeek > 0
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            switch currentStep {
            case .setupPrompt:
                setupPromptView
            case .calculator:
                calculatorView
            case .confirmation:
                confirmationView
            }
        }
        .navigationTitle("Life Energy")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            // If already configured, go straight to confirmation
            if hasExistingConfiguration {
                loadExistingValues()
                currentStep = .confirmation
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
            Text("Know what your time is really worth")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
                .multilineTextAlignment(.center)
            
            // Description
            VStack(spacing: SpendLessSpacing.md) {
                Text("Calculate your true hourly wage — after taxes, commute, and work expenses.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                
                Text("Once set, we'll automatically show you how many hours of life any purchase costs.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            Spacer()
            
            // Get Started button
            PrimaryButton("Get Started", icon: "arrow.right") {
                currentStep = .calculator
                HapticFeedback.buttonTap()
            }
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    // MARK: - Screen 2: Calculator
    
    private var calculatorView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Take-home pay
                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("Your take-home pay")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("(after taxes, per paycheck)")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    CurrencyTextField(title: "", amount: $takeHomePay)
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
                    
                    Text("(including commute, prep, etc.)")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
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
                
                // Work-related expenses
                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("Work-related expenses (monthly)")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("Commute, clothes, lunches, etc.")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    CurrencyTextField(title: "", amount: $monthlyWorkExpenses)
                }
                
                Divider()
                    .padding(.vertical, SpendLessSpacing.md)
                
                // Live calculation
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("Your true hourly wage:")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                    
                    Text(canCalculate ? ToolCalculationService.formatCurrencyWithCents(calculatedHourlyWage) : "$0.00")
                        .font(.system(size: 48, weight: .bold))
                        .foregroundStyle(canCalculate ? Color.spendLessPrimary : Color.spendLessTextMuted)
                    
                    // Warnings
                    if canCalculate {
                        if calculatedHourlyWage < 5 {
                            WarningBanner(
                                message: "This seems low — double-check your numbers?",
                                type: .warning
                            )
                        } else if calculatedHourlyWage > 500 {
                            WarningBanner(
                                message: "This seems high — double-check your numbers?",
                                type: .warning
                            )
                        }
                    }
                }
                
                Spacer()
                    .frame(height: SpendLessSpacing.xl)
                
                // Save button
                PrimaryButton("Save", icon: "checkmark") {
                    saveAndContinue()
                }
                .disabled(!canCalculate)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .padding(.horizontal, SpendLessSpacing.md)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    if hasExistingConfiguration {
                        currentStep = .confirmation
                    } else {
                        currentStep = .setupPrompt
                    }
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    // MARK: - Screen 3: Confirmation
    
    private var confirmationView: some View {
        VStack(spacing: SpendLessSpacing.xl) {
            Spacer()
            
            // Success icon
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 60))
                .foregroundStyle(Color.spendLessSuccess)
            
            Text("Your true hourly wage")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Text(ToolCalculationService.formatCurrencyWithCents(calculatedHourlyWage))
                .font(.system(size: 48, weight: .bold))
                .foregroundStyle(Color.spendLessPrimary)
            
            Divider()
                .padding(.horizontal, SpendLessSpacing.xl)
            
            // Explanation
            VStack(spacing: SpendLessSpacing.md) {
                Text("Now when you add items to your Waiting List, you'll see how many hours of life they cost.")
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                
                // Example
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("Example:")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    
                    let examplePrice: Decimal = 89
                    let exampleHours = ToolCalculationService.lifeEnergyHours(
                        amount: examplePrice,
                        hourlyWage: calculatedHourlyWage
                    )
                    
                    Text("$89 headphones = \(ToolCalculationService.formatLifeEnergyHours(exampleHours))")
                        .font(SpendLessFont.bodyBold)
                        .foregroundStyle(Color.spendLessTextPrimary)
                }
                .padding(SpendLessSpacing.md)
                .background(Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            
            Spacer()
            Spacer()
            
            // Action buttons
            VStack(spacing: SpendLessSpacing.sm) {
                SecondaryButton("Recalculate", icon: "arrow.counterclockwise") {
                    currentStep = .calculator
                    HapticFeedback.buttonTap()
                }
                
                PrimaryButton("Done", icon: "checkmark") {
                    HapticFeedback.buttonTap()
                    dismiss()
                }
            }
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.bottom, SpendLessSpacing.xl)
        }
    }
    
    // MARK: - Helper Functions
    
    private func loadExistingValues() {
        guard let profile = profile else { return }
        
        if profile.trueHourlyWage != nil {
            // We have the calculated wage, but need to load the inputs
            if let takeHome = profile.takeHomePay {
                takeHomePay = takeHome
            }
            if let frequency = profile.payFrequency {
                payFrequency = frequency
            }
            if let hours = profile.hoursWorkedPerWeek {
                hoursWorkedPerWeek = hours
            }
            if let expenses = profile.monthlyWorkExpenses {
                monthlyWorkExpenses = expenses
            }
        }
    }
    
    private func saveAndContinue() {
        guard canCalculate else { return }
        
        // Save to profile
        if let profile = profile {
            profile.trueHourlyWage = calculatedHourlyWage
            profile.takeHomePay = takeHomePay
            profile.payFrequency = payFrequency
            profile.hoursWorkedPerWeek = hoursWorkedPerWeek
            profile.monthlyWorkExpenses = monthlyWorkExpenses
            
            try? modelContext.save()
        }
        
        HapticFeedback.buttonTap()
        currentStep = .confirmation
    }
}

// MARK: - Supporting Views

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
    profile.trueHourlyWage = 21.50
    profile.takeHomePay = 2400
    profile.payFrequency = .biweekly
    profile.hoursWorkedPerWeek = 50
    profile.monthlyWorkExpenses = 200
    container.mainContext.insert(profile)
    
    return NavigationStack {
        LifeEnergyCalculatorView()
    }
    .modelContainer(container)
}

