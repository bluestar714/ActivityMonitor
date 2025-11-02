//
//  ActivityMonitorWidgetLiveActivity.swift
//  ActivityMonitorWidget
//
//  Live Activity UI for Dynamic Island and Lock Screen
//

import ActivityKit
import WidgetKit
import SwiftUI

// MARK: - Activity Attributes (shared with main app)

@available(iOS 16.1, *)
struct ActivityMonitorAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var cpuUsage: Double
        var memoryUsage: Double
        var networkSpeed: Double
        var timestamp: Date
    }

    var startTime: Date
}

// MARK: - Live Activity Widget

@available(iOS 16.1, *)
struct ActivityMonitorWidgetLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityMonitorAttributes.self) { context in
            // Lock screen/banner UI
            HStack(spacing: 16) {
                // CPU
                VStack(alignment: .leading, spacing: 4) {
                    Label("CPU", systemImage: "cpu")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(context.state.cpuUsage))%")
                        .font(.headline)
                        .foregroundStyle(.blue)
                }

                Divider()

                // Memory
                VStack(alignment: .leading, spacing: 4) {
                    Label("Memory", systemImage: "memorychip")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text("\(Int(context.state.memoryUsage))%")
                        .font(.headline)
                        .foregroundStyle(.green)
                }

                Divider()

                // Network
                VStack(alignment: .leading, spacing: 4) {
                    Label("Network", systemImage: "arrow.down.circle")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                    Text(String(format: "%.1f MB/s", context.state.networkSpeed))
                        .font(.headline)
                        .foregroundStyle(.purple)
                }
            }
            .padding()
            .activityBackgroundTint(Color.black.opacity(0.3))
            .activitySystemActionForegroundColor(Color.white)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    VStack(alignment: .leading, spacing: 2) {
                        Label("CPU", systemImage: "cpu")
                            .font(.caption2)
                        Text("\(Int(context.state.cpuUsage))%")
                            .font(.title3.bold())
                            .foregroundStyle(.blue)
                    }
                }

                DynamicIslandExpandedRegion(.trailing) {
                    VStack(alignment: .trailing, spacing: 2) {
                        Label("Memory", systemImage: "memorychip")
                            .font(.caption2)
                        Text("\(Int(context.state.memoryUsage))%")
                            .font(.title3.bold())
                            .foregroundStyle(.green)
                    }
                }

                DynamicIslandExpandedRegion(.bottom) {
                    HStack {
                        Label("Network", systemImage: "arrow.down.circle")
                            .font(.caption)
                        Spacer()
                        Text(String(format: "%.2f MB/s", context.state.networkSpeed))
                            .font(.callout.bold())
                            .foregroundStyle(.purple)
                    }
                    .padding(.horizontal)
                }
            } compactLeading: {
                Label {
                    Text("\(Int(context.state.cpuUsage))%")
                } icon: {
                    Image(systemName: "cpu")
                }
                .font(.caption2)
            } compactTrailing: {
                Label {
                    Text("\(Int(context.state.memoryUsage))%")
                } icon: {
                    Image(systemName: "memorychip")
                }
                .font(.caption2)
            } minimal: {
                Image(systemName: "chart.line.uptrend.xyaxis")
            }
            .keylineTint(Color.blue)
        }
    }
}

// MARK: - Previews

@available(iOS 16.1, *)
extension ActivityMonitorAttributes {
    fileprivate static var preview: ActivityMonitorAttributes {
        ActivityMonitorAttributes(startTime: Date())
    }
}

@available(iOS 16.1, *)
extension ActivityMonitorAttributes.ContentState {
    fileprivate static var normal: ActivityMonitorAttributes.ContentState {
        ActivityMonitorAttributes.ContentState(
            cpuUsage: 45.5,
            memoryUsage: 62.3,
            networkSpeed: 2.4,
            timestamp: Date()
        )
    }

    fileprivate static var high: ActivityMonitorAttributes.ContentState {
        ActivityMonitorAttributes.ContentState(
            cpuUsage: 89.2,
            memoryUsage: 85.7,
            networkSpeed: 12.8,
            timestamp: Date()
        )
    }
}

@available(iOS 16.1, *)
#Preview("Notification", as: .content, using: ActivityMonitorAttributes.preview) {
   ActivityMonitorWidgetLiveActivity()
} contentStates: {
    ActivityMonitorAttributes.ContentState.normal
    ActivityMonitorAttributes.ContentState.high
}
