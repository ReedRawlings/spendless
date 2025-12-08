//
//  TemporaryAccessActivity.swift
//  SpendLess
//
//  Live Activity widget for 10-minute temporary access countdown timer
//  Displays in Dynamic Island and Lock Screen
//

import Foundation
import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes

struct TemporaryAccessAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var startTime: Date
        var endTime: Date
        var appName: String
        
        var timeRemaining: TimeInterval {
            max(0, endTime.timeIntervalSinceNow)
        }
        
        var minutesRemaining: Int {
            Int(ceil(timeRemaining / 60.0))
        }
        
        var secondsRemaining: Int {
            Int(timeRemaining) % 60
        }
        
        var isExpired: Bool {
            timeRemaining <= 0
        }
    }
    
    var appName: String
}

// MARK: - Activity Widget

@available(iOS 16.1, *)
struct TemporaryAccessActivityWidget: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: TemporaryAccessAttributes.self) { context in
            // Lock Screen / Expanded Dynamic Island
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: "timer")
                        .foregroundColor(.orange)
                    Text("Temporary Access")
                        .font(.headline)
                    Spacer()
                }
                
                Text("\(context.attributes.appName)")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                HStack {
                    Text("Time remaining:")
                        .font(.caption)
                        .foregroundColor(.secondary)
                    Spacer()
                    Text(formatTimeRemaining(context.state.timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                        .foregroundColor(.primary)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.1))
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded region
                DynamicIslandExpandedRegion(.leading) {
                    HStack {
                        Image(systemName: "timer")
                            .foregroundColor(.orange)
                        Text("Temporary Access")
                            .font(.caption)
                    }
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    Text(formatTimeRemaining(context.state.timeRemaining))
                        .font(.title2)
                        .fontWeight(.bold)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(context.attributes.appName)")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                        Text("Shield will restore automatically")
                            .font(.caption)
                            .foregroundColor(.secondary)
                    }
                }
            } compactLeading: {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
            } compactTrailing: {
                Text(formatTimeRemaining(context.state.timeRemaining))
                    .font(.caption2)
                    .fontWeight(.semibold)
            } minimal: {
                Image(systemName: "timer")
                    .foregroundColor(.orange)
            }
        }
    }
    
    private func formatTimeRemaining(_ timeRemaining: TimeInterval) -> String {
        guard timeRemaining > 0 else {
            return "0:00"
        }
        
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

