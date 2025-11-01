//
//  DashboardView.swift
//  ActivityMonitor
//
//  Main dashboard displaying all performance metrics (iOS 17+ design)
//

import SwiftUI

@available(iOS 17.0, *)
struct DashboardView: View {
    @Environment(MetricsManager.self) private var metricsManager
    @Environment(SettingsManager.self) private var settingsManager

    var body: some View {
        ScrollView {
            VStack(spacing: 18) {
                // CPU Metric
                if settingsManager.isMetricEnabled(.cpu) {
                    ModernMetricCardView(
                        type: .cpu,
                        currentValue: String(format: "%.1f%%", metricsManager.currentMetrics.cpu.usage),
                        subtitle: cpuSubtitle,
                        data: metricsManager.getHistory(for: .cpu),
                        maxValue: 100,
                        color: .blue
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("cpu")
                }

                // Memory Metric
                if settingsManager.isMetricEnabled(.memory) {
                    ModernMetricCardView(
                        type: .memory,
                        currentValue: String(format: "%.1f%%", metricsManager.currentMetrics.memory.usagePercentage),
                        subtitle: memorySubtitle,
                        data: metricsManager.getHistory(for: .memory),
                        maxValue: 100,
                        color: .green
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("memory")
                }

                // Network Metric
                if settingsManager.isMetricEnabled(.network) {
                    ModernMetricCardView(
                        type: .network,
                        currentValue: networkCurrentValue,
                        subtitle: networkSubtitle,
                        data: metricsManager.networkHistory.map { $0.downloadSpeedMBps },
                        maxValue: maxNetworkSpeed,
                        color: .orange
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("network")
                }

                // Storage Metric
                if settingsManager.isMetricEnabled(.storage) {
                    ModernMetricCardView(
                        type: .storage,
                        currentValue: String(format: "%.1f%%", metricsManager.currentMetrics.storage.usagePercentage),
                        subtitle: storageSubtitle,
                        data: metricsManager.getHistory(for: .storage),
                        maxValue: 100,
                        color: .purple
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("storage")
                }
            }
            .padding(20)
            .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3), value: settingsManager.settings.enabledMetrics)
        }
        .background {
            Color(.systemGroupedBackground)
                .ignoresSafeArea()
        }
        .refreshable {
            await refreshMetrics()
        }
        .sensoryFeedback(.success, trigger: metricsManager.currentMetrics.timestamp)
    }

    // MARK: - Computed Properties

    private var cpuSubtitle: String {
        let cpu = metricsManager.currentMetrics.cpu
        return String(format: "User: %.1f%% • System: %.1f%%", cpu.userTime, cpu.systemTime)
    }

    private var memorySubtitle: String {
        let memory = metricsManager.currentMetrics.memory
        return String(format: "%.1f GB / %.1f GB", memory.usedGB, memory.totalGB)
    }

    private var networkCurrentValue: String {
        let network = metricsManager.currentMetrics.network
        let download = network.downloadSpeedMBps
        if download >= 1.0 {
            return String(format: "%.1f MB/s", download)
        } else {
            return String(format: "%.0f KB/s", download * 1024)
        }
    }

    private var networkSubtitle: String {
        let network = metricsManager.currentMetrics.network
        let upload = network.uploadSpeedMBps
        let uploadStr: String
        if upload >= 1.0 {
            uploadStr = String(format: "%.1f MB/s", upload)
        } else {
            uploadStr = String(format: "%.0f KB/s", upload * 1024)
        }
        return "Upload: \(uploadStr)"
    }

    private var maxNetworkSpeed: Double {
        let maxDownload = metricsManager.networkHistory.map { $0.downloadSpeedMBps }.max() ?? 1.0
        return max(maxDownload * 1.5, 1.0)
    }

    private var storageSubtitle: String {
        let storage = metricsManager.currentMetrics.storage
        return String(format: "%.1f GB free of %.1f GB", storage.freeGB, storage.totalGB)
    }

    // MARK: - Actions

    @MainActor
    private func refreshMetrics() async {
        // Simulate refresh delay
        try? await Task.sleep(nanoseconds: 500_000_000)
    }
}

// MARK: - Preview

@available(iOS 17.0, *)
#Preview {
    NavigationStack {
        DashboardView()
            .navigationTitle("Activity Monitor")
    }
    .environment(MetricsManager.shared)
    .environment(SettingsManager.shared)
}
