//
//  PrimaryButton.swift
//  SpendLess
//
//  Primary action button with warm styling
//

import SwiftUI

struct PrimaryButton: View {
    let title: String
    let icon: String?
    let isLoading: Bool
    let isDisabled: Bool
    let action: () -> Void
    
    init(
        _ title: String,
        icon: String? = nil,
        isLoading: Bool = false,
        isDisabled: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isLoading = isLoading
        self.isDisabled = isDisabled
        self.action = action
    }
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xs) {
                if isLoading {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .scaleEffect(0.9)
                } else {
                    if let icon {
                        Image(systemName: icon)
                            .font(.body.weight(.semibold))
                    }
                    Text(title)
                        .font(SpendLessFont.headline)
                }
            }
            .foregroundStyle(.white)
            .frame(maxWidth: .infinity)
            .padding(.vertical, SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(isDisabled ? Color.spendLessTextMuted : Color.spendLessPrimary)
            )
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .disabled(isDisabled || isLoading)
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .accessibilityLabel(title)
    }
}

// MARK: - Pressable Button Style

struct PressableButtonStyle: ButtonStyle {
    @Binding var isPressed: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .onChange(of: configuration.isPressed) { _, newValue in
                isPressed = newValue
            }
    }
}

// MARK: - Small Primary Button Variant

struct SmallPrimaryButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    
    init(_ title: String, icon: String? = nil, action: @escaping () -> Void) {
        self.title = title
        self.icon = icon
        self.action = action
    }
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: SpendLessSpacing.xxs) {
                if let icon {
                    Image(systemName: icon)
                        .font(.caption.weight(.semibold))
                }
                Text(title)
                    .font(SpendLessFont.subheadline)
                    .fontWeight(.semibold)
            }
            .foregroundStyle(.white)
            .padding(.horizontal, SpendLessSpacing.md)
            .padding(.vertical, SpendLessSpacing.xs)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.sm)
                    .fill(Color.spendLessPrimary)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    VStack(spacing: 20) {
        PrimaryButton("Get Started") {
            print("Tapped")
        }
        
        PrimaryButton("Continue", icon: "arrow.right") {
            print("Tapped")
        }
        
        PrimaryButton("Loading...", isLoading: true) {
            print("Tapped")
        }
        
        PrimaryButton("Disabled", isDisabled: true) {
            print("Tapped")
        }
        
        SmallPrimaryButton("Bury it", icon: "leaf.fill") {
            print("Small tap")
        }
    }
    .padding()
    .background(Color.spendLessBackground)
}

