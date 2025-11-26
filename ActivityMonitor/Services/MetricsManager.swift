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
    var networkDetails: NetworkDetails = .zero

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

        // Network history is collected if any Network metric is enabled
        if settingsManager.isMetricEnabled(.networkDownload) || settingsManager.isMetricEnabled(.networkUpload) || settingsManager.isMetricEnabled(.networkTotal) {
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
        case .networkDownload:
            return networkHistory.map { $0.downloadSpeedMBps }
        case .networkUpload:
            return networkHistory.map { $0.uploadSpeedMBps }
        case .networkTotal:
            return networkHistory.map { $0.downloadSpeedMBps + $0.uploadSpeedMBps }
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

    // MARK: - Performance Optimization

    func optimizePerformance() async -> (freedMemory: Double, clearedCache: Double) {
        // Clear temporary files
        let tempDir = FileManager.default.temporaryDirectory
        var clearedSize: UInt64 = 0

        do {
            let tempFiles = try FileManager.default.contentsOfDirectory(at: tempDir, includingPropertiesForKeys: [.fileSizeKey])
            for fileURL in tempFiles {
                if let fileSize = try? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    clearedSize += UInt64(fileSize)
                }
                try? FileManager.default.removeItem(at: fileURL)
            }
        } catch {
            print("Error clearing temp files: \(error)")
        }

        // Clear URL cache
        URLCache.shared.removeAllCachedResponses()

        // Capture memory before optimization
        let memoryBefore = currentMetrics.memory.usedGB

        // Request memory pressure to encourage iOS to free memory
        // Note: This is done through collecting new metrics
        await collectMetrics()

        // Small delay to allow system to respond
        try? await Task.sleep(nanoseconds: 500_000_000)

        // Collect metrics again to see the effect
        await collectMetrics()

        let memoryAfter = currentMetrics.memory.usedGB
        let freedMemory = max(0, memoryBefore - memoryAfter)
        let clearedCache = Double(clearedSize) / 1_073_741_824.0 // Convert to GB

        return (freedMemory, clearedCache)
    }

    func refreshNetworkDetails() async {
        networkDetails = await Task.detached(priority: .userInitiated) { [weak self] in
            self?.collector.collectNetworkDetails() ?? .zero
        }.value
    }

    // MARK: - Data Export

    func exportDataAsCSV() -> URL? {
        var csvString = "Timestamp,CPU User (%),CPU System (%),CPU Total (%),Memory Used (GB),Memory Total (GB),Memory Usage (%),Network Download (MB/s),Network Upload (MB/s),Storage Used (GB),Storage Total (GB),Storage Usage (%),Battery Level (%),Disk I/O Read (MB/s),Disk I/O Write (MB/s)\n"

        // Find the maximum count among all histories
        let maxCount = max(
            cpuHistory.count,
            memoryHistory.count,
            networkHistory.count,
            storageHistory.count,
            batteryHistory.count,
            diskIOHistory.count
        )

        // Export data row by row
        for i in 0..<maxCount {
            var row: [String] = []

            // Timestamp (use the first available timestamp)
            let timestamp: Date
            if i < cpuHistory.count {
                timestamp = cpuHistory[i].timestamp
            } else if i < memoryHistory.count {
                timestamp = memoryHistory[i].timestamp
            } else if i < networkHistory.count {
                timestamp = networkHistory[i].timestamp
            } else if i < storageHistory.count {
                timestamp = storageHistory[i].timestamp
            } else if i < batteryHistory.count {
                timestamp = batteryHistory[i].timestamp
            } else if i < diskIOHistory.count {
                timestamp = diskIOHistory[i].timestamp
            } else {
                timestamp = Date()
            }

            let dateFormatter = ISO8601DateFormatter()
            row.append(dateFormatter.string(from: timestamp))

            // CPU data
            if i < cpuHistory.count {
                let cpu = cpuHistory[i]
                row.append(String(format: "%.2f", cpu.userTime))
                row.append(String(format: "%.2f", cpu.systemTime))
                row.append(String(format: "%.2f", cpu.userTime + cpu.systemTime))
            } else {
                row.append("")
                row.append("")
                row.append("")
            }

            // Memory data
            if i < memoryHistory.count {
                let memory = memoryHistory[i]
                row.append(String(format: "%.2f", memory.usedGB))
                row.append(String(format: "%.2f", memory.totalGB))
                row.append(String(format: "%.2f", memory.usagePercentage))
            } else {
                row.append("")
                row.append("")
                row.append("")
            }

            // Network data
            if i < networkHistory.count {
                let network = networkHistory[i]
                row.append(String(format: "%.2f", network.downloadSpeedMBps))
                row.append(String(format: "%.2f", network.uploadSpeedMBps))
            } else {
                row.append("")
                row.append("")
            }

            // Storage data
            if i < storageHistory.count {
                let storage = storageHistory[i]
                row.append(String(format: "%.2f", storage.usedGB))
                row.append(String(format: "%.2f", storage.totalGB))
                row.append(String(format: "%.2f", storage.usagePercentage))
            } else {
                row.append("")
                row.append("")
                row.append("")
            }

            // Battery data
            if i < batteryHistory.count {
                let battery = batteryHistory[i]
                row.append(String(format: "%.2f", battery.level))
            } else {
                row.append("")
            }

            // Disk I/O data
            if i < diskIOHistory.count {
                let diskIO = diskIOHistory[i]
                row.append(String(format: "%.2f", diskIO.readSpeedMBps))
                row.append(String(format: "%.2f", diskIO.writeSpeedMBps))
            } else {
                row.append("")
                row.append("")
            }

            csvString += row.joined(separator: ",") + "\n"
        }

        // Save to temporary file
        let fileName = "ActivityMonitor_Export_\(Date().timeIntervalSince1970).csv"
        let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent(fileName)

        do {
            try csvString.write(to: tempURL, atomically: true, encoding: .utf8)
            return tempURL
        } catch {
            print("Error writing CSV file: \(error)")
            return nil
        }
    }
}
