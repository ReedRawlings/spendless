//
//  CommitmentDetailView.swift
//  SpendLess
//
//  View for displaying user's commitment details
//

import SwiftUI
import SwiftData
import PencilKit

struct CommitmentDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @Query private var profiles: [UserProfile]
    // Query only active goals to avoid loading all goals into memory
    @Query(filter: #Predicate<UserGoal> { $0.isActive }) private var activeGoals: [UserGoal]

    @State private var showRenewSignature = false

    private var profile: UserProfile? {
        profiles.first
    }

    private var currentGoal: UserGoal? {
        activeGoals.first
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.lg) {
                    // Commitment text and signature
                    Card {
                        VStack(spacing: SpendLessSpacing.md) {
                            if let goalType = profile?.goalType {
                                Text(generateCommitmentText(
                                    goalType: goalType,
                                    goalName: currentGoal?.name
                                ))
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .multilineTextAlignment(.center)
                            }
                            
                            if let signatureData = profile?.signatureImageData,
                               let uiImage = UIImage(data: signatureData) {
                                Image(uiImage: uiImage)
                                    .resizable()
                                    .aspectRatio(contentMode: .fit)
                                    .frame(height: 120)
                                    .frame(maxWidth: .infinity)
                                    .padding(.top, SpendLessSpacing.sm)
                            }
                            
                            if let commitmentDate = profile?.commitmentDate {
                                Text(formatCommitmentDate(commitmentDate))
                                    .font(SpendLessFont.caption)
                                    .foregroundStyle(Color.spendLessTextMuted)
                                    .padding(.top, SpendLessSpacing.xs)
                            }
                        }
                        .padding(SpendLessSpacing.lg)
                    }
                    .padding(.horizontal, SpendLessSpacing.md)
                    .padding(.top, SpendLessSpacing.lg)
                    
                    // Letter section
                    if let letterText = profile?.futureLetterText, !letterText.isEmpty {
                        VStack(alignment: .leading, spacing: SpendLessSpacing.sm) {
                            Text("MY LETTER TO MYSELF")
                                .font(SpendLessFont.headline)
                                .foregroundStyle(Color.spendLessTextPrimary)
                                .padding(.horizontal, SpendLessSpacing.md)
                            
                            Card {
                                Text(letterText)
                                    .font(SpendLessFont.body)
                                    .foregroundStyle(Color.spendLessTextPrimary)
                                    .multilineTextAlignment(.leading)
                                    .padding(SpendLessSpacing.md)
                            }
                            .padding(.horizontal, SpendLessSpacing.md)
                        }
                    }
                    
                    // Renew commitment button
                    PrimaryButton("Renew My Commitment") {
                        showRenewSignature = true
                    }
                    .padding(.horizontal, SpendLessSpacing.lg)
                    .padding(.bottom, SpendLessSpacing.xl)
                }
            }
        }
        .navigationTitle("My Commitment")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showRenewSignature) {
            RenewCommitmentView()
        }
    }
}

// MARK: - Renew Commitment View

struct RenewCommitmentView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    
    @Query private var profiles: [UserProfile]
    
    @State private var drawing = PKDrawing()
    @State private var showSignatureSheet = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color.spendLessBackground.ignoresSafeArea()
                
                VStack(spacing: SpendLessSpacing.lg) {
                    Spacer()
                    
                    VStack(spacing: SpendLessSpacing.md) {
                        Text("✍️")
                            .font(.system(size: 50))
                        
                        Text("Renew your commitment")
                            .font(SpendLessFont.title2)
                            .foregroundStyle(Color.spendLessTextPrimary)
                        
                        if let goalType = profile?.goalType {
                            Text(generateCommitmentText(
                                goalType: goalType,
                                goalName: nil
                            ))
                            .font(SpendLessFont.body)
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, SpendLessSpacing.lg)
                        }
                    }
                    
                    if let existingSignature = profile?.signatureImageData,
                       let uiImage = UIImage(data: existingSignature) {
                        Image(uiImage: uiImage)
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(height: 100)
                            .frame(maxWidth: .infinity)
                    } else {
                        VStack(spacing: SpendLessSpacing.sm) {
                            Image(systemName: "pencil.tip")
                                .font(.system(size: 40))
                                .foregroundStyle(Color.spendLessTextMuted)
                            
                            Text("Tap to sign")
                                .font(SpendLessFont.body)
                                .foregroundStyle(Color.spendLessTextSecondary)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 150)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(SpendLessSpacing.xl)
                .background(
                    RoundedRectangle(cornerRadius: SpendLessRadius.lg)
                        .strokeBorder(Color.spendLessTextMuted, lineWidth: 2)
                )
                .onTapGesture {
                    showSignatureSheet = true
                }
                .padding(.horizontal, SpendLessSpacing.lg)
                
                Spacer()
                
                PrimaryButton("Save") {
                    saveRenewal()
                }
                .disabled(profile?.signatureImageData == nil)
                .padding(.horizontal, SpendLessSpacing.lg)
                .padding(.bottom, SpendLessSpacing.xl)
            }
            .navigationTitle("Renew Commitment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }
            }
            .sheet(isPresented: $showSignatureSheet) {
                SignatureSheetView { signatureData, date in
                    profile?.signatureImageData = signatureData
                    profile?.commitmentDate = date
                    try? modelContext.save()
                }
            }
        }
    }
    
    private func saveRenewal() {
        guard let profile = profile,
              profile.signatureImageData != nil else {
            return
        }

        // Sync to App Groups
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        if let letterText = profile.futureLetterText, !letterText.isEmpty {
            sharedDefaults?.set(letterText, forKey: "futureLetterText")
        }

        try? modelContext.save()
        dismiss()
    }
}

