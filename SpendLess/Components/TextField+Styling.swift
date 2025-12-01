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
                .foregroundStyle(Color.spendLessTextSecondary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                if let icon {
                    Image(systemName: icon)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                
                TextField(placeholder, text: $text)
                    .font(SpendLessFont.body)
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
                .foregroundStyle(Color.spendLessTextSecondary)
            
            HStack(spacing: SpendLessSpacing.sm) {
                Text("$")
                    .font(SpendLessFont.title3)
                    .foregroundStyle(Color.spendLessTextMuted)
                
                TextField("0", text: $textValue)
                    .font(SpendLessFont.title3)
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

