//
//  ActivityMonitorWidget.swift
//  ActivityMonitorWidget
//
//  Home screen widget for Activity Monitor
//

import WidgetKit
import SwiftUI

// MARK: - Timeline Provider

struct MetricsProvider: TimelineProvider {
    func placeholder(in context: Context) -> MetricsEntry {
        MetricsEntry(
            date: Date(),
            metrics: .placeholder
        )
    }

    func getSnapshot(in context: Context, completion: @escaping (MetricsEntry) -> ()) {
        let entry = MetricsEntry(
            date: Date(),
            metrics: SharedDataManager.shared.loadCurrentMetrics() ?? .placeholder
        )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let metrics = SharedDataManager.shared.loadCurrentMetrics() ?? .placeholder

        // Create entries for the next hour, updating every minute
        var entries: [MetricsEntry] = []
        for minuteOffset in 0..<60 {
            let entryDate = Calendar.current.date(byAdding: .minute, value: minuteOffset, to: currentDate)!
            let entry = MetricsEntry(date: entryDate, metrics: metrics)
            entries.append(entry)
        }

        // Update timeline every minute
        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

// MARK: - Timeline Entry

struct MetricsEntry: TimelineEntry {
    let date: Date
    let metrics: MetricsSnapshot
}

// MARK: - Widget Views

struct ActivityMonitorWidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    var entry: MetricsProvider.Entry

    var body: some View {
        switch family {
        case .systemSmall:
            SmallWidgetView(metrics: entry.metrics, date: entry.date)
        case .systemMedium:
            MediumWidgetView(metrics: entry.metrics, date: entry.date)
        case .systemLarge:
            LargeWidgetView(metrics: entry.metrics, date: entry.date)
        default:
            SmallWidgetView(metrics: entry.metrics, date: entry.date)
        }
    }
}

// Small Widget: Shows CPU and Memory
struct SmallWidgetView: View {
    let metrics: MetricsSnapshot
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Label("Activity Monitor", systemImage: "chart.xyaxis.line")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)

            VStack(alignment: .leading, spacing: 8) {
                // CPU
                HStack {
                    Label("CPU", systemImage: "cpu")
                        .font(.caption)
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("\(Int(metrics.cpu.usage))%")
                        .font(.headline.bold())
                        .foregroundStyle(.blue)
                }

                // Memory
                HStack {
                    Label("Memory", systemImage: "memorychip")
                        .font(.caption)
                        .foregroundStyle(.green)
                    Spacer()
                    Text("\(Int(metrics.memory.usagePercentage))%")
                        .font(.headline.bold())
                        .foregroundStyle(.green)
                }
            }

            Spacer()

            Text(date, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }
}

// Medium Widget: Shows CPU, Memory, and Network
struct MediumWidgetView: View {
    let metrics: MetricsSnapshot
    let date: Date

    var body: some View {
        HStack(spacing: 16) {
            VStack(alignment: .leading, spacing: 8) {
                Label("Activity Monitor", systemImage: "chart.xyaxis.line")
                    .font(.caption.bold())
                    .foregroundStyle(.secondary)

                Spacer()

                // CPU
                VStack(alignment: .leading, spacing: 4) {
                    Label("CPU", systemImage: "cpu")
                        .font(.caption2)
                        .foregroundStyle(.blue)
                    Text("\(Int(metrics.cpu.usage))%")
                        .font(.title2.bold())
                        .foregroundStyle(.blue)
                }

                // Memory
                VStack(alignment: .leading, spacing: 4) {
                    Label("Memory", systemImage: "memorychip")
                        .font(.caption2)
                        .foregroundStyle(.green)
                    Text("\(Int(metrics.memory.usagePercentage))%")
                        .font(.title2.bold())
                        .foregroundStyle(.green)
                }

                Spacer()

                Text(date, style: .time)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }

            Divider()

            VStack(alignment: .leading, spacing: 8) {
                // Network
                VStack(alignment: .leading, spacing: 4) {
                    Label("Network", systemImage: "arrow.down.circle")
                        .font(.caption2)
                        .foregroundStyle(.purple)
                    Text(String(format: "%.1f MB/s", metrics.network.downloadSpeedMBps))
                        .font(.title3.bold())
                        .foregroundStyle(.purple)
                }

                Spacer()

                // Storage
                VStack(alignment: .leading, spacing: 4) {
                    Label("Storage", systemImage: "internaldrive")
                        .font(.caption2)
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f GB free", metrics.storage.freeSpaceGB))
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }
        }
        .padding()
    }
}

// Large Widget: Shows all metrics
struct LargeWidgetView: View {
    let metrics: MetricsSnapshot
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            // Header
            HStack {
                Label("Activity Monitor", systemImage: "chart.xyaxis.line")
                    .font(.headline.bold())
                Spacer()
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // CPU Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("CPU Usage", systemImage: "cpu")
                        .font(.callout.bold())
                        .foregroundStyle(.blue)
                    Spacer()
                    Text("\(Int(metrics.cpu.usage))%")
                        .font(.title.bold())
                        .foregroundStyle(.blue)
                }

