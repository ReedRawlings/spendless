//
//  PaywallView.swift
//  SpendLess
//
//  Custom StoreKit 2 Paywall - warm, supportive design
//

import SwiftUI
import StoreKit

/// Simple paywall view matching the app's warm design system
struct SpendLessPaywallView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(SubscriptionService.self) private var subscriptionService

    /// Optional callback for onboarding context. When nil, uses standard dismiss().
    var onComplete: (() -> Void)?

    @State private var products: [Product] = []
    @State private var selectedProduct: Product?
    @State private var isLoading = true
    @State private var isPurchasing = false
    @State private var errorMessage: String?

    // Animation states
    @State private var headerVisible = false
    @State private var benefitsVisible = false
    @State private var plansVisible = false
    @State private var buttonVisible = false
    
    var body: some View {
        ZStack {
            // Warm background
            Color.spendLessBackground.ignoresSafeArea()
            
            if isLoading {
                ProgressView()
                    .scaleEffect(1.2)
            } else {
                ScrollView {
                    VStack(spacing: SpendLessSpacing.xl) {
                        // Close button
                        HStack {
                            Spacer()
                            Button {
                                handleCompletion()
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundStyle(Color.spendLessTextMuted)
                                    .padding(SpendLessSpacing.sm)
                                    .background(Color.spendLessBackgroundSecondary)
                                    .clipShape(Circle())
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                        .padding(.top, SpendLessSpacing.sm)
                        
                        // Header
                        VStack(spacing: SpendLessSpacing.md) {
                            Image(systemName: "sparkles")
                                .font(.system(size: 48))
                                .foregroundStyle(Color.spendLessGold)
                            
                            Text("You're ready to take control")
                                .font(SpendLessFont.title)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .multilineTextAlignment(.center)
                            
                            Text("Unlock all the tools to break the cycle and start saving for what matters.")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, SpendLessSpacing.md)
                        }
                        .opacity(headerVisible ? 1 : 0)
                        .offset(y: headerVisible ? 0 : 20)
                        
                        // Benefits
                        VStack(spacing: SpendLessSpacing.sm) {
                            BenefitRow(icon: "shield.fill", text: "Block shopping apps when you need it")
                            BenefitRow(icon: "clock.fill", text: "7-day waiting list for impulse buys")
                            BenefitRow(icon: "target", text: "Track progress toward your goals")
                            BenefitRow(icon: "wind", text: "Breathing exercises for tough moments")
                        }
                        .padding(SpendLessSpacing.lg)
                        .background(Color.spendLessCardBackground)
                        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
                        .padding(.horizontal, SpendLessSpacing.lg)
                        .opacity(benefitsVisible ? 1 : 0)
                        .offset(y: benefitsVisible ? 0 : 20)
                        
                        // Subscription options
                        VStack(spacing: SpendLessSpacing.sm) {
                            ForEach(products.sorted { $0.price > $1.price }, id: \.id) { product in
                                SubscriptionOption(
                                    product: product,
                                    isSelected: selectedProduct?.id == product.id,
                                    isAnnual: product.id == AppConstants.ProductIdentifiers.annual
                                ) {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        selectedProduct = product
                                        HapticFeedback.lightSuccess()
                                    }
                                }
                            }
                        }
                        .padding(.horizontal, SpendLessSpacing.lg)
                        .opacity(plansVisible ? 1 : 0)
                        .offset(y: plansVisible ? 0 : 20)
                        
                        // Error message
                        if let error = errorMessage {
                            Text(error)
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessError)
                                .multilineTextAlignment(.center)
                                .padding(.horizontal, SpendLessSpacing.lg)
                        }
                        
                        // CTA Button
                        VStack(spacing: SpendLessSpacing.md) {
                            PrimaryButton(
                                isPurchasing ? "Processing..." : "Start Free Trial",
                                icon: isPurchasing ? nil : "arrow.right",
                                isLoading: isPurchasing,
                                isDisabled: selectedProduct == nil
                            ) {
                                Task {
                                    await handlePurchase()
                                }
                            }
                            .padding(.horizontal, SpendLessSpacing.lg)
                            
                            // Trial reminder
                            Text("Try free for 3 days, then \(selectedProduct?.displayPrice ?? "$6.99")/\(selectedProduct?.id == AppConstants.ProductIdentifiers.annual ? "year" : "month")")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        .opacity(buttonVisible ? 1 : 0)
                        .offset(y: buttonVisible ? 0 : 20)
                        
                        // Footer
                        VStack(spacing: SpendLessSpacing.sm) {
                            Button {
                                Task {
                                    await handleRestore()
                                }
                            } label: {
                                Text("Restore Purchases")
                                    .font(SpendLessFont.callout)
                                    .foregroundStyle(Color.spendLessTextSecondary)
                            }
                            
                            Text("Cancel anytime. No questions asked.")
                                .font(SpendLessFont.caption)
                                .foregroundStyle(Color.spendLessTextMuted)
                        }
                        .padding(.bottom, SpendLessSpacing.xxl)
                    }
                }
            }
        }
        .task {
            await loadProducts()
            animateIn()
        }
    }
    
    // MARK: - Actions
    
    private func loadProducts() async {
        do {
            products = try await subscriptionService.getAvailableProducts()
            // Default to annual (better value)
            selectedProduct = products.first { $0.id == AppConstants.ProductIdentifiers.annual }
                ?? products.first
            isLoading = false
        } catch {
            errorMessage = "Unable to load subscription options"
            isLoading = false
        }
    }
    
    private func animateIn() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation(.easeOut(duration: 0.4)) {
                headerVisible = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeOut(duration: 0.4)) {
                benefitsVisible = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.4) {
            withAnimation(.easeOut(duration: 0.4)) {
                plansVisible = true
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.55) {
            withAnimation(.easeOut(duration: 0.4)) {
                buttonVisible = true
            }
        }
    }
    
    private func handlePurchase() async {
        guard let product = selectedProduct else { return }

        isPurchasing = true
        errorMessage = nil

        do {
            _ = try await subscriptionService.purchase(product)
            HapticFeedback.celebration()
            handleCompletion()
        } catch SubscriptionError.purchaseCancelled {
            // User cancelled - no error message needed
        } catch {
            errorMessage = "Something went wrong. Please try again."
        }

        isPurchasing = false
    }

    private func handleRestore() async {
        isPurchasing = true
        errorMessage = nil

        do {
            try await subscriptionService.restorePurchases()
            if subscriptionService.hasProAccess {
                HapticFeedback.celebration()
                handleCompletion()
            } else {
                errorMessage = "No active subscription found"
            }
        } catch {
            errorMessage = "Unable to restore purchases"
        }

        isPurchasing = false
    }

    /// Handle completion - uses onComplete callback for onboarding, dismiss() for settings
    private func handleCompletion() {
        if let onComplete {
            onComplete()
        } else {
            dismiss()
        }
    }
}

