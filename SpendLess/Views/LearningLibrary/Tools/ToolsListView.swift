//
//  ToolsListView.swift
//  SpendLess
//
//  Main tools list view - interactive calculators and frameworks
//

import SwiftUI
import SwiftData

struct ToolsListView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var profiles: [UserProfile]
    
    @State private var selectedTool: ToolType?
    @State private var showDopamineMenu = false
    @State private var showOpportunityCost = false
    @State private var showPricePerWear = false
    @State private var showThirtyXRule = false
    @State private var showSpendingAudit = false
    
    private var profile: UserProfile? {
        profiles.first
    }
    
    var body: some View {
        ZStack {
            Color.spendLessBackground.ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: SpendLessSpacing.md) {
                    // Header
                    header
                    
                    // Tools Grid
                    toolsGrid
                }
                .padding(SpendLessSpacing.md)
            }
        }
        .navigationTitle("Tools")
        .navigationBarTitleDisplayMode(.large)
        .navigationDestination(isPresented: $showDopamineMenu) {
            DopamineMenuView()
        }
        .navigationDestination(isPresented: $showOpportunityCost) {
            OpportunityCostView()
        }
        .navigationDestination(isPresented: $showPricePerWear) {
            PricePerWearView()
        }
        .navigationDestination(isPresented: $showThirtyXRule) {
            ThirtyXRuleView()
        }
        .navigationDestination(isPresented: $showSpendingAudit) {
            SpendingAuditView()
        }
    }
    
    // MARK: - Header
    
    private var header: some View {
        VStack(alignment: .leading, spacing: SpendLessSpacing.xs) {
            Text("Decision Tools")
                .font(SpendLessFont.title2)
                .foregroundStyle(Color.spendLessTextPrimary)
            
            Text("Calculators and frameworks to help you decide")
                .font(SpendLessFont.body)
                .foregroundStyle(Color.spendLessTextSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
    // MARK: - Tools Grid
    
    private var toolsGrid: some View {
        LazyVGrid(columns: [
            GridItem(.flexible(), spacing: SpendLessSpacing.md),
            GridItem(.flexible(), spacing: SpendLessSpacing.md)
        ], spacing: SpendLessSpacing.md) {
            ForEach(ToolType.allCases) { tool in
                ToolCard(tool: tool, isEnabled: tool.isV1) {
                    navigateToTool(tool)
                }
            }
        }
    }
    
    // MARK: - Navigation
    
    private func navigateToTool(_ tool: ToolType) {
        guard tool.isV1 else { return }
        HapticFeedback.buttonTap()
        
        switch tool {
        case .dopamineMenu:
            showDopamineMenu = true
        case .opportunityCost:
            showOpportunityCost = true
        case .pricePerWear:
            showPricePerWear = true
        case .thirtyXRule:
            showThirtyXRule = true
        case .spendingAudit:
            showSpendingAudit = true
        }
    }
}

// MARK: - Tool Card

struct ToolCard: View {
    let tool: ToolType
    let isEnabled: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            if isEnabled {
                action()
            }
        }) {
            VStack(spacing: SpendLessSpacing.sm) {
                // Icon
                Text(tool.icon)
                    .font(.system(size: 44))
                    .opacity(isEnabled ? 1.0 : 0.5)
                
                // Title
                Text(tool.name)
                    .font(SpendLessFont.headline)
                    .foregroundStyle(isEnabled ? Color.spendLessTextPrimary : Color.spendLessTextMuted)
                    .multilineTextAlignment(.center)
                
                // Description
                Text(tool.description)
                    .font(SpendLessFont.caption)
                    .foregroundStyle(Color.spendLessTextSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
                
                // Coming soon badge for V2 tools
                if !isEnabled {
                    Text("Coming Soon")
                        .font(SpendLessFont.caption2)
                        .foregroundStyle(.white)
                        .padding(.horizontal, SpendLessSpacing.xs)
                        .padding(.vertical, SpendLessSpacing.xxs)
                        .background(Color.spendLessTextMuted)
                        .clipShape(Capsule())
                }
            }
            .frame(maxWidth: .infinity)
            .padding(SpendLessSpacing.lg)
            .background(Color.spendLessCardBackground)
            .clipShape(RoundedRectangle(cornerRadius: SpendLessRadius.lg))
            .spendLessShadow(SpendLessShadow.cardShadow)
            .opacity(isEnabled ? 1.0 : 0.7)
            .scaleEffect(isPressed ? 0.97 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        }
        .buttonStyle(PressableButtonStyle(isPressed: $isPressed))
        .disabled(!isEnabled)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        ToolsListView()
    }
    .environment(AppState.shared)
    .modelContainer(for: [UserProfile.self], inMemory: true)
}

