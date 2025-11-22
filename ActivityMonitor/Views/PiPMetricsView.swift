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
        case .cpu:
            let total = metricsManager.currentMetrics.cpu.userTime + metricsManager.currentMetrics.cpu.systemTime
            return String(format: "%.1f%%", total)
        case .memory:
            return String(format: "%.1f%%", metricsManager.currentMetrics.memory.usagePercentage)
        case .network:
            let download = metricsManager.currentMetrics.network.downloadSpeedMBps
            return download >= 1.0 ? String(format: "%.1f MB/s", download) : String(format: "%.0f KB/s", download * 1024)
        case .storage:
            return String(format: "%.1f%%", metricsManager.currentMetrics.storage.usagePercentage)
        }
    }

    private var metricHistory: [Double] {
        switch selectedMetric {
        case .cpu:
            return metricsManager.getHistory(for: .cpu)
        case .memory:
            return metricsManager.getHistory(for: .memory)
        case .network:
            return metricsManager.networkHistory.map { $0.downloadSpeedMBps }
        case .storage:
            return metricsManager.getHistory(for: .storage)
        }
    }

    private var metricColor: Color {
        switch selectedMetric {
        case .cpu: return .blue
        case .memory: return .green
        case .network: return .orange
        case .storage: return .purple
        }
    }

    private var metricMaxValue: Double {
        switch selectedMetric {
        case .cpu, .memory, .storage:
            return 100
        case .network:
            let maxDownload = metricsManager.networkHistory.map { $0.downloadSpeedMBps }.max() ?? 1.0
            return max(maxDownload * 1.5, 1.0)
        }
    }

    private var detailInfo: [(label: String, value: String)] {
        switch selectedMetric {
        case .cpu:
            return [
                ("User", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime)),
                ("System", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.systemTime)),
                ("Idle", String(format: "%.1f%%", metricsManager.currentMetrics.cpu.idleTime))
            ]
        case .memory:
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

