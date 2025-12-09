//
//  ThirtyXRuleView.swift
//  SpendLess
//
//  30x Rule Check - Quick yes/no filter to evaluate if a purchase is worth it
//

import SwiftUI
import SwiftData

// MARK: - 30x Rule Flow

enum ThirtyXRuleStep {
    case input
    case result
}

struct ThirtyXRuleView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var currentStep: ThirtyXRuleStep = .input
    
    // Input state
    @State private var itemName: String = ""
    @State private var itemPrice: Decimal = 0
    @State private var usageAnswer: ThirtyXAnswer?
    @State private var versatilityAnswer: ThirtyXAnswer?
    @State private var practicalityAnswer: ThirtyXAnswer?
    
    // Navigation
    @State private var showAddToWaitingList = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var canProceed: Bool {
        !itemName.isEmpty &&
        itemPrice > 0 &&
        usageAnswer != nil &&
        versatilityAnswer != nil &&
        practicalityAnswer != nil
    }
    
    private var result: ThirtyXResult? {
        guard let usage = usageAnswer,
              let versatility = versatilityAnswer,
              let practicality = practicalityAnswer else {
            return nil
        }
        return ThirtyXResult.evaluate(
            usage: usage,
            versatility: versatility,
            practicality: practicality
        )
    }
    
    private var costPerUseAt30: Decimal {
        ToolCalculationService.costPerUseAt30(price: itemPrice)
    }
    
    // Detect category from item name for adaptive questions
    private var detectedCategory: ItemCategory {
        let nameLower = itemName.lowercased()
        
        if nameLower.contains("jacket") || nameLower.contains("dress") || nameLower.contains("shirt") || nameLower.contains("pants") || nameLower.contains("sweater") || nameLower.contains("coat") || nameLower.contains("jeans") {
            return .clothing
        } else if nameLower.contains("shoe") || nameLower.contains("boot") || nameLower.contains("sneaker") || nameLower.contains("heel") || nameLower.contains("sandal") {
            return .shoes
        } else if nameLower.contains("lipstick") || nameLower.contains("mascara") || nameLower.contains("foundation") || nameLower.contains("eyeshadow") || nameLower.contains("makeup") || nameLower.contains("blush") {
            return .makeup
        } else if nameLower.contains("serum") || nameLower.contains("moisturizer") || nameLower.contains("cleanser") || nameLower.contains("skincare") || nameLower.contains("cream") || nameLower.contains("toner") {
            return .skincare
        } else if nameLower.contains("game") || nameLower.contains("console") || nameLower.contains("controller") || nameLower.contains("playstation") || nameLower.contains("xbox") || nameLower.contains("nintendo") {
            return .gaming
        } else if nameLower.contains("headphone") || nameLower.contains("phone") || nameLower.contains("laptop") || nameLower.contains("tablet") || nameLower.contains("watch") || nameLower.contains("speaker") {
            return .electronics
        }
        
        return .default
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            switch currentStep {
            case .input:
                inputView
            case .result:
                resultView
            }
        }
        .navigationTitle("30x Rule Check")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAddToWaitingList) {
            AddToWaitingListWithPrefill(
                name: itemName,
                amount: itemPrice,
                onDismiss: {
                    showAddToWaitingList = false
                }
            )
        }
    }
    
    // MARK: - Input View
    
    private var inputView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Item name
                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("What are you thinking of buying?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    SpendLessTextField(
                        "",
                        text: $itemName,
                        placeholder: "e.g., Denim jacket"
                    )
                }
                .padding(.top, SpendLessSpacing.md)
                
                // Item price
                VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
                    Text("How much does it cost?")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    CurrencyTextField(title: "", amount: $itemPrice)
                }
                
                Divider()
                    .padding(.vertical, SpendLessSpacing.sm)
                
                // Question 1: Usage
                questionSection(
                    question: usageQuestion,
                    answer: $usageAnswer
                )
                
                // Question 2: Versatility
                questionSection(
                    question: versatilityQuestion,
                    answer: $versatilityAnswer
                )
                
                // Question 3: Practicality
                questionSection(
                    question: practicalityQuestion,
                    answer: $practicalityAnswer
                )
                
                Spacer()
                    .frame(height: SpendLessSpacing.xl)
                
                // See Results button
                PrimaryButton("See Results", icon: "checkmark.circle") {
                    currentStep = .result
                    HapticFeedback.buttonTap()
                }
                .disabled(!canProceed)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .padding(.horizontal, SpendLessSpacing.md)
        }
    }
    
    // MARK: - Result View
    
    private var resultView: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.lg) {
                // Result header
                VStack(spacing: SpendLessSpacing.md) {
                    Text(result?.emoji ?? "")
                        .font(.system(size: 60))
                    
                    Text(result?.title ?? "")
                        .font(SpendLessFont.title2)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text("\(itemName) · \(ToolCalculationService.formatCurrency(itemPrice))")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                }
                .padding(.top, SpendLessSpacing.xl)
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.md)
                
                // Answer breakdown
                VStack(spacing: SpendLessSpacing.sm) {
                    answerRow(
                        question: "Will use 30+ times?",
                        answer: usageAnswer
                    )
                    answerRow(
                        question: "Versatile?",
                        answer: versatilityAnswer
                    )
                    answerRow(
                        question: "Fits your life?",
                        answer: practicalityAnswer
                    )
                }
                .padding(.horizontal, SpendLessSpacing.md)
                
                // Cost per use insight (for pass result)
                if result == .pass {
                    VStack(spacing: SpendLessSpacing.xs) {
                        Text("At 30 uses, that's \(ToolCalculationService.formatCurrencyWithCents(costPerUseAt30))/use.")
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                    }
                    .padding(SpendLessSpacing.md)
                    .frame(maxWidth: .infinity)
                    .background(Color.spendLessCardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .padding(.horizontal, SpendLessSpacing.md)
                }
                
                // Result message
                if let result = result, result == .uncertain {
                    Text(result.message)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SpendLessSpacing.lg)
                }
                
                Divider()
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.vertical, SpendLessSpacing.sm)
                
                // Action buttons
                VStack(spacing: SpendLessSpacing.sm) {
                    // Add to Waiting List (always available)
                    ActionButton(
                        icon: "📝",
                        title: result == .pass ? "Add to Waiting List anyway" : "Add to Waiting List",
                        action: {
                            showAddToWaitingList = true
                        }
                    )
                    
                    // Bury it (only for fail result)
                    if result == .fail {
                        ActionButton(
                            icon: "⚰️",
                            title: "Bury it",
                            action: {
                                buryItem()
                            }
                        )
                    }
                    
                    // Done
                    ActionButton(
                        icon: "✓",
                        title: "Done",
                        action: {
                            dismiss()
                        }
                    )
                }
                .padding(.horizontal, SpendLessSpacing.md)
                .padding(.bottom, SpendLessSpacing.xl)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button {
                    currentStep = .input
                } label: {
                    HStack(spacing: 4) {
                        Image(systemName: "chevron.left")
                        Text("Back")
                    }
                }
            }
        }
    }
    
    // MARK: - Question Helpers
    
    private var usageQuestion: String {
        switch detectedCategory {
        case .clothing:
            return "Will you wear this 30+ times?"
        case .shoes:
            return "Will you wear these 30+ times?"
        case .makeup:
            return "Will you use this up before it expires?"
        case .skincare:
            return "Will you use this consistently?"
        case .gaming:
            return "Will you get 30+ hours from this?"
        case .electronics:
            return "Will you use this weekly for 6+ months?"
        case .default:
            return "Will you use this 30+ times?"
        }
    }
    
    private var versatilityQuestion: String {
        switch detectedCategory {
        case .clothing:
            return "Can you style this 5+ ways?"
        case .shoes:
            return "Do these work for 3+ occasions?"
        case .makeup:
            return "Can you use this 3+ ways?"
        case .skincare:
            return "Does this work with your current products?"
        case .gaming:
            return "Will this stay fun long-term?"
        case .electronics:
            return "Does this replace or add to what you have?"
        case .default:
            return "Can you use this in 5+ contexts?"
        }
    }
    
    private var practicalityQuestion: String {
        switch detectedCategory {
        case .clothing:
            return "Does it fit you now and suit your lifestyle?"
        case .shoes:
            return "Are these comfortable for your daily life?"
        case .makeup:
            return "Does this fit your current routine?"
        case .skincare:
            return "Is this right for your skin type now?"
        case .gaming:
            return "Do you have time for this right now?"
        case .electronics:
            return "Do you have space and need for this?"
        case .default:
            return "Does it fit your life right now?"
        }
    }
    
    // MARK: - Supporting Views
    
    private func questionSection(question: String, answer: Binding<ThirtyXAnswer?>) -> some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
            Text(question)
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                ForEach(ThirtyXAnswer.allCases) { option in
                    AnswerChip(
                        title: option.displayName,
                        isSelected: answer.wrappedValue == option
                    ) {
                        answer.wrappedValue = option
                        HapticFeedback.buttonTap()
                    }
                }
            }
        }
    }
    
    private func answerRow(question: String, answer: ThirtyXAnswer?) -> some View {
        HStack {
            answerIcon(for: answer)
            
            Text(answerText(for: question, answer: answer))
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            Spacer()
        }
        .padding(SpendLessSpacing.sm)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.sm))
    }
    
    private func answerIcon(for answer: ThirtyXAnswer?) -> some View {
        Group {
            switch answer {
            case .yes:
                Image(systemName: "checkmark.circle.fill")
                    .foregroundStyle(Color.spendLessSuccess)
            case .no:
                Image(systemName: "xmark.circle.fill")
                    .foregroundStyle(Color.spendLessError)
            case .notSure:
                Image(systemName: "questionmark.circle.fill")
                    .foregroundStyle(Color.orange)
            case .none:
                Image(systemName: "circle")
                    .foregroundStyle(Color.spendLessTextMuted)
            }
        }
        .font(.title3)
    }
    
    private func answerText(for question: String, answer: ThirtyXAnswer?) -> String {
        let baseText: String
        
        if question.contains("30+") || question.contains("use") {
            baseText = answer == .yes ? "You'll use it enough" : (answer == .no ? "Won't use it enough" : "Not sure about usage")
        } else if question.contains("Versatile") || question.contains("contexts") || question.contains("ways") {
            baseText = answer == .yes ? "It's versatile" : (answer == .no ? "Not versatile enough" : "Not sure about versatility")
        } else {
            baseText = answer == .yes ? "It fits your life" : (answer == .no ? "Doesn't fit your life" : "Not sure about fit")
        }
        
        return baseText
    }
    
    // MARK: - Actions
    
    private func buryItem() {
        // Create graveyard item
        let graveyardItem = GraveyardItem(
            name: itemName,
            amount: itemPrice,
            source: .manual
        )
        modelContext.insert(graveyardItem)
        try? modelContext.save()
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        dismiss()
    }
}

