//
//  MetricsManager.swift
//  ActivityMonitor
//
//  Manages metrics collection and distribution to views (iOS 17+)
//

import Foundation
import Observation

@Observable
@MainActor
class MetricsManager {
    static let shared = MetricsManager()

    var currentMetrics: MetricsSnapshot = .zero
    var cpuHistory: [CPUMetrics] = []
    var memoryHistory: [MemoryMetrics] = []
    var networkHistory: [NetworkMetrics] = []
    var storageHistory: [StorageMetrics] = []

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
            storage: storageHistory
        )
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

        // Update histories
        if settingsManager.isMetricEnabled(.cpu) {
            cpuHistory.append(snapshot.cpu)
            if cpuHistory.count > maxDataPoints {
                cpuHistory.removeFirst()
            }
        }

        if settingsManager.isMetricEnabled(.memory) {
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
        case .cpu:
            return cpuHistory.map { $0.usage }
        case .memory:
            return memoryHistory.map { $0.usagePercentage }
        case .network:
            return networkHistory.map { $0.downloadSpeed }
        case .storage:
            return storageHistory.map { $0.usagePercentage }
        }
    }

    func clearHistory() {
        cpuHistory.removeAll()
        memoryHistory.removeAll()
        networkHistory.removeAll()
        storageHistory.removeAll()
    }
}
