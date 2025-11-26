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
    @State private var showNetworkDetails = false

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            // Main content
            ScrollView {
            VStack(spacing: 18) {
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

                // CPU User Metric
                if settingsManager.isMetricEnabled(.cpuUser) && settingsManager.settings.showDetailedCPU {
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
                if settingsManager.isMetricEnabled(.cpuSystem) && settingsManager.settings.showDetailedCPU {
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
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            settingsManager.settings.showDetailedMemory.toggle()
                        }
                    }
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.showDetailedMemory) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                }

                // Memory Active Metric
                if settingsManager.isMetricEnabled(.memoryActive) && settingsManager.settings.showDetailedMemory {
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
                if settingsManager.isMetricEnabled(.memoryInactive) && settingsManager.settings.showDetailedMemory {
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
                if settingsManager.isMetricEnabled(.memoryWired) && settingsManager.settings.showDetailedMemory {
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
                if settingsManager.isMetricEnabled(.memoryCompressed) && settingsManager.settings.showDetailedMemory {
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

                // Network Total Metric
                if settingsManager.isMetricEnabled(.networkTotal) {
                    ModernMetricCardView(
                        type: .networkTotal,
                        currentValue: networkTotalValue,
                        subtitle: networkTotalSubtitle,
                        data: metricsManager.getHistory(for: .networkTotal),
                        maxValue: maxNetworkTotalSpeed,
                        color: .orange
                    ) {
                        // Info button for network details
                        Button {
                            Task {
                                await metricsManager.refreshNetworkDetails()
                                showNetworkDetails = true
                            }
                        } label: {
                            Image(systemName: "info.circle.fill")
                                .font(.system(size: 16))
                                .foregroundStyle(.orange.gradient)
                                .symbolRenderingMode(.hierarchical)
                        }
                        .buttonStyle(.plain)
                    }
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            settingsManager.settings.showDetailedNetwork.toggle()
                        }
                    }
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.showDetailedNetwork) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("network-total")
                }

                // Network Download Metric
                if settingsManager.isMetricEnabled(.networkDownload) && settingsManager.settings.showDetailedNetwork {
                    ModernMetricCardView(
                        type: .networkDownload,
                        currentValue: networkDownloadValue,
                        subtitle: "Download speed",
                        data: metricsManager.getHistory(for: .networkDownload),
                        maxValue: maxNetworkDownloadSpeed,
                        color: .green
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("network-download")
                }

                // Network Upload Metric
                if settingsManager.isMetricEnabled(.networkUpload) && settingsManager.settings.showDetailedNetwork {
                    ModernMetricCardView(
                        type: .networkUpload,
                        currentValue: networkUploadValue,
                        subtitle: "Upload speed",
                        data: metricsManager.getHistory(for: .networkUpload),
                        maxValue: maxNetworkUploadSpeed,
                        color: .blue
                    )
                    .transition(.asymmetric(
                        insertion: .scale(scale: 0.9).combined(with: .opacity).combined(with: .move(edge: .top)),
                        removal: .scale(scale: 0.9).combined(with: .opacity)
                    ))
                    .id("network-upload")
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
                    .onTapGesture {
                        withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                            settingsManager.settings.showDetailedDiskIO.toggle()
                        }
                    }
                    .sensoryFeedback(.selection, trigger: settingsManager.settings.showDetailedDiskIO) { _, _ in
                        settingsManager.settings.hapticsEnabled
                    }
                }

                // Disk I/O Read Metric
                if settingsManager.isMetricEnabled(.diskIORead) && settingsManager.settings.showDetailedDiskIO {
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
                if settingsManager.isMetricEnabled(.diskIOWrite) && settingsManager.settings.showDetailedDiskIO {
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
            }
            .padding(20)
            .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3), value: settingsManager.settings.enabledMetrics)
            .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3), value: settingsManager.settings.showDetailedCPU)
            .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3), value: settingsManager.settings.showDetailedMemory)
            .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3), value: settingsManager.settings.showDetailedNetwork)
            .animation(.spring(response: 0.5, dampingFraction: 0.75, blendDuration: 0.3), value: settingsManager.settings.showDetailedDiskIO)
            }
            .background {
                ZStack {
                    // Base gradient background
                    LinearGradient(
                        colors: [
                            Color.blue.opacity(0.15),
                            Color.purple.opacity(0.12),
                            Color.pink.opacity(0.08),
                            Color.orange.opacity(0.06)
                        ],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                    .ignoresSafeArea()

                    // Animated gradient overlay
                    RadialGradient(
                        colors: [
                            Color.cyan.opacity(0.1),
                            Color.blue.opacity(0.05),
                            .clear
                        ],
                        center: .topTrailing,
                        startRadius: 0,
                        endRadius: 500
                    )
                    .ignoresSafeArea()

                    // Glass layer
                    Color(.systemGroupedBackground)
                        .opacity(0.7)
                        .blur(radius: 0.5)
                        .ignoresSafeArea()

                    // Subtle noise texture effect
                    Rectangle()
                        .fill(.regularMaterial)
                        .opacity(0.15)
                        .ignoresSafeArea()
                }
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
        .sheet(isPresented: $showNetworkDetails) {
            NetworkDetailsView(networkDetails: metricsManager.networkDetails)
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
        let total = cpu.userTime + cpu.systemTime
        return String(format: "%.1f%%", total)
    }

    private var cpuSubtitle: String {
        let cpu = metricsManager.currentMetrics.cpu
        return String(format: "User: %.1f%% • System: %.1f%% • Idle: %.1f%%", cpu.userTime, cpu.systemTime, cpu.idleTime)
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

    private var networkTotalValue: String {
        let network = metricsManager.currentMetrics.network
        let total = network.downloadSpeedMBps + network.uploadSpeedMBps
        if total >= 1.0 {
            return String(format: "%.1f MB/s", total)
        } else {
            return String(format: "%.0f KB/s", total * 1024)
        }
    }

    private var networkTotalSubtitle: String {
        let network = metricsManager.currentMetrics.network
        let download = network.downloadSpeedMBps
        let upload = network.uploadSpeedMBps

        let downloadStr: String
        if download >= 1.0 {
            downloadStr = String(format: "↓ %.1f MB/s", download)
        } else {
            downloadStr = String(format: "↓ %.0f KB/s", download * 1024)
        }

        let uploadStr: String
        if upload >= 1.0 {
            uploadStr = String(format: "↑ %.1f MB/s", upload)
        } else {
            uploadStr = String(format: "↑ %.0f KB/s", upload * 1024)
        }

        return "\(downloadStr) • \(uploadStr) • Tap for details"
    }

    private var networkDownloadValue: String {
        let network = metricsManager.currentMetrics.network
        let download = network.downloadSpeedMBps
        if download >= 1.0 {
            return String(format: "%.1f MB/s", download)
        } else {
            return String(format: "%.0f KB/s", download * 1024)
        }
    }

    private var networkUploadValue: String {
        let network = metricsManager.currentMetrics.network
        let upload = network.uploadSpeedMBps
        if upload >= 1.0 {
            return String(format: "%.1f MB/s", upload)
        } else {
            return String(format: "%.0f KB/s", upload * 1024)
        }
    }

    private var maxNetworkDownloadSpeed: Double {
        let currentDownload = metricsManager.currentMetrics.network.downloadSpeedMBps
        let maxDownload = metricsManager.networkHistory.map { $0.downloadSpeedMBps }.max() ?? 1.0
        let overallMax = max(currentDownload, maxDownload)
        return max(overallMax * 1.5, 1.0)
    }

    private var maxNetworkUploadSpeed: Double {
        let currentUpload = metricsManager.currentMetrics.network.uploadSpeedMBps
        let maxUpload = metricsManager.networkHistory.map { $0.uploadSpeedMBps }.max() ?? 1.0
        let overallMax = max(currentUpload, maxUpload)
        return max(overallMax * 1.5, 1.0)
    }

    private var maxNetworkTotalSpeed: Double {
        let currentTotal = metricsManager.currentMetrics.network.downloadSpeedMBps + metricsManager.currentMetrics.network.uploadSpeedMBps
        let maxTotal = metricsManager.networkHistory.map { $0.downloadSpeedMBps + $0.uploadSpeedMBps }.max() ?? 1.0
        let overallMax = max(currentTotal, maxTotal)
        return max(overallMax * 1.5, 1.0)
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

// MARK: - Network Details View

@available(iOS 17.0, *)
struct NetworkDetailsView: View {
    @Environment(\.dismiss) private var dismiss
    let networkDetails: NetworkDetails

    var body: some View {
        NavigationStack {
            List {
                // Connection Status
                Section {
                    DetailRow(label: "Interface Type", value: networkDetails.interfaceType, icon: "network")
                    if let interfaceName = networkDetails.interfaceName {
                        DetailRow(label: "Interface Name", value: interfaceName, icon: "laptopcomputer")
                    }
                    if networkDetails.isVPNActive {
                        DetailRow(label: "VPN", value: "Connected", icon: "lock.shield.fill", valueColor: .green)
                    }
                    if networkDetails.isHotspotActive {
                        DetailRow(label: "Personal Hotspot", value: "Active", icon: "personalhotspot", valueColor: .orange)
                    }
                } header: {
                    Text("Connection Status")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }

                // IP Configuration
                Section {
                    if let ipv4 = networkDetails.ipv4Address {
                        CopyableDetailRow(label: "IPv4 Address", value: ipv4, icon: "number.circle.fill")
                    }
                    if let ipv6 = networkDetails.ipv6Address {
                        CopyableDetailRow(label: "IPv6 Address", value: ipv6, icon: "number.circle.fill")
                    }
                    if let subnetMask = networkDetails.subnetMask {
                        DetailRow(label: "Subnet Mask", value: subnetMask, icon: "network.badge.shield.half.filled")
                    }
                    if let gateway = networkDetails.defaultGateway {
                        CopyableDetailRow(label: "Default Gateway", value: gateway, icon: "arrow.triangle.branch")
                    }
                    if let externalIP = networkDetails.externalIP {
                        CopyableDetailRow(label: "External IP", value: externalIP, icon: "globe")
                    }
                } header: {
                    Text("IP Configuration")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }

                // DNS
                if !networkDetails.dnsServers.isEmpty {
                    Section {
                        ForEach(Array(networkDetails.dnsServers.enumerated()), id: \.offset) { index, dns in
                            CopyableDetailRow(label: "DNS \(index + 1)", value: dns, icon: "server.rack")
                        }
                    } header: {
                        Text("DNS Servers")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }

                // WiFi Information
                if networkDetails.ssid != nil || networkDetails.bssid != nil {
                    Section {
                        if let ssid = networkDetails.ssid {
                            DetailRow(label: "SSID", value: ssid, icon: "wifi")
                        }
                        if let bssid = networkDetails.bssid {
                            CopyableDetailRow(label: "BSSID", value: bssid, icon: "antenna.radiowaves.left.and.right")
                        }
                        if let rssi = networkDetails.rssi {
                            DetailRow(label: "Signal Strength", value: "\(rssi) dBm", icon: "wifi.circle.fill")
                        }
                        if let securityType = networkDetails.securityType {
                            DetailRow(label: "Security Type", value: securityType, icon: "lock.fill")
                        }
                        if let wifiBand = networkDetails.wifiBand {
                            DetailRow(label: "Band", value: wifiBand, icon: "waveform")
                        }
                    } header: {
                        Text("WiFi Information")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }

                // Cellular Information
                if networkDetails.carrierName != nil || networkDetails.connectionType != nil {
                    Section {
                        if let carrier = networkDetails.carrierName {
                            DetailRow(label: "Carrier", value: carrier, icon: "antenna.radiowaves.left.and.right.circle.fill")
                        }
                        if let connectionType = networkDetails.connectionType {
                            DetailRow(label: "Connection Type", value: connectionType, icon: "cellularbars")
                        }
                        if let cellularBand = networkDetails.cellularBand {
                            DetailRow(label: "Band", value: cellularBand, icon: "waveform.circle")
                        }
                        if let phoneNumber = networkDetails.phoneNumber {
                            CopyableDetailRow(label: "Phone Number", value: phoneNumber, icon: "phone.fill")
                        }
                        if let mcc = networkDetails.mobileCountryCode {
                            DetailRow(label: "Mobile Country Code", value: mcc, icon: "globe.asia.australia.fill")
                        }
                        if let mnc = networkDetails.mobileNetworkCode {
                            DetailRow(label: "Mobile Network Code", value: mnc, icon: "antenna.radiowaves.left.and.right")
                        }
                        if let iso = networkDetails.isoCountryCode {
                            DetailRow(label: "Country Code", value: iso, icon: "flag.fill")
                        }
                        if let voip = networkDetails.allowsVOIP {
                            DetailRow(label: "VoIP Support", value: voip ? "Yes" : "No", icon: "phone.connection")
                        }
                    } header: {
                        Text("Cellular Information")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }

                // Proxy
                if networkDetails.isProxyEnabled {
                    Section {
                        DetailRow(label: "Proxy Status", value: "Enabled", icon: "arrow.left.arrow.right.circle.fill", valueColor: .orange)
                        if let proxy = networkDetails.proxyServer {
                            CopyableDetailRow(label: "Proxy Server", value: proxy, icon: "server.rack")
                        }
                    } header: {
                        Text("Proxy Configuration")
                            .font(.system(size: 13, weight: .semibold, design: .rounded))
                    }
                }

                // Data Usage
                Section {
                    DetailRow(
                        label: "Total Sent",
                        value: formatBytes(networkDetails.totalBytesSent),
                        icon: "arrow.up.circle.fill",
                        valueColor: .blue
                    )
                    DetailRow(
                        label: "Total Received",
                        value: formatBytes(networkDetails.totalBytesReceived),
                        icon: "arrow.down.circle.fill",
                        valueColor: .green
                    )
                } header: {
                    Text("Data Usage (Session)")
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                }
            }
            .listStyle(.insetGrouped)
            .navigationTitle("Network Details")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        dismiss()
                    } label: {
                        Text("Done")
                            .font(.system(size: 16, weight: .semibold, design: .rounded))
                    }
                }
            }
        }
    }

    private func formatBytes(_ bytes: UInt64) -> String {
        let formatter = ByteCountFormatter()
        formatter.allowedUnits = [.useAll]
        formatter.countStyle = .file
        return formatter.string(fromByteCount: Int64(bytes))
    }
}

// MARK: - Detail Row

struct DetailRow: View {
    let label: String
    let value: String
    let icon: String
    var valueColor: Color = .primary

    var body: some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 18))
            }

            Spacer()

            Text(value)
                .font(.system(size: 15, design: .monospaced))
                .foregroundStyle(valueColor)
                .textSelection(.enabled)
        }
    }
}

// MARK: - Copyable Detail Row

struct CopyableDetailRow: View {
    let label: String
    let value: String
    let icon: String
    @State private var showCopied = false

    var body: some View {
        HStack {
            Label {
                Text(label)
                    .font(.system(size: 16, weight: .medium, design: .rounded))
            } icon: {
                Image(systemName: icon)
                    .foregroundStyle(.blue.gradient)
                    .symbolRenderingMode(.hierarchical)
                    .font(.system(size: 18))
            }

            Spacer()

            HStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 15, design: .monospaced))
                    .foregroundStyle(.primary)
                    .textSelection(.enabled)

                Button {
                    UIPasteboard.general.string = value
                    withAnimation {
                        showCopied = true
                    }

                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                        withAnimation {
                            showCopied = false
                        }
                    }
                } label: {
                    Image(systemName: showCopied ? "checkmark.circle.fill" : "doc.on.doc")
                        .foregroundStyle(showCopied ? .green : .blue)
                        .font(.system(size: 16))
                        .symbolEffect(.bounce, value: showCopied)
                }
                .buttonStyle(.plain)
            }
        }
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