// MARK: - Item Category

enum ItemCategory {
    case clothing
    case shoes
    case makeup
    case skincare
    case gaming
    case electronics
    case `default`
}

// MARK: - Supporting Views

struct AnswerChip: View {
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
                .frame(maxWidth: .infinity)
                .background(isSelected ? Color.spendLessPrimary : Color.spendLessCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .buttonStyle(.plain)
    }
}

struct ActionButton: View {
    let icon: String
    let title: String
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.md) {
                Text(icon)
                    .font(.title3)
                
                Text(title)
                    .font(SpendLessFont.bodyBold)
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

// MARK: - Add to Waiting List with Prefill

struct AddToWaitingListWithPrefill: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    let name: String
    let amount: Decimal
    let onDismiss: () -> Void
    
    @State private var itemName: String = ""
    @State private var itemAmount: Decimal = 0
    @State private var selectedReason: ReasonWanted?
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: SpendLessSpacing.lg) {
                        VStack(spacing: SpendLessSpacing.xs) {
                            Text("Add to Waiting List")
                                .font(SpendLessFont.title2)
                                .foregroundStyle(Color.spendLessTextPrimary)
                            
                            Text("Wait 7 days before buying")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                        .padding(.top, SpendLessSpacing.lg)
                        
                        VStack(spacing: SpendLessSpacing.md) {
                            SpendLessTextField(
                                "Item name",
                                text: $itemName,
                                placeholder: "What is it?"
                            )
                            
                            CurrencyTextField(title: "Price", amount: $itemAmount)
                        }
                        .padding(.horizontal, SpendLessSpacing.md)
                        
                        Spacer()
                    }
                }
                
                // Bottom action
                VStack {
                    Spacer()
                    
                    PrimaryButton("Add to Waiting List", icon: "clock") {
                        addItem()
                    }
                    .disabled(itemName.isEmpty || itemAmount <= 0)
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
            .onAppear {
                itemName = name
                itemAmount = amount
            }
        }
    }
    
    private func addItem() {
        let item = WaitingListItem(
            name: itemName,
            amount: itemAmount,
            reasonWanted: selectedReason
        )
        modelContext.insert(item)
        try? modelContext.save()
        
        // Schedule Day 3 and Day 6 notifications
        NotificationManager.shared.scheduleWaitingListNotifications(
            itemID: item.id,
            itemName: item.name,
            addedAt: item.addedAt
        )
        
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
        
        onDismiss()
        dismiss()
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ThirtyXRuleView()
    }
    .modelContainer(for: [UserProfile.self, WaitingListItem.self, GraveyardItem.self], inMemory: true)
}
