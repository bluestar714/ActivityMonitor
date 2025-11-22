//
//  MetricsData.swift
//  ActivityMonitor
//
//  Data models for system performance metrics
//

import Foundation

// MARK: - Metric Types

enum MetricType: String, CaseIterable, Codable {
    case cpuUser = "CPU User"
    case cpuSystem = "CPU System"
    case cpuTotal = "CPU Total"
    case memoryActive = "Memory Active"
    case memoryInactive = "Memory Inactive"
    case memoryWired = "Memory Wired"
    case memoryCompressed = "Memory Compressed"
    case memoryTotal = "Memory Total"
    case network = "Network"
    case storage = "Storage"
    case battery = "Battery"
    case diskIORead = "Disk I/O Read"
    case diskIOWrite = "Disk I/O Write"
    case diskIOTotal = "Disk I/O Total"

    var icon: String {
        switch self {
        case .cpuUser: return "person.fill"
        case .cpuSystem: return "gearshape.fill"
        case .cpuTotal: return "cpu"
        case .memoryActive: return "bolt.fill"
        case .memoryInactive: return "pause.fill"
        case .memoryWired: return "pin.fill"
        case .memoryCompressed: return "arrow.down.square.fill"
        case .memoryTotal: return "memorychip"
        case .network: return "network"
        case .storage: return "internaldrive"
        case .battery: return "battery.100"
        case .diskIORead: return "arrow.down.circle"
        case .diskIOWrite: return "arrow.up.circle"
        case .diskIOTotal: return "cylinder.split.1x2"
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

// MARK: - Battery Metrics

struct BatteryMetrics: Codable {
    let level: Double // Percentage 0-100
    let state: BatteryState
    let isCharging: Bool
    let timestamp: Date

    enum BatteryState: String, Codable {
        case unknown
        case unplugged
        case charging
        case full
    }

    var levelPercentage: Double {
        return level
    }

    static let zero = BatteryMetrics(
        level: 0,
        state: .unknown,
        isCharging: false,
        timestamp: Date()
    )
}

// MARK: - Disk I/O Metrics

struct DiskIOMetrics: Codable {
    let readBytes: UInt64
    let writeBytes: UInt64
    let readSpeed: Double // Bytes per second
    let writeSpeed: Double // Bytes per second
    let timestamp: Date

    var readSpeedMBps: Double {
        return readSpeed / 1_048_576.0
    }

    var writeSpeedMBps: Double {
        return writeSpeed / 1_048_576.0
    }

    var totalReadMB: Double {
        return Double(readBytes) / 1_048_576.0
    }

    var totalWriteMB: Double {
        return Double(writeBytes) / 1_048_576.0
    }

    static let zero = DiskIOMetrics(
        readBytes: 0,
        writeBytes: 0,
        readSpeed: 0,
        writeSpeed: 0,
        timestamp: Date()
    )
}

// MARK: - Metrics Snapshot

struct MetricsSnapshot: Codable {
    let cpu: CPUMetrics
    let memory: MemoryMetrics
    let network: NetworkMetrics
    let storage: StorageMetrics
    let battery: BatteryMetrics
    let diskIO: DiskIOMetrics
    let timestamp: Date

    static let zero = MetricsSnapshot(
        cpu: .zero,
        memory: .zero,
        network: .zero,
        storage: .zero,
        battery: .zero,
        diskIO: .zero,
        timestamp: Date()
    )
}
