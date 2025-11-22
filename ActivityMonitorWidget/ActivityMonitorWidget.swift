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
        let loadedMetrics = SharedDataManager.shared.loadCurrentMetrics()
        let entry = MetricsEntry(
            date: Date(),
            metrics: loadedMetrics ?? .placeholder
        )

        if loadedMetrics == nil {
            print("⚠️ [Widget] Using placeholder data in snapshot")
        } else {
            print("✅ [Widget] Using real data in snapshot")
        }

        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let loadedMetrics = SharedDataManager.shared.loadCurrentMetrics()
        let metrics = loadedMetrics ?? .placeholder

        if loadedMetrics == nil {
            print("⚠️ [Widget Timeline] No data available, using placeholder")
        } else {
            let cpuTotal = metrics.cpu.userTime + metrics.cpu.systemTime
            print("✅ [Widget Timeline] Using real data - CPU: \(Int(cpuTotal))% (User: \(Int(metrics.cpu.userTime))%, System: \(Int(metrics.cpu.systemTime))%), Memory: \(Int(metrics.memory.usagePercentage))%")
        }

        // Create a single entry with current data
        let entry = MetricsEntry(date: currentDate, metrics: metrics)

        // Schedule next update in 1 minute
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 1, to: currentDate)!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))

        print("📅 [Widget Timeline] Next update scheduled at: \(nextUpdate)")
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
        let (metric1, metric2) = SharedDataManager.shared.loadWidgetSettings()

        switch family {
        case .systemSmall:
            CompactTwoMetricsView(metrics: entry.metrics, metric1: metric1, metric2: metric2, date: entry.date)
        case .systemMedium:
            MediumTwoMetricsView(metrics: entry.metrics, metric1: metric1, metric2: metric2, date: entry.date)
        case .systemLarge:
            LargeTwoMetricsView(metrics: entry.metrics, metric1: metric1, metric2: metric2, date: entry.date)
        default:
            CompactTwoMetricsView(metrics: entry.metrics, metric1: metric1, metric2: metric2, date: entry.date)
        }
    }
}

// MARK: - Compact View (Small Widget)

struct CompactTwoMetricsView: View {
    let metrics: MetricsSnapshot
    let metric1: MetricType
    let metric2: MetricType
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header
            Label("Activity Monitor", systemImage: "chart.xyaxis.line")
                .font(.caption2.bold())
                .foregroundStyle(.secondary)

            // Metric 1
            metricRow(for: metric1)

            // Metric 2
            metricRow(for: metric2)

            Spacer()

            // Timestamp
            Text(date, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
    }

    @ViewBuilder
    private func metricRow(for type: MetricType) -> some View {
        HStack {
            Label(type.rawValue, systemImage: type.icon)
                .font(.caption)
                .foregroundStyle(colorFor(type))
            Spacer()
            Text(valueString(for: type))
                .font(.headline.bold())
                .foregroundStyle(colorFor(type))
        }
    }

    private func valueString(for type: MetricType) -> String {
        switch type {
        case .cpuUser:
            return "\(Int(metrics.cpu.userTime))%"
        case .cpuSystem:
            return "\(Int(metrics.cpu.systemTime))%"
        case .cpuTotal:
            return "\(Int(metrics.cpu.userTime + metrics.cpu.systemTime))%"
        case .memoryActive:
            let percentage = Double(metrics.memory.active) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryInactive:
            let percentage = Double(metrics.memory.inactive) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryWired:
            let percentage = Double(metrics.memory.wired) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryCompressed:
            let percentage = Double(metrics.memory.compressed) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryTotal:
            return "\(Int(metrics.memory.usagePercentage))%"
        case .network:
            return String(format: "%.1f MB/s", metrics.network.downloadSpeedMBps)
        case .storage:
            return String(format: "%.1f GB", metrics.storage.freeSpaceGB)
        case .battery:
            return "\(Int(metrics.battery.level))%"
        case .diskIORead:
            return String(format: "%.1f MB/s", metrics.diskIO.readSpeedMBps)
        case .diskIOWrite:
            return String(format: "%.1f MB/s", metrics.diskIO.writeSpeedMBps)
        case .diskIOTotal:
            return String(format: "%.1f MB/s", metrics.diskIO.readSpeedMBps + metrics.diskIO.writeSpeedMBps)
        }
    }

