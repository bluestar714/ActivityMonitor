//
//  MetricsData.swift
//  ActivityMonitor
//
//  Data models for system performance metrics
//

import Foundation

// MARK: - Metric Types

enum MetricType: String, CaseIterable, Codable {
    case cpu = "CPU"
    case memory = "Memory"
    case network = "Network"
    case storage = "Storage"

    var icon: String {
        switch self {
        case .cpu: return "cpu"
        case .memory: return "memorychip"
        case .network: return "network"
        case .storage: return "internaldrive"
        }
    }
}

// MARK: - CPU Metrics

struct CPUMetrics: Codable {
    let usage: Double // Percentage 0-100
    let userTime: Double
    let systemTime: Double
    let idleTime: Double
    let timestamp: Date

    // Computed properties for Widget compatibility
    var userPercentage: Double {
        return userTime
    }

    var systemPercentage: Double {
        return systemTime
    }

    var idlePercentage: Double {
        return idleTime
    }

    static let zero = CPUMetrics(
        usage: 0,
        userTime: 0,
        systemTime: 0,
        idleTime: 100,
        timestamp: Date()
    )
}

// MARK: - Memory Metrics

struct MemoryMetrics: Codable {
    let used: UInt64 // Bytes
    let total: UInt64
    let free: UInt64
    let active: UInt64
    let inactive: UInt64
    let wired: UInt64
    let compressed: UInt64
    let timestamp: Date

    var usagePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100.0
    }

    var usedGB: Double {
        return Double(used) / 1_073_741_824.0
    }

    var totalGB: Double {
        return Double(total) / 1_073_741_824.0
    }

    var freeGB: Double {
        return Double(free) / 1_073_741_824.0
    }

    var activeGB: Double {
        return Double(active) / 1_073_741_824.0
    }

    var inactiveGB: Double {
        return Double(inactive) / 1_073_741_824.0
    }

    var wiredGB: Double {
        return Double(wired) / 1_073_741_824.0
    }

    var compressedGB: Double {
        return Double(compressed) / 1_073_741_824.0
    }

    static let zero = MemoryMetrics(
        used: 0,
        total: 0,
        free: 0,
        active: 0,
        inactive: 0,
        wired: 0,
        compressed: 0,
        timestamp: Date()
    )
}

// MARK: - Network Metrics

struct NetworkMetrics: Codable {
    let bytesReceived: UInt64
    let bytesSent: UInt64
    let packetsReceived: UInt64
    let packetsSent: UInt64
    let downloadSpeed: Double // Bytes per second
    let uploadSpeed: Double
    let timestamp: Date

    var downloadSpeedMBps: Double {
        return downloadSpeed / 1_048_576.0
    }

    var uploadSpeedMBps: Double {
        return uploadSpeed / 1_048_576.0
    }

    static let zero = NetworkMetrics(
        bytesReceived: 0,
        bytesSent: 0,
        packetsReceived: 0,
        packetsSent: 0,
        downloadSpeed: 0,
        uploadSpeed: 0,
        timestamp: Date()
    )
}

// MARK: - Storage Metrics

struct StorageMetrics: Codable {
    let total: UInt64 // Bytes
    let used: UInt64
    let free: UInt64
    let timestamp: Date

    var usagePercentage: Double {
        guard total > 0 else { return 0 }
        return Double(used) / Double(total) * 100.0
    }

    var freeGB: Double {
        return Double(free) / 1_073_741_824.0
    }

    var totalGB: Double {
        return Double(total) / 1_073_741_824.0
    }

    var usedGB: Double {
        return Double(used) / 1_073_741_824.0
    }

    var freeSpaceGB: Double {
        return freeGB
    }

    var totalSpaceGB: Double {
        return totalGB
    }

    var usedSpaceGB: Double {
        return usedGB
    }

    static let zero = StorageMetrics(
        total: 0,
        used: 0,
        free: 0,
        timestamp: Date()
    )
}

// MARK: - Metrics Snapshot

struct MetricsSnapshot: Codable {
    let cpu: CPUMetrics
    let memory: MemoryMetrics
    let network: NetworkMetrics
    let storage: StorageMetrics
    let timestamp: Date

    static let zero = MetricsSnapshot(
        cpu: .zero,
        memory: .zero,
        network: .zero,
        storage: .zero,
        timestamp: Date()
    )
}
