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
        guard let defaults = userDefaults else { return }

        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(metrics) {
            defaults.set(encoded, forKey: "currentMetrics")
            defaults.set(Date(), forKey: "lastUpdate")
        }
    }

    func saveMetricsHistory(cpu: [CPUMetrics], memory: [MemoryMetrics], network: [NetworkMetrics], storage: [StorageMetrics]) {
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
    }

    // MARK: - Load Metrics

    func loadCurrentMetrics() -> MetricsSnapshot? {
        guard let defaults = userDefaults,
              let data = defaults.data(forKey: "currentMetrics") else {
            return nil
        }

        let decoder = JSONDecoder()
        return try? decoder.decode(MetricsSnapshot.self, from: data)
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
