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
        VStack(spacing: SpendLessSpacing.md) {
            // Headline - compact
            VStack(spacing: SpendLessSpacing.xs) {
                Text("A Gift For Your Journey")
                    .font(SpendLessFont.title2)
                    .foregroundStyle(Color.spendLessTextPrimary)
                    .multilineTextAlignment(.center)

                Text("Get our free Self-Compassion Guide—your reset button when slip-ups happen.")
                    .font(SpendLessFont.callout)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.top, SpendLessSpacing.lg)

            // Three content cards
            VStack(spacing: SpendLessSpacing.sm) {
                guideContentCard(
                    icon: "arrow.triangle.branch",
                    title: "The Two Pathways",
                    description: "Understand the choice you're making",
                    color: .spendLessSecondary
                )

                guideContentCard(
                    icon: "timer",
                    title: "3-Minute Reset",
                    description: "A quick exercise to regain control",
                    color: .spendLessGold
                )

                guideContentCard(
                    icon: "checkmark.circle.fill",
                    title: "Your Action Plan",
                    description: "Steps to get back on track",
                    color: .spendLessPrimary
                )
            }
            .padding(.horizontal, SpendLessSpacing.lg)

            // Email input
            VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
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
                HStack(alignment: .center, spacing: SpendLessSpacing.sm) {
                    Image(systemName: optedIntoMarketing ? "checkmark.square.fill" : "square")
                        .foregroundStyle(optedIntoMarketing ? Color.spendLessPrimary : Color.spendLessTextMuted)
                        .font(.system(size: 18))

                    Text("Send me tips on mindful spending")
                        .font(SpendLessFont.caption)
                        .foregroundStyle(Color.spendLessTextSecondary)
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

            // Legal text + Skip in same row
            HStack {
                (Text("By continuing, you agree to our ")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
                +
                Text("Privacy Policy")
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessPrimary))

                Spacer()

                if let onSkip {
                    Button {
                        onSkip()
                    } label: {
                        Text("Skip")
                            .font(SpendLessFont.caption)
                            .foregroundStyle(Color.spendLessTextMuted)
                    }
                }
            }
            .padding(.horizontal, SpendLessSpacing.lg)
            .padding(.bottom, SpendLessSpacing.lg)

            Spacer(minLength: 0)
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

    private func guideContentCard(icon: String, title: String, description: String, color: Color) -> some View {
        HStack(spacing: SpendLessSpacing.md) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundStyle(color)
                .frame(width: 32)

            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(SpendLessFont.bodyBold)
                    .foregroundStyle(Color.spendLessTextPrimary)

                Text(description)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextMuted)
            }

            Spacer()
        }
        .padding(SpendLessSpacing.md)
        .background(Color.spendLessCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
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

