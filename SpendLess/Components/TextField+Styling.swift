//
//  TextField+Styling.swift
//  SpendLess
//
//  Styled text fields for the app
//

import SwiftUI

// MARK: - Styled Text Field

struct SpendLessTextField: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let icon: String?
    let keyboardType: UIKeyboardType
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "",
        icon: String? = nil,
        keyboardType: UIKeyboardType = .default
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.icon = icon
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text(title)
                .font(SpendLessFont.subheadline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                
                TextField(placeholder, text: $text)
                    .font(SpendLessFont.body)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .keyboardType(keyboardType)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
    }
}

// MARK: - Currency Text Field

struct CurrencyTextField: View {
    let title: String
    @Binding var amount: Decimal
    
    @State private var textValue: String = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text(title)
                .font(SpendLessFont.subheadline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                Text("$")
                    .font(SpendLessFont.title3)
                    .foregroundStyle(Color.spendLessTextPrimary)
                
                TextField("0", text: $textValue)
                    .font(SpendLessFont.title3)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .keyboardType(.decimalPad)
                    .onChange(of: textValue) { _, newValue in
                        // Filter to only numbers and decimal
                        let filtered = newValue.filter { $0.isNumber || $0 == "." }
                        if filtered != newValue {
                            textValue = filtered
                        }
                        // Update the decimal value
                        amount = Decimal(string: filtered) ?? 0
                    }
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
        .onAppear {
            if amount > 0 {
                textValue = "\(amount)"
            }
        }
    }
}

// MARK: - Stepper Input

struct StepperInput: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let step: Int
    
    init(
        _ title: String,
        value: Binding<Int>,
        range: ClosedRange<Int> = 0...999,
        step: Int = 1
    ) {
        self.title = title
        self._value = value
        self.range = range
        self.step = step
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text(title)
                .font(SpendLessFont.subheadline)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            HStack(spacing: SpendLessSpacing.md) {
                // Decrement button
                Button {
                    if value - step >= range.lowerBound {
                        value -= step
                        HapticFeedback.buttonTap()
                    }
                } label: {
                    Image(systemName: "minus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(value > range.lowerBound ? Color.spendLessPrimary : Color.spendLessTextMuted)
                        .frame(width: 44, height: 44)
                        .background(Color.spendLessBackgroundSecondary)
                        .clipShape(Circle())
                }
                .disabled(value <= range.lowerBound)
                
                // Value display
                Text("\(value)")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .frame(minWidth: 60)
                    .multilineTextAlignment(.center)
                
                // Increment button
                Button {
                    if value + step <= range.upperBound {
                        value += step
                        HapticFeedback.buttonTap()
                    }
                } label: {
                    Image(systemName: "plus")
                        .font(.title3.weight(.semibold))
                        .foregroundStyle(value < range.upperBound ? Color.spendLessPrimary : Color.spendLessTextMuted)
                        .frame(width: 44, height: 44)
                        .background(Color.spendLessBackgroundSecondary)
                        .clipShape(Circle())
                }
                .disabled(value >= range.upperBound)
            }
            .padding(SpendLessSpacing.md)
            .background(Color.spendLessBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
    }
}

// MARK: - Compact Stepper Input (for inline use)

struct CompactStepperInput: View {
    @Binding var value: Int
    let range: ClosedRange<Int>
    
    init(value: Binding<Int>, range: ClosedRange<Int> = 0...999) {
        self._value = value
        self.range = range
    }
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.sm) {
            // Decrement button
            Button {
                if value > range.lowerBound {
                    value -= 1
                    HapticFeedback.buttonTap()
                }
            } label: {
                Image(systemName: "minus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(value > range.lowerBound ? Color.spendLessPrimary : Color.spendLessTextMuted)
            }
            .disabled(value <= range.lowerBound)
            
            // Value
            Text("\(value)")
                .font(SpendLessFont.headline)
                .foregroundStyle(Color.spendLessTextPrimary)
                .frame(minWidth: 30)
                .multilineTextAlignment(.center)
            
            // Increment button
            Button {
                if value < range.upperBound {
                    value += 1
                    HapticFeedback.buttonTap()
                }
            } label: {
                Image(systemName: "plus.circle.fill")
                    .font(.title2)
                    .foregroundStyle(value < range.upperBound ? Color.spendLessPrimary : Color.spendLessTextMuted)
            }
            .disabled(value >= range.upperBound)
        }
    }
}

// MARK: - Multi-line Text Field

struct SpendLessTextEditor: View {
    let title: String
    @Binding var text: String
    let placeholder: String
    let minHeight: CGFloat
    
    init(
        _ title: String,
        text: Binding<String>,
        placeholder: String = "",
        minHeight: CGFloat = 100
    ) {
        self.title = title
        self._text = text
        self.placeholder = placeholder
        self.minHeight = minHeight
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text(title)
                .font(SpendLessFont.subheadline)
                .foregroundStyle(Color.spendLessTextSecondary)
            
            ZStack(alignment: .topLeading) {
                if text.isEmpty {
                    Text(placeholder)
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextMuted)
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                }
                
                TextEditor(text: $text)
                    .font(SpendLessFont.body)
                    .scrollContentBackground(.hidden)
                    .frame(minHeight: minHeight)
            }
            .padding(SpendLessSpacing.sm)
            .background(Color.spendLessBackgroundSecondary)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
        }
    }
}

// MARK: - Preview

#Preview {
    struct PreviewWrapper: View {
        @State private var text = ""
        @State private var amount: Decimal = 0
        @State private var longText = ""
        
        var body: some View {
            VStack(spacing: 20) {
                SpendLessTextField(
                    "Item Name",
                    text: $text,
                    placeholder: "What is it?",
                    icon: "tag"
                )
                
                CurrencyTextField(title: "How much?", amount: $amount)
                
                SpendLessTextEditor(
                    "Why do you want it?",
                    text: $longText,
                    placeholder: "Optional: Tell us why..."
                )
            }
            .padding()
            .background(Color.spendLessBackground)
        }
    }
    
    return PreviewWrapper()
}

#Preview("Stepper Input") {
    struct PreviewWrapper: View {
        @State private var quantity = 5
        @State private var hours = 40
        
        var body: some View {
            VStack(spacing: 20) {
                StepperInput("Quantity", value: $quantity, range: 0...99)
                StepperInput("Hours per week", value: $hours, range: 0...168, step: 5)
                
                HStack {
                    Text("Compact:")
                    CompactStepperInput(value: $quantity, range: 0...99)
                }
            }
            .padding()
            .background(Color.spendLessBackground)
        }
    }
    
    return PreviewWrapper()
}

