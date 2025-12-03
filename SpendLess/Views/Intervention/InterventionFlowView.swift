//
//  InterventionFlowView.swift
//  SpendLess
//
//  Routes between different intervention steps
//

import SwiftUI

struct InterventionFlowView: View {
    @Bindable var manager: InterventionManager
    
    var body: some View {
        ZStack {
            // Full screen background with gradient
            LinearGradient(
                stops: [
                    .init(color: Color.spendLessBackground, location: 0),
                    .init(color: Color.spendLessBackground.opacity(0.97), location: 0.5),
                    .init(color: Color.warmSand, location: 1)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            // Current step
            Group {
                switch manager.currentStep {
                case .initial:
                    EmptyView()
                    
                case .breathing:
                    InterventionBreathingView(onComplete: manager.completeBreathing)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                    
                case .haltCheck:
                    InterventionHALTCheckView(
                        manager: manager,
                        onComplete: manager.completeHALTCheck
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
                    
                case .haltRedirect:
                    if let state = manager.selectedHALTState {
                        InterventionHALTRedirectView(
                            state: state,
                            onRedirectAccepted: manager.handleHALTRedirectAccepted,
                            onRedirectDeclined: manager.handleHALTRedirectDeclined
                        )
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                    } else {
                        // Fallback: if no state selected, continue to reflection
                        EmptyView()
                            .onAppear {
                                manager.currentStep = .reflection
                            }
                    }
                    
                case .goalReminder:
                    InterventionGoalReminderView(onComplete: manager.completeGoalReminder)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                    
                case .quickPause:
                    InterventionQuickPauseView(onComplete: manager.completeQuickPause)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .scale(scale: 0.95)),
                            removal: .opacity.combined(with: .scale(scale: 1.05))
                        ))
                    
                case .reflection:
                    InterventionReflectionView(
                        onJustBrowsing: manager.handleJustBrowsing,
                        onSomethingSpecific: manager.handleSomethingSpecific
                    )
                    .transition(.asymmetric(
                        insertion: .opacity.combined(with: .move(edge: .trailing)),
                        removal: .opacity.combined(with: .move(edge: .leading))
                    ))
                    
                case .logItem:
                    InterventionLogItemView(onItemLogged: manager.handleItemLogged)
                        .transition(.asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .trailing)),
                            removal: .opacity.combined(with: .move(edge: .leading))
                        ))
                    
                case .celebration:
                    InterventionCelebrationView(
                        isHALTRedirect: manager.isHALTRedirectCelebration,
                        onComplete: manager.completeIntervention
                    )
                    .transition(.opacity.combined(with: .scale(scale: 0.9)))
                    
                case .complete:
                    EmptyView()
                }
            }
            .animation(.spring(response: 0.4, dampingFraction: 0.8), value: manager.currentStep)
            
            // Close button
            VStack {
                HStack {
                    Spacer()
                    Button {
                        manager.completeIntervention()
                    } label: {
                        Image(systemName: "xmark")
                            .font(.body.weight(.medium))
                            .foregroundStyle(Color.spendLessTextSecondary)
                            .padding(SpendLessSpacing.sm)
                            .background(Color.spendLessBackgroundSecondary.opacity(0.8))
                            .clipShape(Circle())
                    }
                    .padding(.trailing, SpendLessSpacing.md)
                    .padding(.top, SpendLessSpacing.md)
                }
                Spacer()
            }
        }
    }
}

// MARK: - Preview

#Preview {
    InterventionFlowView(manager: .shared)
}

