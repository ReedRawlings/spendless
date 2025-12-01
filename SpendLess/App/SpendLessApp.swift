//
//  SpendLessApp.swift
//  SpendLess
//
//  Main app entry point
//

import SwiftUI
import SwiftData

@main
struct SpendLessApp: App {
    
    // MARK: - SwiftData Container
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self,
        ])
        
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            groupContainer: .automatic // Will use App Groups when configured
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    // MARK: - App State
    
    @State private var appState = AppState.shared
    
    // MARK: - Body
    
    var body: some Scene {
        WindowGroup {
            RootView()
                .environment(appState)
                .onOpenURL { url in
                    handleDeepLink(url)
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    // MARK: - Deep Linking
    
    private func handleDeepLink(_ url: URL) {
        guard url.scheme == "spendless" else { return }
        
        switch url.host {
        case "addToWaitingList":
            // Navigate to add waiting list item
            // This will be handled by the view that needs to show the add flow
            appState.pendingDeepLink = "addToWaitingList"
            
        case "breathingExercise":
            // Show breathing exercise
            appState.pendingDeepLink = "breathingExercise"
            
        case "panicButton":
            // Show panic button flow
            appState.pendingDeepLink = "panicButton"
            
        default:
            break
        }
    }
}

// MARK: - Root View (handles onboarding vs main app)

struct RootView: View {
    @Environment(AppState.self) private var appState
    
    var body: some View {
        Group {
            if appState.hasCompletedOnboarding {
                MainTabView()
            } else {
                OnboardingCoordinatorView()
            }
        }
        .animation(.easeInOut(duration: 0.3), value: appState.hasCompletedOnboarding)
    }
}

#Preview {
    RootView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

