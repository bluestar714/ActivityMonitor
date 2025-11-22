//
//  MetricsManager.swift
//  ActivityMonitor
//
//  Manages metrics collection and distribution to views (iOS 17+)
//

import Foundation
import Observation
import WidgetKit

@Observable
@MainActor
class MetricsManager {
    static let shared = MetricsManager()

    var currentMetrics: MetricsSnapshot = .zero
    var cpuHistory: [CPUMetrics] = []
    var memoryHistory: [MemoryMetrics] = []
    var networkHistory: [NetworkMetrics] = []
    var storageHistory: [StorageMetrics] = []
    var batteryHistory: [BatteryMetrics] = []
    var diskIOHistory: [DiskIOMetrics] = []

    private let collector = SystemMetricsCollector()
    private var timer: Timer?
    private let settingsManager = SettingsManager.shared
    private let sharedDataManager = SharedDataManager.shared

    private var maxDataPoints: Int {
        return settingsManager.settings.maxDataPoints
    }

    private init() {}

    // MARK: - Background Support

    func saveToSharedStorage() {
        sharedDataManager.saveCurrentMetrics(currentMetrics)
        sharedDataManager.saveMetricsHistory(
            cpu: cpuHistory,
            memory: memoryHistory,
            network: networkHistory,
            storage: storageHistory,
            battery: batteryHistory,
            diskIO: diskIOHistory
        )

        // Tell all widgets to reload their timelines with new data
        WidgetCenter.shared.reloadAllTimelines()
    }

    // MARK: - Monitoring Control

    func startMonitoring() {
        stopMonitoring() // Ensure no duplicate timers

        let interval = settingsManager.settings.refreshInterval

        // Initial collection
        Task {
            await collectMetrics()
        }

        // Schedule periodic collection
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            Task { @MainActor [weak self] in
                await self?.collectMetrics()
            }
        }

        // Ensure timer works in background modes
        if let timer = timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func stopMonitoring() {
        timer?.invalidate()
        timer = nil
    }

    // MARK: - Data Collection

    private func collectMetrics() async {
        let snapshot = await Task.detached(priority: .userInitiated) { [weak self] in
            self?.collector.collectAllMetrics() ?? .zero
        }.value

        currentMetrics = snapshot

        // Update histories - CPU history is collected if any CPU metric is enabled
        if settingsManager.isMetricEnabled(.cpuUser) || settingsManager.isMetricEnabled(.cpuSystem) || settingsManager.isMetricEnabled(.cpuTotal) {
            cpuHistory.append(snapshot.cpu)
            if cpuHistory.count > maxDataPoints {
                cpuHistory.removeFirst()
            }
        }

        // Memory history is collected if any Memory metric is enabled
        if settingsManager.isMetricEnabled(.memoryActive) || settingsManager.isMetricEnabled(.memoryInactive) || settingsManager.isMetricEnabled(.memoryWired) || settingsManager.isMetricEnabled(.memoryCompressed) || settingsManager.isMetricEnabled(.memoryTotal) {
            memoryHistory.append(snapshot.memory)
            if memoryHistory.count > maxDataPoints {
                memoryHistory.removeFirst()
            }
        }

        if settingsManager.isMetricEnabled(.network) {
            networkHistory.append(snapshot.network)
            if networkHistory.count > maxDataPoints {
                networkHistory.removeFirst()
            }
        }

        if settingsManager.isMetricEnabled(.storage) {
            storageHistory.append(snapshot.storage)
            if storageHistory.count > maxDataPoints {
                storageHistory.removeFirst()
            }
        }

        if settingsManager.isMetricEnabled(.battery) {
            batteryHistory.append(snapshot.battery)
            if batteryHistory.count > maxDataPoints {
                batteryHistory.removeFirst()
            }
        }

        // Disk I/O history is collected if any of the three disk I/O metrics are enabled
        if settingsManager.isMetricEnabled(.diskIORead) || settingsManager.isMetricEnabled(.diskIOWrite) || settingsManager.isMetricEnabled(.diskIOTotal) {
            diskIOHistory.append(snapshot.diskIO)
            if diskIOHistory.count > maxDataPoints {
                diskIOHistory.removeFirst()
            }
        }

        // Save to shared storage for widgets and Live Activities
        saveToSharedStorage()

        // Check thresholds and send notifications
        Task { @MainActor in
            let notificationManager = NotificationManager.shared
            notificationManager.checkMetricsAndNotify(metrics: snapshot)
        }

        // Update Live Activities if running (iOS 16.1+)
        if #available(iOS 16.1, *) {
            Task { @MainActor in
                let liveActivityManager = LiveActivityManager.shared
                liveActivityManager.updateLiveActivity(with: snapshot)
            }
        }
    }

    // MARK: - Data Access

    func getHistory(for type: MetricType) -> [Double] {
        switch type {
        case .cpuUser:
            return cpuHistory.map { $0.userTime }
        case .cpuSystem:
            return cpuHistory.map { $0.systemTime }
        case .cpuTotal:
            return cpuHistory.map { $0.userTime + $0.systemTime }
        case .memoryActive:
            return memoryHistory.map { Double($0.active) / Double($0.total) * 100.0 }
        case .memoryInactive:
            return memoryHistory.map { Double($0.inactive) / Double($0.total) * 100.0 }
        case .memoryWired:
            return memoryHistory.map { Double($0.wired) / Double($0.total) * 100.0 }
        case .memoryCompressed:
            return memoryHistory.map { Double($0.compressed) / Double($0.total) * 100.0 }
        case .memoryTotal:
            return memoryHistory.map { $0.usagePercentage }
        case .network:
            return networkHistory.map { $0.downloadSpeed }
        case .storage:
            return storageHistory.map { $0.usagePercentage }
        case .battery:
            return batteryHistory.map { $0.level }
        case .diskIORead:
            return diskIOHistory.map { $0.readSpeed }
        case .diskIOWrite:
            return diskIOHistory.map { $0.writeSpeed }
        case .diskIOTotal:
            return diskIOHistory.map { $0.readSpeed + $0.writeSpeed }
        }
    }

    func clearHistory() {
        cpuHistory.removeAll()
        memoryHistory.removeAll()
        networkHistory.removeAll()
        storageHistory.removeAll()
        batteryHistory.removeAll()
        diskIOHistory.removeAll()
    }
}
