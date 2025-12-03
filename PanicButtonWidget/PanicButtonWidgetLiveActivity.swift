//
//  PanicButtonWidgetLiveActivity.swift
//  PanicButtonWidget
//
//  Created by Reed Rawlings on 12/1/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct PanicButtonWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct PanicButtonWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PanicButtonWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension PanicButtonWidgetAttributes {
    fileprivate static var preview: PanicButtonWidgetAttributes {
        PanicButtonWidgetAttributes(name: "World")
    }
}

extension PanicButtonWidgetAttributes.ContentState {
    fileprivate static var smiley: PanicButtonWidgetAttributes.ContentState {
        PanicButtonWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: PanicButtonWidgetAttributes.ContentState {
         PanicButtonWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: PanicButtonWidgetAttributes.preview) {
   PanicButtonWidgetLiveActivity()
} contentStates: {
    PanicButtonWidgetAttributes.ContentState.smiley
    PanicButtonWidgetAttributes.ContentState.starEyes
}
