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
        }
        .modelContainer(sharedModelContainer)
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

