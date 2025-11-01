//
//  ActivityMonitorWidget.swift
//  ActivityMonitorWidget
//
//  Home Screen Widget for Activity Monitor
//

import WidgetKit
import SwiftUI
import Charts

// MARK: - Widget Timeline Provider

struct MetricsProvider: TimelineProvider {
    let sharedDataManager = SharedDataManager.shared

    func placeholder(in context: Context) -> MetricsEntry {
        MetricsEntry(date: Date(), metrics: .zero, cpuHistory: [], memoryHistory: [])
    }

    func getSnapshot(in context: Context, completion: @escaping (MetricsEntry) -> Void) {
        let metrics = sharedDataManager.loadCurrentMetrics() ?? .zero
        let cpuHistory = sharedDataManager.loadCPUHistory()
        let memoryHistory = sharedDataManager.loadMemoryHistory()

        let entry = MetricsEntry(
            date: Date(),
            metrics: metrics,
            cpuHistory: cpuHistory,
            memoryHistory: memoryHistory
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<MetricsEntry>) -> Void) {
        let currentDate = Date()
        let metrics = sharedDataManager.loadCurrentMetrics() ?? .zero
        let cpuHistory = sharedDataManager.loadCPUHistory()
        let memoryHistory = sharedDataManager.loadMemoryHistory()

        let entry = MetricsEntry(
            date: currentDate,
            metrics: metrics,
            cpuHistory: cpuHistory,
            memoryHistory: memoryHistory
        )

        // Refresh every minute
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        completion(timeline)
    }
}

// MARK: - Widget Entry

struct MetricsEntry: TimelineEntry {
    let date: Date
    let metrics: MetricsSnapshot
    let cpuHistory: [CPUMetrics]
    let memoryHistory: [MemoryMetrics]
}

// MARK: - Widget Views

@available(iOS 17.0, *)
struct ActivityMonitorWidgetEntryView: View {
    @Environment(\.widgetFamily) var widgetFamily
    var entry: MetricsProvider.Entry

    var body: some View {
        switch widgetFamily {
        case .systemSmall:
            SmallWidgetView(entry: entry)
        case .systemMedium:
            MediumWidgetView(entry: entry)
        case .systemLarge:
            LargeWidgetView(entry: entry)
        default:
            SmallWidgetView(entry: entry)
        }
    }
}

// MARK: - Small Widget (Single Metric)

@available(iOS 17.0, *)
struct SmallWidgetView: View {
    var entry: MetricsEntry

    var body: some View {
        VStack(spacing: 8) {
            // Header
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))

                Spacer()

                Text("CPU")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))
            }

            Spacer()

            // CPU Usage
            Text(String(format: "%.0f%%", entry.metrics.cpu.usage))
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundStyle(
                    LinearGradient(
                        colors: [.blue, .cyan],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .contentTransition(.numericText())

            // Mini Chart
            if !entry.cpuHistory.isEmpty {
                Chart {
                    ForEach(Array(entry.cpuHistory.suffix(10).enumerated()), id: \.offset) { index, cpu in
                        LineMark(
                            x: .value("Time", index),
                            y: .value("Usage", cpu.usage)
                        )
                        .foregroundStyle(.blue.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 2, lineCap: .round))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 30)
            }
        }
        .padding(12)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }
}

// MARK: - Medium Widget (2x Metrics)

@available(iOS 17.0, *)
struct MediumWidgetView: View {
    var entry: MetricsEntry

