//
//  LeadMagnetView.swift
//  SpendLess
//
//  Email collection screen for Self-Compassion Guide lead magnet
//

import SwiftUI
import SwiftData

struct LeadMagnetView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    let source: LeadMagnetSource
    let onComplete: () -> Void
    let onSkip: (() -> Void)?
    
    @State private var email: String = ""
    @State private var optedIntoMarketing: Bool = false
    @State private var isSubmitting: Bool = false
    @State private var showSuccess: Bool = false
    @State private var errorMessage: String?
    @State private var showError: Bool = false
    
    @Query private var profiles: [UserProfile]
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    private var isValidEmail: Bool {
        let emailRegex = #"^[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$"#
        let emailPredicate = NSPredicate(format: "SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
    
    var body: some View {
        if showSuccess {
            LeadMagnetSuccessView(
                email: email,
                onContinue: {
                    onComplete()
                }
            )
        } else {
            mainContent
        }
    }
    
    private var mainContent: some View {
        ScrollView {
            VStack(spacing: SpendLessSpacing.xl) {
                // Add top padding since OnboardingContainer handles the background
                Spacer()
                    .frame(height: SpendLessSpacing.md)
                // Lottie animation placeholder (can be added later)
                // For now, using a simple icon
                Image(systemName: "gift.fill")
                    .font(.system(size: 60))
                    .foregroundStyle(Color.spendLessPrimary)
                    .padding(.top, SpendLessSpacing.xxl)
                
                // Headline
                VStack(spacing: SpendLessSpacing.sm) {
                    Text("A Gift For Your Journey")
                        .font(SpendLessFont.title)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .multilineTextAlignment(.center)
                    
                    Text("Get our free Self-Compassion Guide—your reset button when slip-ups happen.")
                        .font(SpendLessFont.body)
                        .foregroundStyle(Color.spendLessTextSecondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, SpendLessSpacing.lg)
                }
                
                // Stacked card preview
                StackedCardPreview()
                    .padding(.horizontal, SpendLessSpacing.lg)
                
                // Email input
                VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                    HStack(spacing: SpendLessSpacing.sm) {
                        Image(systemName: "envelope")
                            .foregroundStyle(Color.spendLessTextMuted)
                        
                        TextField("Enter your email", text: $email)
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextPrimary)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                            .textContentType(.emailAddress)
                    }
                    .padding(SpendLessSpacing.md)
                    .background(Color.spendLessBackgroundSecondary)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    
                    if !email.isEmpty && !isValidEmail {
                        Text("Please enter a valid email address")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessError)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Marketing opt-in checkbox
                Button {
                    optedIntoMarketing.toggle()
                } label: {
                    HStack(alignment: .top, spacing: SpendLessSpacing.sm) {
                        Image(systemName: optedIntoMarketing ? "checkmark.square.fill" : "square")
                            .foregroundStyle(optedIntoMarketing ? Color.spendLessPrimary : Color.spendLessTextMuted)
                            .font(.system(size: 20))
                        
                        Text("Send me occasional tips on mindful spending (optional)")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.leading)
                    }
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Submit button
                PrimaryButton(
                    "Send My Free Guide",
                    isLoading: isSubmitting,
                    isDisabled: !isValidEmail || email.isEmpty
                ) {
                    submitEmail()
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Legal text
                VStack(spacing: SpendLessSpacing.xs) {
                    Text("By continuing, you agree to our")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                    +
                    Text(" Privacy Policy")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessPrimary)
                    +
                    Text(". Unsubscribe anytime.")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextMuted)
                }
                .multilineTextAlignment(.center)
                .padding(.horizontal, SpendLessSpacing.lg)
                
                // Skip link (only show if onSkip is provided)
                if let onSkip {
                    Button {
                        onSkip()
                    } label: {
                        Text("Skip for now")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                    .padding(.bottom, SpendLessSpacing.xl)
                } else {
                    // Add bottom padding if no skip button
                    Spacer()
                        .frame(height: SpendLessSpacing.xl)
                }
            }
        }
        .background(source == .settings ? Color.spendLessBackground : Color.clear)
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) {}
        } message: {
            if let errorMessage {
                Text(errorMessage)
            }
        }
    }
    
    private func submitEmail() {
        guard isValidEmail else { return }
        
        isSubmitting = true
        errorMessage = nil
        
        Task {
            do {
                // Submit to MailerLite
                try await MailerLiteService.shared.submitEmailForPDF(
                    email: email,
                    optedIntoMarketing: optedIntoMarketing,
                    source: source
                )
                
                // Save to profile
                await MainActor.run {
                    if let profile {
                        profile.leadMagnetEmailCollected = true
                        profile.leadMagnetEmailAddress = email
                        profile.leadMagnetOptedIntoMarketing = optedIntoMarketing
                        profile.leadMagnetCollectedAt = Date()
                        profile.leadMagnetSource = source
                        
                        try? modelContext.save()
                    }
                    
                    // Track analytics (if available)
                    // Analytics.track(.leadMagnetSubmitSuccess, properties: ["source": source.rawValue])
                    
                    withAnimation {
                        showSuccess = true
                    }
                }
            } catch let error as EmailSubmissionError {
                await MainActor.run {
                    errorMessage = error.errorDescription
                    showError = true
                    isSubmitting = false
                    
                    // If network error, queue for retry
                    if case .networkError = error {
                        let pending = PendingEmailSubmission(
                            email: email,
                            optedIntoMarketing: optedIntoMarketing,
                            source: source,
                            queuedAt: Date()
                        )
                        PendingSubmissionsStore.shared.add(pending)
                    }
                }
            } catch {
                await MainActor.run {
                    errorMessage = "Something went wrong. Please try again."
                    showError = true
                    isSubmitting = false
                }
            }
        }
    }
}

// MARK: - Preview

#Preview {
    LeadMagnetView(
        source: .onboarding,
        onComplete: {},
        onSkip: {}
    )
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

