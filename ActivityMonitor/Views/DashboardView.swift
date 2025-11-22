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
    @State private var pipManager = PictureInPictureManager.shared

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            ScrollView {
            VStack(spacing: 18) {
                // CPU User Metric
                if settingsManager.isMetricEnabled(.cpuUser) {
                    ModernMetricCardView(
                        type: .cpuUser,
                        currentValue: cpuUserValue,
                        subtitle: "User processes",
                        data: metricsManager.cpuHistory.map { $0.userTime },
                        maxValue: 100,
                        color: .orange
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("cpu-user")
                }

                // CPU System Metric
                if settingsManager.isMetricEnabled(.cpuSystem) {
                    ModernMetricCardView(
                        type: .cpuSystem,
                        currentValue: cpuSystemValue,
                        subtitle: "System processes",
                        data: metricsManager.cpuHistory.map { $0.systemTime },
                        maxValue: 100,
                        color: .red
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("cpu-system")
                }

                // CPU Total Metric
                if settingsManager.isMetricEnabled(.cpuTotal) {
                    ModernMetricCardView(
                        type: .cpuTotal,
                        currentValue: cpuCurrentValue,
                        subtitle: cpuSubtitle,
                        data: metricsManager.cpuHistory.map { $0.userTime + $0.systemTime },
                        maxValue: 100,
                        color: .blue
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("cpu-total")
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            settingsManager.settings.showDetailedCPU.toggle()
                        }
                    }
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.showDetailedCPU) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                }

                // Memory Active Metric
                if settingsManager.isMetricEnabled(.memoryActive) {
                    ModernMetricCardView(
                        type: .memoryActive,
                        currentValue: memoryActiveValue,
                        subtitle: "Active memory",
                        data: metricsManager.memoryHistory.map { Double($0.active) / Double($0.total) * 100.0 },
                        maxValue: 100,
                        color: .green
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("memory-active")
                }

                // Memory Inactive Metric
                if settingsManager.isMetricEnabled(.memoryInactive) {
                    ModernMetricCardView(
                        type: .memoryInactive,
                        currentValue: memoryInactiveValue,
                        subtitle: "Inactive memory",
                        data: metricsManager.memoryHistory.map { Double($0.inactive) / Double($0.total) * 100.0 },
                        maxValue: 100,
                        color: .yellow
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("memory-inactive")
                }

                // Memory Wired Metric
                if settingsManager.isMetricEnabled(.memoryWired) {
                    ModernMetricCardView(
                        type: .memoryWired,
                        currentValue: memoryWiredValue,
                        subtitle: "Wired memory",
                        data: metricsManager.memoryHistory.map { Double($0.wired) / Double($0.total) * 100.0 },
                        maxValue: 100,
                        color: .purple
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("memory-wired")
                }

                // Memory Compressed Metric
                if settingsManager.isMetricEnabled(.memoryCompressed) {
                    ModernMetricCardView(
                        type: .memoryCompressed,
                        currentValue: memoryCompressedValue,
                        subtitle: "Compressed memory",
                        data: metricsManager.memoryHistory.map { Double($0.compressed) / Double($0.total) * 100.0 },
                        maxValue: 100,
                        color: .pink
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("memory-compressed")
                }

                // Memory Total Metric
                if settingsManager.isMetricEnabled(.memoryTotal) {
                    ModernMetricCardView(
                        type: .memoryTotal,
                        currentValue: String(format: "%.1f%%", metricsManager.currentMetrics.memory.usagePercentage),
                        subtitle: memorySubtitle,
                        data: metricsManager.getHistory(for: .memoryTotal),
                        maxValue: 100,
                        color: .green
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("memory-total")
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

                // Battery Metric
                if settingsManager.isMetricEnabled(.battery) {
                    ModernMetricCardView(
                        type: .battery,
                        currentValue: String(format: "%.1f%%", metricsManager.currentMetrics.battery.level),
                        subtitle: batterySubtitle,
                        data: metricsManager.getHistory(for: .battery),
                        maxValue: 100,
                        color: .yellow
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("battery")
                }

                // Disk I/O Read Metric
                if settingsManager.isMetricEnabled(.diskIORead) {
                    ModernMetricCardView(
                        type: .diskIORead,
                        currentValue: diskIOReadValue,
                        subtitle: "System paging activity",
                        data: metricsManager.diskIOHistory.map { $0.readSpeedMBps },
                        maxValue: maxDiskIOReadSpeed,
                        color: .cyan
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("diskIO-read")
                }

                // Disk I/O Write Metric
                if settingsManager.isMetricEnabled(.diskIOWrite) {
                    ModernMetricCardView(
                        type: .diskIOWrite,
                        currentValue: diskIOWriteValue,
                        subtitle: "System paging activity",
                        data: metricsManager.diskIOHistory.map { $0.writeSpeedMBps },
                        maxValue: maxDiskIOWriteSpeed,
                        color: Color(red: 1.0, green: 0.2, blue: 0.5)
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("diskIO-write")
                }

                // Disk I/O Total Metric
                if settingsManager.isMetricEnabled(.diskIOTotal) {
                    ModernMetricCardView(
                        type: .diskIOTotal,
                        currentValue: diskIOTotalValue,
                        subtitle: "Combined read and write",
                        data: metricsManager.diskIOHistory.map { $0.readSpeedMBps + $0.writeSpeedMBps },
                        maxValue: maxDiskIOTotalSpeed,
                        color: .purple
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("diskIO-total")
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
            .sensoryFeedback(.success, trigger: metricsManager.currentMetrics.timestamp) { _, _ in
                settingsManager.settings.hapticsEnabled
            }

            // PiP Video Layer (hidden, used only for PiP functionality)
            PiPVideoLayerView { layer in
                // Setup PiP with a small delay to ensure everything is ready
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    pipManager.setup(
                        with: layer,
                        metricsManager: metricsManager,
                        settingsManager: settingsManager
                    )
                }
            }
            .frame(width: 1, height: 1)
            .opacity(0.01)
            .allowsHitTesting(false)
        }
    }

    // MARK: - Computed Properties

    private var cpuUserValue: String {
        let cpu = metricsManager.currentMetrics.cpu
        return String(format: "%.1f%%", cpu.userTime)
    }

    private var cpuSystemValue: String {
        let cpu = metricsManager.currentMetrics.cpu
        return String(format: "%.1f%%", cpu.systemTime)
    }

    private var cpuCurrentValue: String {
        let cpu = metricsManager.currentMetrics.cpu

        if settingsManager.settings.showDetailedCPU {
            // Show User and System separately
            return String(format: "%.1f%% / %.1f%%", cpu.userTime, cpu.systemTime)
        } else {
            // Show total (User + System)
            let total = cpu.userTime + cpu.systemTime
            return String(format: "%.1f%%", total)
        }
    }

    private var cpuSubtitle: String {
        let cpu = metricsManager.currentMetrics.cpu

        if settingsManager.settings.showDetailedCPU {
            // Show Idle when in detailed mode
            return String(format: "User / System • Idle: %.1f%%", cpu.idleTime)
        } else {
            // Show breakdown when in total mode
            return String(format: "User: %.1f%% • System: %.1f%% • Tap for details", cpu.userTime, cpu.systemTime)
        }
    }

    private var memorySubtitle: String {
        let memory = metricsManager.currentMetrics.memory
        return String(format: "%.1f GB / %.1f GB", memory.usedGB, memory.totalGB)
    }

    private var memoryActiveValue: String {
        let memory = metricsManager.currentMetrics.memory
        let activePercentage = Double(memory.active) / Double(memory.total) * 100.0
        return String(format: "%.1f%%", activePercentage)
    }

    private var memoryInactiveValue: String {
        let memory = metricsManager.currentMetrics.memory
        let inactivePercentage = Double(memory.inactive) / Double(memory.total) * 100.0
        return String(format: "%.1f%%", inactivePercentage)
    }

    private var memoryWiredValue: String {
        let memory = metricsManager.currentMetrics.memory
        let wiredPercentage = Double(memory.wired) / Double(memory.total) * 100.0
        return String(format: "%.1f%%", wiredPercentage)
    }

    private var memoryCompressedValue: String {
        let memory = metricsManager.currentMetrics.memory
        let compressedPercentage = Double(memory.compressed) / Double(memory.total) * 100.0
        return String(format: "%.1f%%", compressedPercentage)
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

    private var batterySubtitle: String {
        let battery = metricsManager.currentMetrics.battery
        let stateText: String
        switch battery.state {
        case .charging:
            stateText = "Charging"
        case .full:
            stateText = "Fully Charged"
        case .unplugged:
            stateText = "On Battery"
        case .unknown:
            stateText = "Unknown"
        }
        return stateText
    }

    private var diskIOReadValue: String {
        let read = metricsManager.currentMetrics.diskIO.readSpeedMBps
        if read >= 1.0 {
            return String(format: "%.1f MB/s", read)
        } else {
            return String(format: "%.0f KB/s", read * 1024)
        }
    }

    private var diskIOWriteValue: String {
        let write = metricsManager.currentMetrics.diskIO.writeSpeedMBps
        if write >= 1.0 {
            return String(format: "%.1f MB/s", write)
        } else {
            return String(format: "%.0f KB/s", write * 1024)
        }
    }

    private var diskIOTotalValue: String {
        let total = metricsManager.currentMetrics.diskIO.readSpeedMBps + metricsManager.currentMetrics.diskIO.writeSpeedMBps
        if total >= 1.0 {
            return String(format: "%.1f MB/s", total)
        } else {
            return String(format: "%.0f KB/s", total * 1024)
        }
    }

    private var maxDiskIOReadSpeed: Double {
        let maxRead = metricsManager.diskIOHistory.map { $0.readSpeedMBps }.max() ?? 1.0
        return max(maxRead * 1.5, 1.0)
    }

    private var maxDiskIOWriteSpeed: Double {
        let maxWrite = metricsManager.diskIOHistory.map { $0.writeSpeedMBps }.max() ?? 1.0
        return max(maxWrite * 1.5, 1.0)
    }

    private var maxDiskIOTotalSpeed: Double {
        let maxTotal = metricsManager.diskIOHistory.map { $0.readSpeedMBps + $0.writeSpeedMBps }.max() ?? 1.0
        return max(maxTotal * 1.5, 1.0)
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