    var body: some View {
        VStack(spacing: 10) {
            // Header
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolEffect(.pulse)

                Text("Activity Monitor")
                    .font(.system(size: 13, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                if let lastUpdate = SharedDataManager.shared.getLastUpdateDate() {
                    Text(timeAgo(from: lastUpdate))
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(.white.opacity(0.6))
                }
            }

            // Metrics
            HStack(spacing: 12) {
                MetricCard(
                    icon: "cpu",
                    label: "CPU",
                    value: String(format: "%.0f%%", entry.metrics.cpu.usage),
                    color: .blue,
                    history: entry.cpuHistory.map { $0.usage }
                )

                MetricCard(
                    icon: "memorychip",
                    label: "Memory",
                    value: String(format: "%.0f%%", entry.metrics.memory.usagePercentage),
                    color: .green,
                    history: entry.memoryHistory.map { $0.usagePercentage }
                )
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
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
}

// MARK: - Large Widget (4x Metrics)

@available(iOS 17.0, *)
struct LargeWidgetView: View {
    var entry: MetricsEntry

    var body: some View {
        VStack(spacing: 12) {
            // Header
            HStack {
                Image(systemName: "chart.xyaxis.line")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundStyle(.white.opacity(0.9))
                    .symbolEffect(.pulse)

                Text("Activity Monitor")
                    .font(.system(size: 15, weight: .bold, design: .rounded))
                    .foregroundStyle(.white)

                Spacer()

                if let lastUpdate = SharedDataManager.shared.getLastUpdateDate() {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Updated")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundStyle(.white.opacity(0.5))
                        Text(timeAgo(from: lastUpdate))
                            .font(.system(size: 11, weight: .semibold, design: .rounded))
                            .foregroundStyle(.white.opacity(0.7))
                    }
                }
            }

            // Top Row
            HStack(spacing: 12) {
                MetricCard(
                    icon: "cpu",
                    label: "CPU",
                    value: String(format: "%.0f%%", entry.metrics.cpu.usage),
                    color: .blue,
                    history: entry.cpuHistory.map { $0.usage }
                )

                MetricCard(
                    icon: "memorychip",
                    label: "Memory",
                    value: String(format: "%.0f%%", entry.metrics.memory.usagePercentage),
                    color: .green,
                    history: entry.memoryHistory.map { $0.usagePercentage }
                )
            }

            // Bottom Row
            HStack(spacing: 12) {
                NetworkMetricCard(metrics: entry.metrics.network)

                StorageMetricCard(metrics: entry.metrics.storage)
            }
        }
        .padding(14)
        .containerBackground(for: .widget) {
            LinearGradient(
                colors: [.black.opacity(0.8), .black.opacity(0.9)],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
        }
    }

    private func timeAgo(from date: Date) -> String {
        let seconds = Int(Date().timeIntervalSince(date))
        if seconds < 60 {
            return "\(seconds)s ago"
        } else if seconds < 3600 {
            return "\(seconds / 60)m ago"
        } else {
            return "\(seconds / 3600)h ago"
        }
    }
}

// MARK: - Metric Card Component

@available(iOS 17.0, *)
struct MetricCard: View {
    let icon: String
    let label: String
    let value: String
    let color: Color
    let history: [Double]

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(color.gradient)

                Text(label)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()
            }

            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(color.gradient)
                .contentTransition(.numericText())

            // Mini chart
            if !history.isEmpty {
                Chart {
                    ForEach(Array(history.suffix(15).enumerated()), id: \.offset) { index, value in
                        LineMark(
                            x: .value("Time", index),
                            y: .value("Value", value)
                        )
                        .foregroundStyle(color.gradient)
                        .lineStyle(StrokeStyle(lineWidth: 1.5, lineCap: .round))
                    }
                }
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
                .frame(height: 35)
            }
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }
}

// MARK: - Network Metric Card

@available(iOS 17.0, *)
struct NetworkMetricCard: View {
    let metrics: NetworkMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "network")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.orange.gradient)

                Text("Network")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()
            }

            Text(formatSpeed(metrics.downloadSpeedMBps))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.orange.gradient)

            HStack(spacing: 4) {
                Image(systemName: "arrow.down")
                    .font(.system(size: 9))
                Text(formatSpeed(metrics.downloadSpeedMBps))
                    .font(.system(size: 10, weight: .medium, design: .rounded))

                Spacer()

                Image(systemName: "arrow.up")
                    .font(.system(size: 9))
                Text(formatSpeed(metrics.uploadSpeedMBps))
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }

    private func formatSpeed(_ speedMBps: Double) -> String {
        if speedMBps >= 1.0 {
            return String(format: "%.1f MB/s", speedMBps)
        } else {
            return String(format: "%.0f KB/s", speedMBps * 1024)
        }
    }
}