                HStack {
                    Text("User: \(Int(metrics.cpu.userPercentage))%")
                    Text("System: \(Int(metrics.cpu.systemPercentage))%")
                    Text("Idle: \(Int(metrics.cpu.idlePercentage))%")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Divider()

            // Memory Section
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Label("Memory", systemImage: "memorychip")
                        .font(.callout.bold())
                        .foregroundStyle(.green)
                    Spacer()
                    Text("\(Int(metrics.memory.usagePercentage))%")
                        .font(.title.bold())
                        .foregroundStyle(.green)
                }

                HStack {
                    Text("Used: \(String(format: "%.1f", metrics.memory.usedGB)) GB")
                    Spacer()
                    Text("Free: \(String(format: "%.1f", metrics.memory.freeGB)) GB")
                }
                .font(.caption2)
                .foregroundStyle(.secondary)
            }

            Divider()

            // Network & Storage
            HStack(spacing: 20) {
                VStack(alignment: .leading, spacing: 4) {
                    Label("Network", systemImage: "arrow.down.circle")
                        .font(.caption.bold())
                        .foregroundStyle(.purple)
                    Text(String(format: "↓ %.1f MB/s", metrics.network.downloadSpeedMBps))
                        .font(.callout.bold())
                        .foregroundStyle(.purple)
                    Text(String(format: "↑ %.1f MB/s", metrics.network.uploadSpeedMBps))
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                VStack(alignment: .leading, spacing: 4) {
                    Label("Storage", systemImage: "internaldrive")
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                    Text(String(format: "%.1f GB free", metrics.storage.freeSpaceGB))
                        .font(.callout.bold())
                        .foregroundStyle(.orange)
                    Text("\(Int(metrics.storage.usagePercentage))% used")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
        .padding()
    }
}

// MARK: - Widget Configuration

struct ActivityMonitorWidget: Widget {
    let kind: String = "ActivityMonitorWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: MetricsProvider()) { entry in
            if #available(iOS 17.0, *) {
                ActivityMonitorWidgetEntryView(entry: entry)
                    .containerBackground(.fill.tertiary, for: .widget)
            } else {
                ActivityMonitorWidgetEntryView(entry: entry)
                    .padding()
                    .background()
            }
        }
        .configurationDisplayName("Activity Monitor")
        .description("Real-time system performance metrics")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

// MARK: - Placeholder Data

extension MetricsSnapshot {
    static var placeholder: MetricsSnapshot {
        MetricsSnapshot(
            cpu: CPUMetrics(
                usage: 45.0,
                userPercentage: 25.0,
                systemPercentage: 15.0,
                idlePercentage: 60.0
            ),
            memory: MemoryMetrics(
                totalGB: 6.0,
                usedGB: 3.5,
                freeGB: 2.5,
                activeGB: 2.0,
                inactiveGB: 1.0,
                wiredGB: 0.5,
                compressedGB: 0.0,
                usagePercentage: 58.3
            ),
            network: NetworkMetrics(
                downloadSpeedMBps: 2.4,
                uploadSpeedMBps: 0.8,
                totalDownloadedGB: 125.5,
                totalUploadedGB: 45.2
            ),
            storage: StorageMetrics(
                totalSpaceGB: 128.0,
                usedSpaceGB: 85.3,
                freeSpaceGB: 42.7,
                usagePercentage: 66.6
            ),
            timestamp: Date()
        )
    }
}

// MARK: - Previews

#Preview(as: .systemSmall) {
    ActivityMonitorWidget()
} timeline: {
    MetricsEntry(date: .now, metrics: .placeholder)
}

#Preview(as: .systemMedium) {
    ActivityMonitorWidget()
} timeline: {
    MetricsEntry(date: .now, metrics: .placeholder)
}

#Preview(as: .systemLarge) {
    ActivityMonitorWidget()
} timeline: {
    MetricsEntry(date: .now, metrics: .placeholder)
}
