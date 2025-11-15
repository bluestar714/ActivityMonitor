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

    private var cpuUsage: Double {
        metricsManager.currentMetrics.cpu.userTime + metricsManager.currentMetrics.cpu.systemTime
    }

    private var cpuHistory: [Double] {
        metricsManager.getHistory(for: .cpu)
    }

    var body: some View {
        VStack(spacing: 0) {
            // Title Section
            VStack(spacing: 8) {
                Text("Activity Monitor")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.black)

                Text("CPU Usage")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.gray)
            }
            .padding(.top, 30)

            Spacer()

            // Large CPU Value
            Text(String(format: "%.1f%%", cpuUsage))
                .font(.system(size: 90, weight: .bold))
                .foregroundColor(.blue)
                .minimumScaleFactor(0.5)
                .lineLimit(1)

            Spacer()

            // Simple Graph Representation (using rectangles)
            if !cpuHistory.isEmpty {
                HStack(alignment: .bottom, spacing: 4) {
                    ForEach(Array(cpuHistory.suffix(20).enumerated()), id: \.offset) { index, value in
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.blue)
                            .frame(width: 8, height: max(4, CGFloat(value) * 1.2))
                    }
                }
                .frame(height: 120)
                .padding(.horizontal, 30)
            }

            Spacer()

            // Detailed Info
            HStack(spacing: 30) {
                DetailItem(label: "User", value: String(format: "%.1f%%", metricsManager.currentMetrics.cpu.userTime))

                DetailItem(label: "System", value: String(format: "%.1f%%", metricsManager.currentMetrics.cpu.systemTime))

                DetailItem(label: "Idle", value: String(format: "%.1f%%", metricsManager.currentMetrics.cpu.idleTime))
            }
            .padding(.bottom, 30)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.white)
    }
}

@available(iOS 17.0, *)
struct DetailItem: View {
    let label: String
    let value: String

    var body: some View {
        VStack(spacing: 6) {
            Text(label)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)

            Text(value)
                .font(.system(size: 18, weight: .bold))
                .foregroundColor(.black)
        }
    }
}

