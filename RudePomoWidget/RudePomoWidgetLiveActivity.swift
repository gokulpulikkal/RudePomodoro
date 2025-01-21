//
//  RudePomoWidgetLiveActivity.swift
//  RudePomoWidget
//
//  Created by Gokul P on 1/20/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct RudePomoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct RudePomoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RudePomoWidgetAttributes.self) { context in
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

extension RudePomoWidgetAttributes {
    fileprivate static var preview: RudePomoWidgetAttributes {
        RudePomoWidgetAttributes(name: "World")
    }
}

extension RudePomoWidgetAttributes.ContentState {
    fileprivate static var smiley: RudePomoWidgetAttributes.ContentState {
        RudePomoWidgetAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: RudePomoWidgetAttributes.ContentState {
         RudePomoWidgetAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: RudePomoWidgetAttributes.preview) {
   RudePomoWidgetLiveActivity()
} contentStates: {
    RudePomoWidgetAttributes.ContentState.smiley
    RudePomoWidgetAttributes.ContentState.starEyes
}
