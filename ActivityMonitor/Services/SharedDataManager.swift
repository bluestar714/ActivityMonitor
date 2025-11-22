//
//  SharedDataManager.swift
//  ActivityMonitor
//
//  Manages data sharing between main app and widgets using App Groups
//

import Foundation

class SharedDataManager {
    static let shared = SharedDataManager()

    // App Group identifier - must match in Xcode capabilities
    private let appGroupIdentifier = "group.com.activitymonitor.app"

    private var userDefaults: UserDefaults? {
        UserDefaults(suiteName: appGroupIdentifier)
    }

    private init() {}

    // MARK: - Save Metrics

    func saveCurrentMetrics(_ metrics: MetricsSnapshot) {
        guard let defaults = userDefaults else {
            print("❌ [SharedDataManager] UserDefaults for app group is nil!")
            return
        }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(metrics) {
            defaults.set(encoded, forKey: "currentMetrics")
            defaults.set(Date(), forKey: "lastUpdate")
            defaults.synchronize() // Force save
            print("✅ [SharedDataManager] Saved metrics - CPU: \(Int(metrics.cpu.usage))%, Memory: \(Int(metrics.memory.usagePercentage))%")
        } else {
            print("❌ [SharedDataManager] Failed to encode metrics")
        }
    }

    func saveMetricsHistory(cpu: [CPUMetrics], memory: [MemoryMetrics], network: [NetworkMetrics], storage: [StorageMetrics], battery: [BatteryMetrics], diskIO: [DiskIOMetrics]) {
        guard let defaults = userDefaults else { return }

        let encoder = JSONEncoder()

        if let cpuData = try? encoder.encode(cpu) {
            defaults.set(cpuData, forKey: "cpuHistory")
        }

        if let memoryData = try? encoder.encode(memory) {
            defaults.set(memoryData, forKey: "memoryHistory")
        }

        if let networkData = try? encoder.encode(network) {
            defaults.set(networkData, forKey: "networkHistory")
        }

        if let storageData = try? encoder.encode(storage) {
            defaults.set(storageData, forKey: "storageHistory")
        }

        if let batteryData = try? encoder.encode(battery) {
            defaults.set(batteryData, forKey: "batteryHistory")
        }

        if let diskIOData = try? encoder.encode(diskIO) {
            defaults.set(diskIOData, forKey: "diskIOHistory")
        }
    }

    // MARK: - Load Metrics

    func loadCurrentMetrics() -> MetricsSnapshot? {
        guard let defaults = userDefaults else {
            print("❌ [SharedDataManager] UserDefaults for app group is nil when loading!")
            return nil
        }

        guard let data = defaults.data(forKey: "currentMetrics") else {
            print("⚠️ [SharedDataManager] No data found for currentMetrics")
            return nil
        }

        let decoder = JSONDecoder()
        if let metrics = try? decoder.decode(MetricsSnapshot.self, from: data) {
            print("✅ [SharedDataManager] Loaded metrics - CPU: \(Int(metrics.cpu.usage))%, Memory: \(Int(metrics.memory.usagePercentage))%")
            if let lastUpdate = defaults.object(forKey: "lastUpdate") as? Date {
                let age = Date().timeIntervalSince(lastUpdate)
                print("📅 [SharedDataManager] Data age: \(Int(age)) seconds")
            }
            return metrics
        } else {
            print("❌ [SharedDataManager] Failed to decode metrics data")
            return nil
        }
    }

    func loadCPUHistory() -> [CPUMetrics] {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "cpuHistory") else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([CPUMetrics].self, from: data)) ?? []
    }

    func loadMemoryHistory() -> [MemoryMetrics] {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "memoryHistory") else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([MemoryMetrics].self, from: data)) ?? []
    }

    func loadNetworkHistory() -> [NetworkMetrics] {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "networkHistory") else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([NetworkMetrics].self, from: data)) ?? []
    }

    func loadStorageHistory() -> [StorageMetrics] {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "storageHistory") else {
            return []
        }

        let decoder = JSONDecoder()
        return (try? decoder.decode([StorageMetrics].self, from: data)) ?? []
    }

    func getLastUpdateDate() -> Date? {
        return userDefaults?.object(forKey: "lastUpdate") as? Date
    }

    // MARK: - Widget Settings

    func saveWidgetSettings(metric1: MetricType, metric2: MetricType) {
        guard let defaults = userDefaults else { return }

        defaults.set(metric1.rawValue, forKey: "widgetMetric1")
        defaults.set(metric2.rawValue, forKey: "widgetMetric2")
        defaults.synchronize()

        print("✅ [SharedDataManager] Saved widget settings - Metric 1: \(metric1.rawValue), Metric 2: \(metric2.rawValue)")
    }

    func loadWidgetSettings() -> (MetricType, MetricType) {
        guard let defaults = userDefaults else {
            print("⚠️ [SharedDataManager] UserDefaults nil, using default widget settings")
            return (.cpuTotal, .memoryTotal)
        }

        let metric1String = defaults.string(forKey: "widgetMetric1") ?? "CPU Total"
        let metric2String = defaults.string(forKey: "widgetMetric2") ?? "Memory Total"

        let metric1 = MetricType(rawValue: metric1String) ?? .cpuTotal
        let metric2 = MetricType(rawValue: metric2String) ?? .memoryTotal

        print("✅ [SharedDataManager] Loaded widget settings - Metric 1: \(metric1.rawValue), Metric 2: \(metric2.rawValue)")

        return (metric1, metric2)
    }

    // MARK: - Clear Data

    func clearAllData() {
        guard let defaults = userDefaults else { return }

        defaults.removeObject(forKey: "currentMetrics")
        defaults.removeObject(forKey: "cpuHistory")
        defaults.removeObject(forKey: "memoryHistory")
        defaults.removeObject(forKey: "networkHistory")
        defaults.removeObject(forKey: "storageHistory")
        defaults.removeObject(forKey: "lastUpdate")
    }
}