    private func colorFor(_ type: MetricType) -> Color {
        switch type {
        case .cpuUser: return .orange
        case .cpuSystem: return .red
        case .cpuTotal: return .blue
        case .memoryActive: return .green
        case .memoryInactive: return .yellow
        case .memoryWired: return .purple
        case .memoryCompressed: return .pink
        case .memoryTotal: return .green
        case .network: return .purple
        case .storage: return .orange
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
    }
}

// MARK: - Medium View (Medium Widget)

struct MediumTwoMetricsView: View {
    let metrics: MetricsSnapshot
    let metric1: MetricType
    let metric2: MetricType
    let date: Date

    var body: some View {
        HStack(spacing: 20) {
            // Metric 1
            metricColumn(for: metric1)

            Divider()

            // Metric 2
            metricColumn(for: metric2)
        }
        .padding()
    }

    @ViewBuilder
    private func metricColumn(for type: MetricType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Icon and label
            Label(type.rawValue, systemImage: type.icon)
                .font(.caption.bold())
                .foregroundStyle(colorFor(type))
                .symbolRenderingMode(.multicolor)

            Spacer()

            // Large value
            Text(valueString(for: type))
                .font(.system(size: 32, weight: .bold, design: .rounded))
                .foregroundStyle(colorFor(type))
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            // Subtitle
            Text(subtitleString(for: type))
                .font(.caption2)
                .foregroundStyle(.secondary)
                .lineLimit(1)

            Spacer()

            // Timestamp
            Text(date, style: .time)
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    private func valueString(for type: MetricType) -> String {
        switch type {
        case .cpuUser:
            return "\(Int(metrics.cpu.userTime))%"
        case .cpuSystem:
            return "\(Int(metrics.cpu.systemTime))%"
        case .cpuTotal:
            return "\(Int(metrics.cpu.userTime + metrics.cpu.systemTime))%"
        case .memoryActive:
            let percentage = Double(metrics.memory.active) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryInactive:
            let percentage = Double(metrics.memory.inactive) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryWired:
            let percentage = Double(metrics.memory.wired) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryCompressed:
            let percentage = Double(metrics.memory.compressed) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryTotal:
            return "\(Int(metrics.memory.usagePercentage))%"
        case .network:
            let speed = metrics.network.downloadSpeedMBps
            if speed >= 1.0 {
                return String(format: "%.1f", speed)
            } else {
                return String(format: "%.0f", speed * 1024)
            }
        case .storage:
            return String(format: "%.1f", metrics.storage.freeSpaceGB)
        case .battery:
            return "\(Int(metrics.battery.level))%"
        case .diskIORead:
            return String(format: "%.1f", metrics.diskIO.readSpeedMBps)
        case .diskIOWrite:
            return String(format: "%.1f", metrics.diskIO.writeSpeedMBps)
        case .diskIOTotal:
            return String(format: "%.1f", metrics.diskIO.readSpeedMBps + metrics.diskIO.writeSpeedMBps)
        }
    }

    private func subtitleString(for type: MetricType) -> String {
        switch type {
        case .cpuUser:
            return "User time"
        case .cpuSystem:
            return "System time"
        case .cpuTotal:
            return "User+System"
        case .memoryActive:
            return String(format: "%.1f GB", metrics.memory.activeGB)
        case .memoryInactive:
            return String(format: "%.1f GB", metrics.memory.inactiveGB)
        case .memoryWired:
            return String(format: "%.1f GB", metrics.memory.wiredGB)
        case .memoryCompressed:
            return String(format: "%.1f GB", metrics.memory.compressedGB)
        case .memoryTotal:
            return String(format: "%.1f/%.1f GB", metrics.memory.usedGB, metrics.memory.totalGB)
        case .network:
            let speed = metrics.network.downloadSpeedMBps
            return speed >= 1.0 ? "MB/s" : "KB/s"
        case .storage:
            return "GB free"
        case .battery:
            return metrics.battery.isCharging ? "Charging" : "Discharging"
        case .diskIORead:
            return "Read speed"
        case .diskIOWrite:
            return "Write speed"
        case .diskIOTotal:
            return "Combined speed"
        }
    }

    private func colorFor(_ type: MetricType) -> Color {
        switch type {
        case .cpuUser: return .orange
        case .cpuSystem: return .red
        case .cpuTotal: return .blue
        case .memoryActive: return .green
        case .memoryInactive: return .yellow
        case .memoryWired: return .purple
        case .memoryCompressed: return .pink
        case .memoryTotal: return .green
        case .network: return .purple
        case .storage: return .orange
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
    }
}

// MARK: - Large View (Large Widget)

struct LargeTwoMetricsView: View {
    let metrics: MetricsSnapshot
    let metric1: MetricType
    let metric2: MetricType
    let date: Date

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            // Header
            HStack {
                Label("Activity Monitor", systemImage: "chart.xyaxis.line")
                    .font(.headline.bold())
                    .symbolRenderingMode(.multicolor)
                Spacer()
                Text(date, style: .time)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Divider()

            // Metric 1 Section
            metricDetailSection(for: metric1)

            Divider()

            // Metric 2 Section
            metricDetailSection(for: metric2)

            Spacer()
        }
        .padding()
    }

    @ViewBuilder
    private func metricDetailSection(for type: MetricType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            // Main value
            HStack(alignment: .firstTextBaseline) {
                Label(type.rawValue, systemImage: type.icon)
                    .font(.title3.bold())
                    .foregroundStyle(colorFor(type))
                    .symbolRenderingMode(.multicolor)
                Spacer()
                Text(mainValueString(for: type))
                    .font(.system(size: 40, weight: .bold, design: .rounded))
                    .foregroundStyle(colorFor(type))
                    .minimumScaleFactor(0.5)
                    .lineLimit(1)
            }

            // Detail breakdown
            HStack(spacing: 12) {
                ForEach(detailStrings(for: type), id: \.self) { detail in
                    Text(detail)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }
        }
    }

    private func mainValueString(for type: MetricType) -> String {
        switch type {
        case .cpuUser:
            return "\(Int(metrics.cpu.userTime))%"
        case .cpuSystem:
            return "\(Int(metrics.cpu.systemTime))%"
        case .cpuTotal:
            return "\(Int(metrics.cpu.userTime + metrics.cpu.systemTime))%"
        case .memoryActive:
            let percentage = Double(metrics.memory.active) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryInactive:
            let percentage = Double(metrics.memory.inactive) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryWired:
            let percentage = Double(metrics.memory.wired) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryCompressed:
            let percentage = Double(metrics.memory.compressed) / Double(metrics.memory.total) * 100.0
            return "\(Int(percentage))%"
        case .memoryTotal:
            return "\(Int(metrics.memory.usagePercentage))%"
        case .network:
            return String(format: "%.1f MB/s", metrics.network.downloadSpeedMBps)
        case .storage:
            return String(format: "%.1f GB", metrics.storage.freeSpaceGB)
        case .battery:
            return "\(Int(metrics.battery.level))%"
        case .diskIORead:
            return String(format: "%.1f MB/s", metrics.diskIO.readSpeedMBps)
        case .diskIOWrite:
            return String(format: "%.1f MB/s", metrics.diskIO.writeSpeedMBps)
        case .diskIOTotal:
            return String(format: "%.1f MB/s", metrics.diskIO.readSpeedMBps + metrics.diskIO.writeSpeedMBps)
        }
    }

    private func detailStrings(for type: MetricType) -> [String] {
        switch type {
        case .cpuUser:
            return [
                "User: \(Int(metrics.cpu.userTime))%",
                "System: \(Int(metrics.cpu.systemTime))%",
                "Idle: \(Int(metrics.cpu.idleTime))%"
            ]
        case .cpuSystem:
            return [
                "System: \(Int(metrics.cpu.systemTime))%",
                "User: \(Int(metrics.cpu.userTime))%",
                "Idle: \(Int(metrics.cpu.idleTime))%"
            ]
        case .cpuTotal:
            return [
                "User: \(Int(metrics.cpu.userTime))%",
                "System: \(Int(metrics.cpu.systemTime))%",
                "Idle: \(Int(metrics.cpu.idleTime))%"
            ]
        case .memoryActive:
            return [
                "Active: \(String(format: "%.1f", metrics.memory.activeGB)) GB",
                "Total: \(String(format: "%.1f", metrics.memory.totalGB)) GB"
            ]
        case .memoryInactive:
            return [
                "Inactive: \(String(format: "%.1f", metrics.memory.inactiveGB)) GB",
                "Total: \(String(format: "%.1f", metrics.memory.totalGB)) GB"
            ]
        case .memoryWired:
            return [
                "Wired: \(String(format: "%.1f", metrics.memory.wiredGB)) GB",
                "Total: \(String(format: "%.1f", metrics.memory.totalGB)) GB"
            ]
        case .memoryCompressed:
            return [
                "Compressed: \(String(format: "%.1f", metrics.memory.compressedGB)) GB",
                "Total: \(String(format: "%.1f", metrics.memory.totalGB)) GB"
            ]
        case .memoryTotal:
            return [
                "Used: \(String(format: "%.1f", metrics.memory.usedGB)) GB",
                "Free: \(String(format: "%.1f", metrics.memory.freeGB)) GB",
                "Total: \(String(format: "%.1f", metrics.memory.totalGB)) GB"
            ]
        case .network:
            return [
                "Download: \(String(format: "%.1f", metrics.network.downloadSpeedMBps)) MB/s",
                "Upload: \(String(format: "%.1f", metrics.network.uploadSpeedMBps)) MB/s"
            ]
        case .storage:
            return [
                "Used: \(String(format: "%.1f", metrics.storage.usedSpaceGB)) GB",
                "Free: \(String(format: "%.1f", metrics.storage.freeSpaceGB)) GB",
                "\(Int(metrics.storage.usagePercentage))% full"
            ]
        case .battery:
            return [
                "Level: \(Int(metrics.battery.level))%",
                "State: \(metrics.battery.state.rawValue)",
                metrics.battery.isCharging ? "Charging" : "On battery"
            ]
        case .diskIORead:
            return [
                "Read: \(String(format: "%.1f", metrics.diskIO.readSpeedMBps)) MB/s",
                "Total: \(String(format: "%.1f", metrics.diskIO.readSpeedMBps + metrics.diskIO.writeSpeedMBps)) MB/s"
            ]
        case .diskIOWrite:
            return [
                "Write: \(String(format: "%.1f", metrics.diskIO.writeSpeedMBps)) MB/s",
                "Total: \(String(format: "%.1f", metrics.diskIO.readSpeedMBps + metrics.diskIO.writeSpeedMBps)) MB/s"
            ]
        case .diskIOTotal:
            return [
                "Read: \(String(format: "%.1f", metrics.diskIO.readSpeedMBps)) MB/s",
                "Write: \(String(format: "%.1f", metrics.diskIO.writeSpeedMBps)) MB/s"
            ]
        }
    }

    private func colorFor(_ type: MetricType) -> Color {
        switch type {
        case .cpuUser: return .orange
        case .cpuSystem: return .red
        case .cpuTotal: return .blue
        case .memoryActive: return .green
        case .memoryInactive: return .yellow
        case .memoryWired: return .purple
        case .memoryCompressed: return .pink
        case .memoryTotal: return .green
        case .network: return .purple
        case .storage: return .orange
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
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
        let gigabyte: UInt64 = 1_073_741_824

        return MetricsSnapshot(
            cpu: CPUMetrics(
                usage: 45.0,
                userTime: 25.0,
                systemTime: 15.0,
                idleTime: 60.0,
                timestamp: Date()
            ),
            memory: MemoryMetrics(
                used: 3_758_096_384,      // 3.5 GB
                total: 6_442_450_944,     // 6 GB
                free: 2_684_354_560,      // 2.5 GB
                active: 2_147_483_648,    // 2 GB
                inactive: 1_073_741_824,  // 1 GB
                wired: 536_870_912,       // 0.5 GB
                compressed: 0,
                timestamp: Date()
            ),
            network: NetworkMetrics(
                bytesReceived: 134_826_188_800,  // 125.5 GB
                bytesSent: 48_563_986_432,       // 45.2 GB
                packetsReceived: 1_000_000,
                packetsSent: 500_000,
                downloadSpeed: 2_516_582.4,      // 2.4 MB/s
                uploadSpeed: 838_860.8,          // 0.8 MB/s
                timestamp: Date()
            ),
            storage: StorageMetrics(
                total: 137_438_953_472,     // 128 GB
                used: 91_539_013_632,       // 85.3 GB
                free: 45_899_939_840,       // 42.7 GB
                timestamp: Date()
            ),
            battery: BatteryMetrics(
                level: 75.0,
                state: .unplugged,
                isCharging: false,
                timestamp: Date()
            ),
            diskIO: DiskIOMetrics(
                readBytes: 1_048_576_000,  // 1 GB
                writeBytes: 524_288_000,   // 500 MB
                readSpeed: 10_485_760,     // 10 MB/s
                writeSpeed: 5_242_880,     // 5 MB/s
                timestamp: Date()
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
