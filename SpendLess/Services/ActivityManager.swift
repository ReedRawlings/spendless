//
//  ActivityManager.swift
//  SpendLess
//
//  Manages Live Activity timers for temporary access sessions
//

import Foundation
import ActivityKit
import SwiftUI

@available(iOS 16.1, *)
@MainActor
final class ActivityManager {
    
    // MARK: - Singleton
    
    static let shared = ActivityManager()
    
    // MARK: - State
    
    private var currentActivity: Activity<TemporaryAccessAttributes>?
    private var updateTimer: Timer?
    
    // MARK: - Initialization
    
    private init() {}
    
    // MARK: - Start Activity
    
    /// Start a Live Activity for a temporary access session
    func startActivity(
        appName: String,
        startTime: Date,
        endTime: Date
    ) {
        // End any existing activity first
        endActivity()
        
        guard ActivityAuthorizationInfo().areActivitiesEnabled else {
            print("[ActivityManager] Live Activities are not enabled")
            return
        }
        
        let attributes = TemporaryAccessAttributes(appName: appName)
        let contentState = TemporaryAccessAttributes.ContentState(
            startTime: startTime,
            endTime: endTime,
            appName: appName
        )
        
        do {
            let content = ActivityContent(state: contentState, staleDate: nil)
            let activity = try Activity<TemporaryAccessAttributes>.request(
                attributes: attributes,
                content: content,
                pushType: nil
            )
            
            currentActivity = activity
            startUpdateTimer(endTime: endTime)
            
            print("[ActivityManager] Started Live Activity for \(appName)")
        } catch {
            print("[ActivityManager] Failed to start Live Activity: \(error)")
        }
    }
    
    // MARK: - Update Activity
    
    /// Update the current activity's timer
    private func updateActivity(endTime: Date) {
        guard let activity = currentActivity else { return }
        
        let contentState = TemporaryAccessAttributes.ContentState(
            startTime: activity.content.state.startTime,
            endTime: endTime,
            appName: activity.attributes.appName
        )
        
        Task {
            let content = ActivityContent(state: contentState, staleDate: nil)
            await activity.update(content)
        }
    }
    
    // MARK: - End Activity
    
    /// End the current Live Activity
    func endActivity() {
        updateTimer?.invalidate()
        updateTimer = nil
        
        guard let activity = currentActivity else { return }
        
        Task {
            let finalContentState = TemporaryAccessAttributes.ContentState(
                startTime: activity.content.state.startTime,
                endTime: Date(),
                appName: activity.attributes.appName
            )
            
            let content = ActivityContent(state: finalContentState, staleDate: nil)
            await activity.end(content, dismissalPolicy: .immediate)
            currentActivity = nil
            
            print("[ActivityManager] Ended Live Activity")
        }
    }
    
    // MARK: - Timer Management
    
    private func startUpdateTimer(endTime: Date) {
        updateTimer?.invalidate()
        
        // Update every second
        updateTimer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self = self else { return }
            
            let timeRemaining = endTime.timeIntervalSinceNow
            
            Task { @MainActor in
                if timeRemaining <= 0 {
                    // Session expired, end activity
                    self.endActivity()
                } else {
                    // Update activity with current time
                    self.updateActivity(endTime: endTime)
                }
            }
        }
    }
    
    // MARK: - Check Active Activity
    
    /// Check if there's an active Live Activity
    var hasActiveActivity: Bool {
        return currentActivity != nil
    }
}

// MARK: - Fallback for iOS < 16.1

final class ActivityManagerFallback {
    static let shared = ActivityManagerFallback()
    
    private init() {}
    
    func startActivity(appName: String, startTime: Date, endTime: Date) {
        print("[ActivityManager] Live Activities not available on this iOS version")
    }
    
    func endActivity() {
        // No-op
    }
    
    var hasActiveActivity: Bool {
        return false
    }
}