// MARK: - Signature Sheet View

struct SignatureSheetView: View {
    @Environment(\.dismiss) private var dismiss

    let onSave: (Data, Date) -> Void

    @State private var canvasView = PKCanvasView()
    @State private var drawing = PKDrawing()

    var body: some View {
        NavigationStack {
            ZStack {
                Color.white.ignoresSafeArea()

                VStack(spacing: SpendLessSpacing.lg) {
                    Text("Sign with your finger")
                        .font(SpendLessFont.headline)
                        .foregroundStyle(Color.spendLessTextPrimary)
                        .padding(.top, SpendLessSpacing.lg)

                    // Signature canvas
                    SignatureCanvasRepresentable(
                        canvasView: $canvasView,
                        drawing: $drawing
                    )
                    .frame(height: 300)
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.md))
                    .overlay(
                        RoundedRectangle(cornerRadius: SpendLessRadius.md)
                            .strokeBorder(Color.spendLessTextMuted, lineWidth: 1)
                    )
                    .padding(.horizontal, SpendLessSpacing.md)

                    Button("Clear") {
                        drawing = PKDrawing()
                        canvasView.drawing = PKDrawing()
                    }
                    .foregroundStyle(Color.spendLessError)

                    Spacer()
                }
            }
            .navigationTitle("Sign Your Commitment")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .confirmationAction) {
                    Button("Done") {
                        saveSignature()
                    }
                    .disabled(drawing.strokes.isEmpty)
                }
            }
        }
    }

    private func saveSignature() {
        let bounds = drawing.bounds

        guard !bounds.isEmpty else {
            return
        }

        // Add padding around signature
        let padding: CGFloat = 20
        let imageSize = CGSize(
            width: bounds.width + padding * 2,
            height: bounds.height + padding * 2
        )

        let renderer = UIGraphicsImageRenderer(size: imageSize)
        let image = renderer.image { context in
            // Transparent background
            UIColor.clear.setFill()
            context.fill(CGRect(origin: .zero, size: imageSize))

            // Center the drawing
            context.cgContext.translateBy(x: padding - bounds.minX, y: padding - bounds.minY)

            // Draw signature
            drawing.image(from: bounds, scale: UIScreen.main.scale).draw(at: .zero)
        }

        if let imageData = image.pngData() {
            onSave(imageData, Date())
        }
    }
}

// MARK: - Signature Canvas Representable

struct SignatureCanvasRepresentable: UIViewRepresentable {
    @Binding var canvasView: PKCanvasView
    @Binding var drawing: PKDrawing

    func makeUIView(context: Context) -> PKCanvasView {
        canvasView.drawingPolicy = .anyInput
        canvasView.tool = PKInkingTool(.pen, color: .black, width: 3)
        canvasView.backgroundColor = .clear
        canvasView.isOpaque = false
        canvasView.drawing = drawing
        canvasView.delegate = context.coordinator

        return canvasView
    }

    func updateUIView(_ uiView: PKCanvasView, context: Context) {
        uiView.drawing = drawing
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    class Coordinator: NSObject, PKCanvasViewDelegate {
        var parent: SignatureCanvasRepresentable

        init(_ parent: SignatureCanvasRepresentable) {
            self.parent = parent
        }

        func canvasViewDrawingDidChange(_ canvasView: PKCanvasView) {
            parent.drawing = canvasView.drawing
        }
    }
}

