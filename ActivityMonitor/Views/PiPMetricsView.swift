//
//  PiPMetricsView.swift
//  ActivityMonitor
//
//  Simplified metrics view optimized for Picture-in-Picture display
//

import SwiftUI
import Charts

@available(iOS 17.0, *)
struct PiPMetricsView: View {
    let metricsManager: MetricsManager
    let settingsManager: SettingsManager

    private var selectedMetric: MetricType {
        settingsManager.settings.pipMetric
    }

    private var appearance: AppTheme {
        settingsManager.settings.appTheme
    }

    private var backgroundColor: Color {
        Color.white
    }

    private var primaryTextColor: Color {
        Color.black
    }

    private var secondaryTextColor: Color {
        Color.gray
    }

    private var metricValue: String {
        switch selectedMetric {
        case .cpuUser:
            return String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime)
        case .cpuSystem:
            return String(format: "%.1f%%", metricsManager.currentMetrics.cpu.systemTime)
        case .cpuTotal:
            let total = metricsManager.currentMetrics.cpu.userTime + metricsManager.currentMetrics.cpu.systemTime
            return String(format: "%.1f%%", total)
        case .memoryActive:
            let memory = metricsManager.currentMetrics.memory
            let activePercentage = Double(memory.active) / Double(memory.total) * 100.0
            return String(format: "%.1f%%", activePercentage)
        case .memoryInactive:
            let memory = metricsManager.currentMetrics.memory
            let inactivePercentage = Double(memory.inactive) / Double(memory.total) * 100.0
            return String(format: "%.1f%%", inactivePercentage)
        case .memoryWired:
            let memory = metricsManager.currentMetrics.memory
            let wiredPercentage = Double(memory.wired) / Double(memory.total) * 100.0
            return String(format: "%.1f%%", wiredPercentage)
        case .memoryCompressed:
            let memory = metricsManager.currentMetrics.memory
            let compressedPercentage = Double(memory.compressed) / Double(memory.total) * 100.0
            return String(format: "%.1f%%", compressedPercentage)
        case .memoryTotal:
            return String(format: "%.1f%%", metricsManager.currentMetrics.memory.usagePercentage)
        case .network:
            let download = metricsManager.currentMetrics.network.downloadSpeedMBps
            return download >= 1.0 ? String(format: "%.1f MB/s", download) : String(format: "%.0f KB/s", download * 1024)
        case .storage:
            return String(format: "%.1f%%", metricsManager.currentMetrics.storage.usagePercentage)
        case .battery:
            let level = metricsManager.currentMetrics.battery.level
            return "\(Int(level))%"
        case .diskIORead:
            let read = metricsManager.currentMetrics.diskIO.readSpeedMBps
            return read >= 1.0 ? String(format: "%.1f MB/s", read) : String(format: "%.0f KB/s", read * 1024)
        case .diskIOWrite:
            let write = metricsManager.currentMetrics.diskIO.writeSpeedMBps
            return write >= 1.0 ? String(format: "%.1f MB/s", write) : String(format: "%.0f KB/s", write * 1024)
        case .diskIOTotal:
            let diskIO = metricsManager.currentMetrics.diskIO
            let total = diskIO.readSpeedMBps + diskIO.writeSpeedMBps
            return total >= 1.0 ? String(format: "%.1f MB/s", total) : String(format: "%.0f KB/s", total * 1024)
        }
    }

    private var metricHistory: [Double] {
        switch selectedMetric {
        case .cpuUser:
            return metricsManager.getHistory(for: .cpuUser)
        case .cpuSystem:
            return metricsManager.getHistory(for: .cpuSystem)
        case .cpuTotal:
            return metricsManager.getHistory(for: .cpuTotal)
        case .memoryActive:
            return metricsManager.getHistory(for: .memoryActive)
        case .memoryInactive:
            return metricsManager.getHistory(for: .memoryInactive)
        case .memoryWired:
            return metricsManager.getHistory(for: .memoryWired)
        case .memoryCompressed:
            return metricsManager.getHistory(for: .memoryCompressed)
        case .memoryTotal:
            return metricsManager.getHistory(for: .memoryTotal)
        case .network:
            return metricsManager.networkHistory.map { $0.downloadSpeedMBps }
        case .storage:
            return metricsManager.getHistory(for: .storage)
        case .battery:
            return metricsManager.batteryHistory.map { $0.level }
        case .diskIORead:
            return metricsManager.diskIOHistory.map { $0.readSpeedMBps }
        case .diskIOWrite:
            return metricsManager.diskIOHistory.map { $0.writeSpeedMBps }
        case .diskIOTotal:
            return metricsManager.diskIOHistory.map { $0.readSpeedMBps + $0.writeSpeedMBps }
        }
    }

    private var metricColor: Color {
        switch selectedMetric {
        case .cpuUser: return .orange
        case .cpuSystem: return .red
        case .cpuTotal: return .blue
        case .memoryActive: return .green
        case .memoryInactive: return .yellow
        case .memoryWired: return .purple
        case .memoryCompressed: return .pink
        case .memoryTotal: return .green
        case .network: return .orange
        case .storage: return .purple
        case .battery: return .yellow
        case .diskIORead: return .cyan
        case .diskIOWrite: return Color(red: 1.0, green: 0.2, blue: 0.5)
        case .diskIOTotal: return .purple
        }
    }

    private var metricMaxValue: Double {
        switch selectedMetric {
        case .cpuUser, .cpuSystem, .cpuTotal:
            return 100
        case .memoryActive, .memoryInactive, .memoryWired, .memoryCompressed, .memoryTotal:
            return 100
        case .storage:
            return 100
        case .battery:
            return 100
        case .network:
            let maxDownload = metricsManager.networkHistory.map { $0.downloadSpeedMBps }.max() ?? 1.0
            return max(maxDownload * 1.5, 1.0)
        case .diskIORead:
            let maxRead = metricsManager.diskIOHistory.map { $0.readSpeedMBps }.max() ?? 1.0
            return max(maxRead * 1.5, 1.0)
        case .diskIOWrite:
            let maxWrite = metricsManager.diskIOHistory.map { $0.writeSpeedMBps }.max() ?? 1.0
            return max(maxWrite * 1.5, 1.0)
        case .diskIOTotal:
            let maxTotal = metricsManager.diskIOHistory.map { $0.readSpeedMBps + $0.writeSpeedMBps }.max() ?? 1.0
            return max(maxTotal * 1.5, 1.0)
        }
    }

    private var detailInfo: [(label: String, value: String)] {
        switch selectedMetric {
        case .cpuUser:
            return [
                ("User", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime)),
                ("System", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.systemTime)),
                ("Idle", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.idleTime))
            ]
        case .cpuSystem:
            return [
                ("System", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.systemTime)),
                ("User", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime)),
                ("Idle", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.idleTime))
            ]
        case .cpuTotal:
            return [
                ("User", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime)),
                ("System", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.systemTime)),
                ("Idle", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.idleTime))
            ]
        case .memoryActive:
            let memory = metricsManager.currentMetrics.memory
            return [
                ("Active", String(format: "%.1f GB", memory.activeGB)),
                ("Total", String(format: "%.1f GB", memory.totalGB)),
                ("", "")
            ]
        case .memoryInactive:
            let memory = metricsManager.currentMetrics.memory
            return [
                ("Inactive", String(format: "%.1f GB", memory.inactiveGB)),
                ("Total", String(format: "%.1f GB", memory.totalGB)),
                ("", "")
            ]
        case .memoryWired:
            let memory = metricsManager.currentMetrics.memory
            return [
                ("Wired", String(format: "%.1f GB", memory.wiredGB)),
                ("Total", String(format: "%.1f GB", memory.totalGB)),
                ("", "")
            ]
        case .memoryCompressed:
            let memory = metricsManager.currentMetrics.memory
            return [
                ("Compressed", String(format: "%.1f GB", memory.compressedGB)),
                ("Total", String(format: "%.1f GB", memory.totalGB)),
                ("", "")
            ]
        case .memoryTotal:
            let memory = metricsManager.currentMetrics.memory
            return [
                ("Used", String(format: "%.1f GB", memory.usedGB)),
                ("Total", String(format: "%.1f GB", memory.totalGB)),
                ("Free", String(format: "%.1f GB", memory.freeGB))
            ]
        case .network:
            let network = metricsManager.currentMetrics.network
            let upload = network.uploadSpeedMBps
            let uploadStr = upload >= 1.0 ? String(format: "%.1f MB/s", upload) : String(format: "%.0f KB/s", upload * 1024)
            return [
                ("Download", metricValue),
                ("Upload", uploadStr),
                ("", "")
            ]
        case .storage:
            let storage = metricsManager.currentMetrics.storage
            return [
                ("Used", String(format: "%.1f GB", storage.usedGB)),
                ("Total", String(format: "%.1f GB", storage.totalGB)),
                ("Free", String(format: "%.1f GB", storage.freeGB))
            ]
        case .battery:
            let battery = metricsManager.currentMetrics.battery
            let stateStr = battery.state.rawValue.capitalized
            let chargingStr = battery.isCharging ? "Charging" : "Not Charging"
            return [
                ("Level", "\(Int(battery.level))%"),
                ("State", stateStr),
                ("Status", chargingStr)
            ]
        case .diskIORead:
            let diskIO = metricsManager.currentMetrics.diskIO
            let totalStr = (diskIO.readSpeedMBps + diskIO.writeSpeedMBps) >= 1.0 ? String(format: "%.1f MB/s", diskIO.readSpeedMBps + diskIO.writeSpeedMBps) : String(format: "%.0f KB/s", (diskIO.readSpeedMBps + diskIO.writeSpeedMBps) * 1024)
            return [
                ("Read", metricValue),
                ("Total", totalStr),
                ("", "")
            ]
        case .diskIOWrite:
            let diskIO = metricsManager.currentMetrics.diskIO
            let totalStr = (diskIO.readSpeedMBps + diskIO.writeSpeedMBps) >= 1.0 ? String(format: "%.1f MB/s", diskIO.readSpeedMBps + diskIO.writeSpeedMBps) : String(format: "%.0f KB/s", (diskIO.readSpeedMBps + diskIO.writeSpeedMBps) * 1024)
            return [
                ("Write", metricValue),
                ("Total", totalStr),
                ("", "")
            ]
        case .diskIOTotal:
            let diskIO = metricsManager.currentMetrics.diskIO
            let readStr = diskIO.readSpeedMBps >= 1.0 ? String(format: "%.1f MB/s", diskIO.readSpeedMBps) : String(format: "%.0f KB/s", diskIO.readSpeedMBps * 1024)
            let writeStr = diskIO.writeSpeedMBps >= 1.0 ? String(format: "%.1f MB/s", diskIO.writeSpeedMBps) : String(format: "%.0f KB/s", diskIO.writeSpeedMBps * 1024)
            return [
                ("Read", readStr),
                ("Write", writeStr),
                ("", "")
            ]
        }
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title Section
            VStack(spacing: 8) {
                Text("Activity Monitor")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(primaryTextColor)

                Text(selectedMetric.rawValue)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(secondaryTextColor)
            }
            .padding(.top, 30)

            Spacer()

            // Large Metric Value
            Text(metricValue)
                .font(.system(size: 80, weight: .bold))
                .foregroundColor(metricColor)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Spacer()

            // Simple Graph Representation (using rectangles)
            if !metricHistory.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(metricHistory.suffix(20).enumerated()), id: \.offset) { index, value in
                        let normalizedHeight = selectedMetric == .network
                            ? CGFloat(value / metricMaxValue * 120)
                            : CGFloat(value * 1.2)

                        RoundedRectangle(cornerRadius: 2)
                            .fill(metricColor)
                            .frame(width: 8, height: max(4, normalizedHeight))
                    }
                }
                .frame(height: 120)
                .padding(.horizontal, 30)
            }

            Spacer()

            // Detailed Info
            HStack(spacing: 30) {
                ForEach(detailInfo, id: \.label) { info in
                    if !info.label.isEmpty {
                        DetailItem(label: info.label, value: info.value, color: metricColor, labelColor: secondaryTextColor)
                    }
                }
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(backgroundColor)
    }
}

@available(iOS 17.0, *)
struct DetailItem: View {
    let label: String
    let value: String
    var color: Color = .black
    var labelColor: Color = .gray

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(labelColor)

            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(color)
                .minimumScaleFactor(0.7)
                .lineLimit(1)
        }
    }
}

