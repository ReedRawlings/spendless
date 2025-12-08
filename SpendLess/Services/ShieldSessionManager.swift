//
//  ShieldSessionManager.swift
//  SpendLess
//
//  Manages temporary access sessions and coordinates restoration
//

import Foundation
import ActivityKit
import ManagedSettings

@MainActor
@Observable
final class ShieldSessionManager {
    
    // MARK: - Singleton
    
    static let shared = ShieldSessionManager()
    
    // MARK: - Dependencies
    
    private let analytics = ShieldAnalytics.shared
    private let screenTimeManager = ScreenTimeManager.shared
    private let notificationManager = NotificationManager.shared
    
    // MARK: - State
    
    private(set) var currentSession: TemporaryAccessSession?
    
    // MARK: - Initialization
    
    private init() {
        // Load current session on init
        loadCurrentSession()
    }
    
    // MARK: - Session Management
    
    /// Check for active/expired sessions and handle accordingly
    func checkSessions() {
        // Check for pending Live Activity start requests from extensions
        checkPendingLiveActivityStart()
        
        // Check for pending Live Activity end requests
        checkPendingLiveActivityEnd()
        
        // Check if notification was tapped
        checkNotificationTap()
        
        // Load and check current session
        loadCurrentSession()
        
        guard let session = currentSession else {
            return
        }
        
        // Check if session has expired
        if session.isExpired {
            restoreShieldForExpiredSession(session)
        } else if session.isActive {
            // Session is still active, ensure Live Activity is running
            ensureLiveActivityRunning(for: session)
        }
    }
    
    /// Check if a notification was tapped and mark session accordingly
    private func checkNotificationTap() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard sharedDefaults?.bool(forKey: "notificationTapped") == true else {
            return
        }
        
        // Clear the flag
        sharedDefaults?.removeObject(forKey: "notificationTapped")
        sharedDefaults?.synchronize()
        
        // Update current session to mark notification as tapped
        if var session = analytics.getCurrentSession() {
            session.markNotificationTapped()
            analytics.updateCurrentSession(session)
            currentSession = session
        }
    }
    
    /// Handle early restoration (user manually restores before 10 min)
    func restoreShieldEarly() {
        guard var session = currentSession else {
            return
        }
        
        session.markRestoredManually()
        session.end()
        
        // Update session
        analytics.updateCurrentSession(session)
        
        // Restore shields
        screenTimeManager.restoreShields()
        
        // End Live Activity
        endLiveActivity()
        
        // Cancel notification
        notificationManager.cancelRestoreNotification()
        
        // Clear current session
        analytics.clearCurrentSession()
        currentSession = nil
        
        print("[ShieldSessionManager] Shield restored early by user")
    }
    
    /// Detect and handle orphaned sessions (apps unlocked but no session record)
    func detectOrphanedSessions() {
        let store = ManagedSettingsStore()
        
        // Check if shields are removed but we have no active session
        let hasNoShields = store.shield.applications == nil && 
                          store.shield.applicationCategories == nil &&
                          store.shield.webDomains == nil
        
        if hasNoShields && currentSession == nil {
            // Check if there's a session in history that might be orphaned
            let sessions = analytics.getAllSessions()
            if let recentSession = sessions.first(where: { $0.isActive || $0.isExpired }) {
                // Found orphaned session, restore shields
                print("[ShieldSessionManager] Detected orphaned session, restoring shields")
                screenTimeManager.restoreShields()
                
                // Mark session as ended
                var updatedSession = recentSession
                updatedSession.end()
                analytics.updateCurrentSession(updatedSession)
            }
        }
    }
    
    // MARK: - Private Helpers
    
    private func loadCurrentSession() {
        currentSession = analytics.getCurrentSession()
    }
    
    private func restoreShieldForExpiredSession(_ session: TemporaryAccessSession) {
        var updatedSession = session
        updatedSession.end()
        
        // Update session
        analytics.updateCurrentSession(updatedSession)
        
        // Restore shields
        screenTimeManager.restoreShields()
        
        // End Live Activity
        endLiveActivity()
        
        // Cancel notification (it may have already fired)
        notificationManager.cancelRestoreNotification()
        
        // Clear current session
        analytics.clearCurrentSession()
        currentSession = nil
        
        print("[ShieldSessionManager] Shield restored for expired session")
    }
    
    private func ensureLiveActivityRunning(for session: TemporaryAccessSession) {
        // Check if Live Activity should be running
        if #available(iOS 16.1, *) {
            let activityManager = ActivityManager.shared
            if !activityManager.hasActiveActivity {
                // Start Live Activity
                startLiveActivity(for: session)
            }
        }
    }
    
    private func checkPendingLiveActivityStart() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard let jsonString = sharedDefaults?.string(forKey: AppConstants.SessionKeys.pendingLiveActivityStart),
              let jsonData = jsonString.data(using: .utf8),
              let activityData = try? JSONSerialization.jsonObject(with: jsonData) as? [String: Any],
              let appName = activityData["appName"] as? String,
              let startTimeString = activityData["startTime"] as? String,
              let endTimeString = activityData["endTime"] as? String,
              let startTime = ISO8601DateFormatter().date(from: startTimeString),
              let endTime = ISO8601DateFormatter().date(from: endTimeString) else {
            return
        }
        
        // Clear the flag
        sharedDefaults?.removeObject(forKey: AppConstants.SessionKeys.pendingLiveActivityStart)
        sharedDefaults?.synchronize()
        
        // Start Live Activity
        if #available(iOS 16.1, *) {
            ActivityManager.shared.startActivity(
                appName: appName,
                startTime: startTime,
                endTime: endTime
            )
        }
    }
    
    private func checkPendingLiveActivityEnd() {
        let sharedDefaults = UserDefaults(suiteName: AppConstants.appGroupID)
        guard sharedDefaults?.bool(forKey: AppConstants.SessionKeys.pendingLiveActivityEnd) == true else {
            return
        }
        
        // Clear the flag
        sharedDefaults?.removeObject(forKey: AppConstants.SessionKeys.pendingLiveActivityEnd)
        sharedDefaults?.synchronize()
        
        // End Live Activity
        endLiveActivity()
    }
    
    private func startLiveActivity(for session: TemporaryAccessSession) {
        if #available(iOS 16.1, *) {
            ActivityManager.shared.startActivity(
                appName: session.triggeringAppName,
                startTime: session.startTimestamp,
                endTime: session.scheduledEndTimestamp
            )
        }
    }
    
    private func endLiveActivity() {
        if #available(iOS 16.1, *) {
            ActivityManager.shared.endActivity()
        }
    }
}

