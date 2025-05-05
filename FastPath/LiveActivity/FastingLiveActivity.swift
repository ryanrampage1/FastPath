//
//  FastingLiveActivity.swift
//  FastPath
//
//  Created on 5/4/25.
//

import SwiftUI
import ActivityKit
import WidgetKit

struct FastingLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FastingActivityAttributes.self) { context in
            // Lock screen/banner UI
            FastingLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    Label {
                        Text("Fasting")
                            .font(.headline)
                    } icon: {
                        Image(systemName: "timer")
                            .foregroundStyle(.indigo)
                    }
                    .font(.headline)
                }
                
                DynamicIslandExpandedRegion(.trailing) {
                    if context.state.goalReached {
                        Label {
                            Text("Goal Reached!")
                                .font(.headline)
                                .foregroundStyle(.green)
                        } icon: {
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundStyle(.green)
                        }
                    } else {
                        Label {
                            Text(formatTimeInterval(context.state.remainingTime))
                                .font(.headline)
                                .monospacedDigit()
                        } icon: {
                            Image(systemName: "hourglass")
                                .foregroundStyle(.orange)
                        }
                    }
                }
                
                DynamicIslandExpandedRegion(.center) {
                    Text(context.attributes.goalName ?? "Fasting Goal")
                        .font(.headline)
                        .lineLimit(1)
                }
                
                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        VStack(alignment: .leading) {
                            Text("Elapsed")
                                .font(.caption2)
                                .foregroundStyle(.secondary)
                            Text(formatTimeInterval(context.state.elapsedTime))
                                .font(.system(.body, design: .rounded))
                                .monospacedDigit()
                        }
                        
                        Spacer()
                        
                        if !context.state.goalReached {
                            VStack(alignment: .trailing) {
                                Text("Remaining")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(formatTimeInterval(context.state.remainingTime))
                                    .font(.system(.body, design: .rounded))
                                    .monospacedDigit()
                            }
                        } else {
                            VStack(alignment: .trailing) {
                                Text("Goal")
                                    .font(.caption2)
                                    .foregroundStyle(.secondary)
                                Text(formatTimeInterval(context.attributes.goalDuration))
                                    .font(.system(.body, design: .rounded))
                                    .monospacedDigit()
                            }
                        }
                    }
                    .padding(.top, 4)
                }
            } compactLeading: {
                Image(systemName: "timer.circle.fill")
                    .foregroundStyle(.indigo)
            } compactTrailing: {
                if context.state.goalReached {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Text(formatCompactTime(context.state.remainingTime))
                        .font(.system(.body, design: .rounded))
                        .monospacedDigit()
                        .foregroundStyle(.orange)
                }
            } minimal: {
                if context.state.goalReached {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                } else {
                    Image(systemName: "timer.circle.fill")
                        .foregroundStyle(.indigo)
                }
            }
        }
    }
    
    // Helper function to format time interval for display
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        
        return formatter.string(from: interval) ?? "00:00:00"
    }
    
    // Helper function to format time interval for compact display
    private func formatCompactTime(_ interval: TimeInterval) -> String {
        if interval >= 3600 { // More than 1 hour
            let hours = Int(interval) / 3600
            let minutes = (Int(interval) % 3600) / 60
            return String(format: "%d:%02d", hours, minutes)
        } else {
            let minutes = Int(interval) / 60
            let seconds = Int(interval) % 60
            return String(format: "%d:%02d", minutes, seconds)
        }
    }
}

struct FastingLiveActivityView: View {
    let context: ActivityViewContext<FastingActivityAttributes>
    
    var body: some View {
        VStack {
            HStack {
                Label {
                    Text("FastPath")
                        .font(.headline)
                } icon: {
                    Image(systemName: "timer.circle.fill")
                        .foregroundStyle(.indigo)
                }
                
                Spacer()
                
                if context.state.goalReached {
                    Label {
                        Text("Goal Reached!")
                            .font(.headline)
                            .foregroundStyle(.green)
                    } icon: {
                        Image(systemName: "checkmark.circle.fill")
                            .foregroundStyle(.green)
                    }
                } else {
                    Text(context.attributes.goalName ?? "Fasting Goal")
                        .font(.headline)
                }
            }
            .padding(.bottom, 4)
            
            HStack {
                VStack(alignment: .leading) {
                    Text("Elapsed")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text(formatTimeInterval(context.state.elapsedTime))
                        .font(.system(.title3, design: .rounded))
                        .monospacedDigit()
                }
                
                Spacer()
                
                if !context.state.goalReached {
                    VStack(alignment: .trailing) {
                        Text("Remaining")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTimeInterval(context.state.remainingTime))
                            .font(.system(.title3, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.orange)
                    }
                } else {
                    VStack(alignment: .trailing) {
                        Text("Completed")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(formatTimeInterval(context.attributes.goalDuration))
                            .font(.system(.title3, design: .rounded))
                            .monospacedDigit()
                            .foregroundStyle(.green)
                    }
                }
            }
        }
        .padding()
        .activityBackgroundTint(Color.white.opacity(0.9))
        .activitySystemActionForegroundColor(Color.black)
    }
    
    // Helper function to format time interval for display
    private func formatTimeInterval(_ interval: TimeInterval) -> String {
        let formatter = DateComponentsFormatter()
        formatter.allowedUnits = [.hour, .minute, .second]
        formatter.zeroFormattingBehavior = .pad
        formatter.unitsStyle = .positional
        
        return formatter.string(from: interval) ?? "00:00:00"
    }
}
