//
//  MainTabView.swift
//  SpendLess
//
//  Main tab bar navigation
//

import SwiftUI
import SwiftData

struct MainTabView: View {
    @State private var selectedTab: Tab = .home
    @Environment(\.modelContext) private var modelContext
    @Environment(AppState.self) private var appState
    
    enum Tab: String, CaseIterable {
        case home = "Home"
        case waitingList = "Waiting"
        case learn = "Learn"
        case settings = "Settings"
        
        var icon: String {
            switch self {
            case .home: return "house.fill"
            case .waitingList: return "clock.fill"
            case .learn: return "book.fill"
            case .settings: return "gearshape.fill"
            }
        }
    }
    
    var body: some View {
        TabView(selection: $selectedTab) {
            DashboardView()
                .tabItem {
                    Label(Tab.home.rawValue, systemImage: Tab.home.icon)
                }
                .tag(Tab.home)
            
            WaitingListView()
                .tabItem {
                    Label(Tab.waitingList.rawValue, systemImage: Tab.waitingList.icon)
                }
                .tag(Tab.waitingList)
            
            LearningLibraryView()
                .tabItem {
                    Label(Tab.learn.rawValue, systemImage: Tab.learn.icon)
                }
                .tag(Tab.learn)
            
            SettingsView()
                .tabItem {
                    Label(Tab.settings.rawValue, systemImage: Tab.settings.icon)
                }
                .tag(Tab.settings)
        }
        .tint(Color.spendLessPrimary)
    }
}

#Preview {
    MainTabView()
        .environment(AppState.shared)
        .modelContainer(for: [
            UserGoal.self,
            WaitingListItem.self,
            GraveyardItem.self,
            Streak.self,
            UserProfile.self
        ], inMemory: true)
}

