//
//  RudePomoWidgetLiveActivity.swift
//  RudePomoWidget
//
//  Created by Gokul P on 1/20/25.
//

import ActivityKit
import SwiftUI
import WidgetKit

struct RudePomoWidgetAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var startDate: Date?
        var timerDuration: TimeInterval?
        var isDone: Bool?
    }

    /// Fixed non-changing properties about your activity go here!
    var name: String
}

struct RudePomoWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: RudePomoWidgetAttributes.self) { context in
            // Lock screen/banner UI goes here
            ZStack {
                Color(hex: "5E2929")
                if context.state.isDone != true, let startDate = context.state.startDate,
                   let duration = context.state.timerDuration
                {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Pomo is Sleeping")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                                .bold()
                                .opacity(0.7)
                            Text(
                                timerInterval: Date.now...Date(timeInterval: duration, since: startDate)
                            )
                            .foregroundStyle(.white)
                            .font(.system(size: 50))
                            .bold()
                        }
                        // TODO: Maybe show sleeping pomo animation with riv
                    }
                    .padding()
                } else if context.state.isDone == true, let duration = context.state.timerDuration {
                    HStack {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("ooh Pomo is Happy")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                                .bold()
                                .opacity(0.7)
                            Text("You did a great Job")
                                .foregroundStyle(.white)
                                .font(.system(size: 30))
                                .bold()
//                            Text(duration.formattedRemainingTime)
//                                .foregroundStyle(.white)
//                                .font(.system(size: 50))
//                                .bold()
                        }
                        Spacer()
                        // TODO: Maybe show sleeping pomo animation with riv
                    }
                    .padding()
                }
            }
            .frame(height: 150)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {}
                DynamicIslandExpandedRegion(.trailing) {
                    // TODO: Maybe show sleeping pomo animation with riv
                }
                DynamicIslandExpandedRegion(.bottom) {
                    if context.state.isDone != true, let startDate = context.state.startDate,
                       let duration = context.state.timerDuration
                    {
                        VStack(alignment: .leading) {
                            Text("Pomo is Sleeping")
                                .foregroundStyle(.white)
                                .font(.system(size: 20))
                                .bold()
                                .opacity(0.7)
                            Text(
                                timerInterval: Date.now...Date(timeInterval: duration, since: startDate)
                            )
                            .foregroundStyle(.white)
                            .font(.system(size: 50))
                            .bold()
                        }
                    }
                }
            } compactLeading: {
                if let startDate = context.state.startDate, let duration = context.state.timerDuration {
                    // TODO: Maybe show sleeping pomo animation with riv
                    Text("L")
                }
            } compactTrailing: {
                if let startDate = context.state.startDate, let duration = context.state.timerDuration {
                    ProgressView(
                        timerInterval: Date.now...Date(timeInterval: duration, since: startDate),
                        countsDown: true,
                        label: {},
                        currentValueLabel: {
                            // Text or Image or whatever you want
                        }
                    )
                    .progressViewStyle(.circular)
                    .tint(.red)
                    .frame(height: 24)
                }
            } minimal: {
                if let startDate = context.state.startDate, let duration = context.state.timerDuration {
                    ProgressView(
                        timerInterval: Date.now...Date(timeInterval: duration, since: startDate),
                        countsDown: true,
                        label: {},
                        currentValueLabel: {
                            // Text or Image or whatever you want
                        }
                    )
                    .progressViewStyle(.circular)
                    .tint(.red)
                    .frame(height: 24)
                }
            }
//            .widgetURL(URL(string: "http://www.apple.com"))
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
        RudePomoWidgetAttributes.ContentState(startDate: .now, timerDuration: 1 * 60, isDone: true)
    }
}

#Preview("Notification", as: .content, using: RudePomoWidgetAttributes.preview) {
    RudePomoWidgetLiveActivity()
} contentStates: {
    RudePomoWidgetAttributes.ContentState.smiley
}