// MARK: - Benefit Row

private struct BenefitRow: View {
    let icon: String
    let text: String
    
    var body: some View {
        HStack(spacing: SpendLessSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 16))
                .foregroundStyle(Color.spendLessSecondary)
                .frame(width: 24)
            
            Text(text)
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Spacer()
        }
    }
}

// MARK: - Subscription Option

private struct SubscriptionOption: View {
    let product: Product
    let isSelected: Bool
    let isAnnual: Bool
    let onTap: () -> Void
    
    var body: some View {
        Button(action: onTap) {
            HStack(spacing: SpendLessSpacing.md) {
                // Selection circle
                Circle()
                    .strokeBorder(isSelected ? Color.spendLessPrimary : Color.spendLessTextMuted, lineWidth: 2)
                    .background(
                        Circle()
                            .fill(isSelected ? Color.spendLessPrimary : Color.clear)
                            .padding(5)
                    )
                    .frame(width: 24, height: 24)
                
                // Plan details
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: SpendLessSpacing.xs) {
                        Text(isAnnual ? "Annual" : "Monthly")
                            .font(SpendLessFont.headline)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        if isAnnual {
                            Text("Save 50%")
                                .font(SpendLessFont.caption)
                                .fontWeight(.semibold)
                                .foregroundStyle(Color.spendLessSecondary)
                                .padding(.horizontal, SpendLessSpacing.xs)
                                .padding(.vertical, 2)
                                .background(Color.spendLessSecondary.opacity(0.15))
                                .clipShape(Capsule())
                        }
                    }
                    
                    Text("3-day free trial")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                
                Spacer()
                
                // Price
                VStack(alignment: .trailing, spacing: 2) {
                    Text(product.displayPrice)
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                    
                    Text(isAnnual ? "/year" : "/month")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
            }
            .padding(SpendLessSpacing.md)
            .background(
                RoundedRectangle(cornerRadius: SpendLessRadius.md)
                    .fill(Color.spendLessCardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(
                                isSelected ? Color.spendLessPrimary : Color.clear,
                                lineWidth: 2
                            )
                    )
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - View Modifier

struct PaywallModifier: ViewModifier {
    @Binding var isPresented: Bool
    
    func body(content: Content) -> some View {
        content
            .sheet(isPresented: $isPresented) {
                SpendLessPaywallView()
            }
    }
}

extension View {
    func presentPaywall(isPresented: Binding<Bool>) -> some View {
        modifier(PaywallModifier(isPresented: isPresented))
    }
}

#Preview {
    SpendLessPaywallView()
        .environment(SubscriptionService.shared)
}
