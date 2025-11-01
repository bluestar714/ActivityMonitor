//
//  ActivityMonitorLiveActivityWidget.swift
//  ActivityMonitorWidget
//
//  Live Activity UI for Dynamic Island and Lock Screen
//

import ActivityKit
import WidgetKit
import SwiftUI

@available(iOS 16.1, *)
struct ActivityMonitorLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: ActivityMonitorAttributes.self) { context in
            // Lock Screen UI
            LockScreenLiveActivityView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI
                DynamicIslandExpandedRegion(.leading) {
                    MetricRow(
                        icon: "cpu",
                        label: "CPU",
                        value: String(format: "%.0f%%", context.state.cpuUsage),
                        color: .blue
                    )
                }

                DynamicIslandExpandedRegion(.trailing) {
                    MetricRow(
                        icon: "memorychip",
                        label: "RAM",
                        value: String(format: "%.0f%%", context.state.memoryUsage),
                        color: .green
                    )
                }

                DynamicIslandExpandedRegion(.bottom) {
                    NetworkMetricRow(speed: context.state.networkSpeed)
                }
            } compactLeading: {
                // Compact Leading (left side of Dynamic Island)
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.blue.gradient)
            } compactTrailing: {
                // Compact Trailing (right side of Dynamic Island)
                Text(String(format: "%.0f%%", context.state.cpuUsage))
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.blue.gradient)
            } minimal: {
                // Minimal (when multiple Live Activities are running)
                Image(systemName: "cpu")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.blue.gradient)
            }
        }
    }
}

// MARK: - Lock Screen View

@available(iOS 16.1, *)
struct LockScreenLiveActivityView: View {
    let context: ActivityViewContext<ActivityMonitorAttributes>

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Text("Activity Monitor")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                Text(timeAgo(from: context.state.timestamp))
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }

            // Metrics
            HStack(spacing: 12) {
                LockScreenMetricCard(
                    icon: "cpu",
                    label: "CPU",
                    value: String(format: "%.0f%%", context.state.cpuUsage),
                    color: .blue
                )

                LockScreenMetricCard(
                    icon: "memorychip",
                    label: "RAM",
                    value: String(format: "%.0f%%", context.state.memoryUsage),
                    color: .green
                )

                LockScreenMetricCard(
                    icon: "network",
                    label: "NET",
                    value: formatSpeed(context.state.networkSpeed),
                    color: .orange
                )
            }
        }
        .padding(16)
        .background {
            RoundedRectangle(cornerRadius: 20, style: .continuous)
                .fill(.ultraThinMaterial)
        }
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "\(seconds)s ago"
        } else {
            return "\(seconds / 60)m ago"
        }
    }

    private func formatSpeed(_ speedMBps: Double) -> String {
        if speedMBps >= 1.0 {
            return String(format: "%.1f M", speedMBps)
        } else {
            return String(format: "%.0f K", speedMBps * 1024)
        }
    }
}

// MARK: - Lock Screen Metric Card

@available(iOS 16.1, *)
struct LockScreenMetricCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 18, weight: .semibold))
                .foregroundStyle(color.gradient)

            Text(value)
                .font(.system(size: 18, weight: .bold, design: .rounded))
                .foregroundStyle(color.gradient)

            Text(label)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 8)
        .background {
            RoundedRectangle(cornerRadius: 10, style: .continuous)
                .fill(.white.opacity(0.1))
        }
    }
}

// MARK: - Dynamic Island Metric Row

@available(iOS 16.1, *)
struct MetricRow: View {
    let icon: String
    let label: String
    let value: String
    let color: Color

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .semibold))
                .foregroundStyle(color.gradient)

            VStack(alignment: .leading, spacing: 2) {
                Text(value)
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                    .foregroundStyle(color.gradient)

                Text(label)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.white.opacity(0.6))
            }
        }
    }
}

// MARK: - Network Metric Row

@available(iOS 16.1, *)
struct NetworkMetricRow: View {
    let speed: Double

    var body: some View {
        HStack(spacing: 16) {
            HStack(spacing: 6) {
                Image(systemName: "arrow.down.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange.gradient)

                Text(formatSpeed(speed))
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }

            Divider()
                .frame(height: 20)

            HStack(spacing: 6) {
                Image(systemName: "arrow.up.circle.fill")
                    .font(.system(size: 16))
                    .foregroundStyle(.orange.gradient)

                Text(formatSpeed(speed * 0.3)) // Estimate upload as 30% of download
                    .font(.system(size: 15, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white)
            }
        }
        .padding(.horizontal)
    }

    private func formatSpeed(_ speedMBps: Double) -> String {
        if speedMBps >= 1.0 {
            return String(format: "%.1f MB/s", speedMBps)
        } else {
            return String(format: "%.0f KB/s", speedMBps * 1024)
        }
    }
}