// MARK: - Storage Metric Card

@available(iOS 17.0, *)
struct StorageMetricCard: View {
    let metrics: StorageMetrics

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "internaldrive")
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(.purple.gradient)

                Text("Storage")
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(.white.opacity(0.7))

                Spacer()
            }

            Text(String(format: "%.0f%%", metrics.usagePercentage))
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundStyle(.purple.gradient)

            HStack(spacing: 4) {
                Text("Used:")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                Text(formatBytes(metrics.used))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))

                Spacer()

                Text("Free:")
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                Text(formatBytes(metrics.free))
                    .font(.system(size: 10, weight: .semibold, design: .rounded))
            }
            .foregroundStyle(.white.opacity(0.6))
        }
        .padding(10)
        .background {
            RoundedRectangle(cornerRadius: 12, style: .continuous)
                .fill(.white.opacity(0.05))
        }
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.countStyle = .binary
        formatter.allowedUnits = [.useGB, .useTB]
        formatter.includesUnit = true
        formatter.includesCount = true
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Widget Configuration

@available(iOS 17.0, *)
struct ActivityMonitorWidget: Widget {
    let kind: String = "ActivityMonitorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetricsProvider()) { entry in
            ActivityMonitorWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Activity Monitor")
        .description("Monitor your device's CPU, memory, network, and storage in real-time.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview(as: .systemSmall) {
    ActivityMonitorWidget()
} timeline: {
    MetricsEntry(
        date: Date(),
        metrics: MetricsSnapshot(
            cpu: CPUMetrics(usage: 45.0, userTime: 30.0, systemTime: 15.0, idleTime: 55.0, timestamp: Date()),
            memory: MemoryMetrics(used: 4_000_000_000, total: 8_000_000_000, free: 4_000_000_000, active: 3_000_000_000, inactive: 1_000_000_000, wired: 1_000_000_000, compressed: 500_000_000, timestamp: Date()),
            network: NetworkMetrics(bytesReceived: 1_000_000, bytesSent: 500_000, packetsReceived: 1000, packetsSent: 500, downloadSpeed: 1_500_000, uploadSpeed: 500_000, timestamp: Date()),
            storage: StorageMetrics(total: 256_000_000_000, used: 150_000_000_000, free: 106_000_000_000, timestamp: Date()),
            timestamp: Date()
        ),
        cpuHistory: [CPUMetrics(usage: 30, userTime: 20, systemTime: 10, idleTime: 70, timestamp: Date())],
        memoryHistory: [MemoryMetrics(used: 4_000_000_000, total: 8_000_000_000, free: 4_000_000_000, active: 3_000_000_000, inactive: 1_000_000_000, wired: 1_000_000_000, compressed: 500_000_000, timestamp: Date())]
    )
}

@available(iOS 17.0, *)
#Preview(as: .systemMedium) {
    ActivityMonitorWidget()
} timeline: {
    MetricsEntry(
        date: Date(),
        metrics: MetricsSnapshot(
            cpu: CPUMetrics(usage: 45.0, userTime: 30.0, systemTime: 15.0, idleTime: 55.0, timestamp: Date()),
            memory: MemoryMetrics(used: 4_000_000_000, total: 8_000_000_000, free: 4_000_000_000, active: 3_000_000_000, inactive: 1_000_000_000, wired: 1_000_000_000, compressed: 500_000_000, timestamp: Date()),
            network: NetworkMetrics(bytesReceived: 1_000_000, bytesSent: 500_000, packetsReceived: 1000, packetsSent: 500, downloadSpeed: 1_500_000, uploadSpeed: 500_000, timestamp: Date()),
            storage: StorageMetrics(total: 256_000_000_000, used: 150_000_000_000, free: 106_000_000_000, timestamp: Date()),
            timestamp: Date()
        ),
        cpuHistory: [],
        memoryHistory: []
    )
}
